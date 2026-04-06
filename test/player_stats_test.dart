import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/components/player/player_stats.dart';

void main() {
  group('PlayerStats — HP / 회복 / 데미지', () {
    late PlayerStats stats;

    setUp(() {
      stats = PlayerStats(maxHp: 100, currentHp: 100);
    });

    test('heal() 기본 회복', () {
      stats.currentHp = 50;
      stats.heal(30);
      expect(stats.currentHp, 80);
    });

    test('heal() 최대 HP 초과 방지', () {
      stats.currentHp = 90;
      stats.heal(50);
      expect(stats.currentHp, 100);
    });

    test('healBlocked 시 heal() 무효', () {
      stats.healBlocked = true;
      stats.currentHp = 50;
      stats.heal(30);
      expect(stats.currentHp, 50);
    });

    test('healBlocked 시 effectiveHpRegen 0 반환', () {
      stats.hpRegen = 5.0;
      stats.healBlocked = true;
      expect(stats.effectiveHpRegen(false), 0);
      expect(stats.effectiveHpRegen(true), 0);
    });

    test('takeDamage() 기본 데미지', () {
      stats.takeDamage(30);
      expect(stats.currentHp, 70);
      expect(stats.totalDamageTaken, 30);
    });

    test('takeDamage() 방어력 적용', () {
      stats.skillDamageReduction = 0.5;
      stats.takeDamage(40);
      // 40 * (1 - 0.5) = 20
      expect(stats.currentHp, 80);
      expect(stats.totalDamageTaken, 20);
    });

    test('takeDamage() HP 0 미만 방지', () {
      stats.takeDamage(200);
      expect(stats.currentHp, 0);
    });

    test('addExp() 레벨업 반환', () {
      stats.expToNext = 10;
      final leveledUp = stats.addExp(15);
      expect(leveledUp, true);
      expect(stats.level, 2);
    });

    test('addExp() 레벨업 미달', () {
      stats.expToNext = 100;
      final leveledUp = stats.addExp(5);
      expect(leveledUp, false);
      expect(stats.level, 1);
    });

    test('isDead 판정', () {
      expect(stats.isDead, false);
      stats.currentHp = 0;
      expect(stats.isDead, true);
    });

    test('skillCritPenalty 플래그 기본값', () {
      expect(stats.skillCritPenalty, false);
    });

    test('totalDamageDealt 추적', () {
      expect(stats.totalDamageDealt, 0);
      stats.totalDamageDealt += 100;
      expect(stats.totalDamageDealt, 100);
    });

    test('bestKillStreak 추적', () {
      expect(stats.bestKillStreak, 0);
      stats.bestKillStreak = 25;
      expect(stats.bestKillStreak, 25);
    });
  });
}
