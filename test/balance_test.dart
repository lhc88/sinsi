import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/weapons.dart';
import 'package:sinsi_survivor/data/enemies.dart';
import 'package:sinsi_survivor/utils/tuning_params.dart';

void main() {
  group('DPS 시뮬레이션 — 무기별 초당 데미지', () {
    for (final entry in weaponTable.entries) {
      test('${entry.value.name} (${entry.key}) DPS 검증', () {
        final info = entry.value;
        for (int lvIdx = 0; lvIdx < info.levels.length; lvIdx++) {
          final data = info.levels[lvIdx];
          final dps = data.damage * data.amount / data.cooldown;
          // ignore: avoid_print
          print('  Lv.${lvIdx + 1}: DMG=${data.damage} × ${data.amount}발 / ${data.cooldown}s = ${dps.toStringAsFixed(1)} DPS  (CD=${data.cooldown}s, SPD=${data.speed}, PIERCE=${data.pierce})');
        }
      });
    }
  });

  group('적 HP vs 무기 DPS — 킬타임 분석', () {
    // 대표 무기: 퇴마부적 Lv.1
    final mainWeapon = weaponTable['toema_bujeok']!.levels[0];
    final dps = mainWeapon.damage * mainWeapon.amount / mainWeapon.cooldown;

    for (final entry in enemyTable.entries) {
      test('${entry.value.name} (HP ${entry.value.baseHp}) vs 퇴마부적 Lv.1', () {
        final enemy = entry.value;

        // 0분 (게임 시작)
        final hp0 = enemy.baseHp;
        final killTime0 = hp0 / dps;

        // 5분 경과
        final hp5 = enemy.baseHp * (1 + 5 * TuningParams.enemyHpScale);
        final killTime5 = hp5 / dps;

        // 10분 경과
        final hp10 = enemy.baseHp * (1 + 10 * TuningParams.enemyHpScale);
        final killTime10 = hp10 / dps;

        // ignore: avoid_print
        print('  ${entry.value.name}: '
            '0분 HP=${hp0.toStringAsFixed(0)} 킬타임=${killTime0.toStringAsFixed(2)}s | '
            '5분 HP=${hp5.toStringAsFixed(0)} 킬타임=${killTime5.toStringAsFixed(2)}s | '
            '10분 HP=${hp10.toStringAsFixed(0)} 킬타임=${killTime10.toStringAsFixed(2)}s');

        // 유저 편의: 0분 잡귀는 1발 이내 킬 가능해야 함
        if (entry.key == EnemyType.jabgwi) {
          expect(mainWeapon.damage >= enemy.baseHp, isTrue,
              reason: '잡귀는 Lv.1 퇴마부적 1발에 처치 가능해야 함');
        }

        // 유저 편의: 0분 기준 모든 적 킬타임 3초 이내
        expect(killTime0 <= 3.0, isTrue,
            reason: '${entry.value.name} 0분 킬타임이 3초 초과');
      });
    }
  });

  group('플레이어 생존성 — 접촉 데미지 분석', () {
    test('적 데미지 vs 플레이어 HP', () {
      const playerMaxHp = 100.0; // 기본 HP
      const iFrame = 0.5; // 무적 시간
      // 접촉 쿨다운 (TuningParams.enemyContactCooldown으로 대체됨)

      for (final entry in enemyTable.entries) {
        final enemy = entry.value;

        // 0분
        final dmg0 = enemy.baseDamage;
        final hitsToKill0 = (playerMaxHp / dmg0).ceil();
        final timeToKill0 = hitsToKill0 * iFrame;

        // 5분
        final dmg5 = enemy.baseDamage * (1 + 5 * TuningParams.enemyDmgScale);
        final hitsToKill5 = (playerMaxHp / dmg5).ceil();

        // 10분
        final dmg10 = enemy.baseDamage * (1 + 10 * TuningParams.enemyDmgScale);
        final hitsToKill10 = (playerMaxHp / dmg10).ceil();

        // ignore: avoid_print
        print('  ${entry.value.name}: '
            '0분 DMG=${dmg0.toStringAsFixed(0)} ($hitsToKill0히트 생존, ${timeToKill0.toStringAsFixed(1)}s) | '
            '5분 DMG=${dmg5.toStringAsFixed(1)} ($hitsToKill5히트) | '
            '10분 DMG=${dmg10.toStringAsFixed(1)} ($hitsToKill10히트)');

        // 유저 편의: 잡귀 0분 기준 최소 10히트 이상 버텨야 함
        if (entry.key == EnemyType.jabgwi) {
          expect(hitsToKill0 >= 10, isTrue,
              reason: '잡귀에게 최소 10번은 맞아야 사망해야 함');
        }
      }
    });
  });
}
