import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/weapons.dart';
import 'package:sinsi_survivor/data/evolutions.dart';

void main() {
  group('무기 데이터 무결성', () {
    test('기본 무기가 8레벨 데이터 보유', () {
      // 진화/합체 무기는 1레벨만 (의도된 설계)
      final baseWeapons = weaponTable.entries.where((e) => e.value.levels.length > 1 || e.value.evolutionId != null);
      for (final entry in baseWeapons) {
        if (entry.value.evolutionId != null) {
          expect(entry.value.levels.length, 8,
              reason: '${entry.key} 기본 무기 레벨 수 != 8');
        }
      }
      // 진화/합체 무기는 1레벨
      final evolvedWeapons = weaponTable.entries.where((e) => e.value.levels.length == 1 && e.value.evolutionId == null);
      for (final entry in evolvedWeapons) {
        expect(entry.value.levels.length, 1,
            reason: '${entry.key} 진화 무기 레벨 수 != 1');
      }
    });

    test('레벨별 데미지 비감소', () {
      for (final entry in weaponTable.entries) {
        for (int i = 1; i < entry.value.levels.length; i++) {
          expect(entry.value.levels[i].damage, greaterThanOrEqualTo(entry.value.levels[i - 1].damage),
              reason: '${entry.key} Lv.${i + 1} 데미지 감소');
        }
      }
    });

    test('쿨다운 양수', () {
      for (final entry in weaponTable.entries) {
        for (int i = 0; i < entry.value.levels.length; i++) {
          expect(entry.value.levels[i].cooldown, greaterThan(0),
              reason: '${entry.key} Lv.${i + 1} 쿨다운 0 이하');
        }
      }
    });

    test('진화 무기 참조 유효', () {
      for (final entry in weaponTable.entries) {
        if (entry.value.evolutionId != null) {
          expect(evolutionTable.containsKey(entry.value.evolutionId), true,
              reason: '${entry.key}의 evolutionId ${entry.value.evolutionId} 미존재');
        }
      }
    });

    test('cheondung/punggyeong 무기 존재', () {
      expect(weaponTable.containsKey('cheondung'), true);
      expect(weaponTable.containsKey('punggyeong'), true);
    });

    test('무기 최소 12종 이상', () {
      expect(weaponTable.length, greaterThanOrEqualTo(12));
    });
  });
}
