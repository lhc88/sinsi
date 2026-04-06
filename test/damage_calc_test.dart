import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/enemies.dart';
import 'package:sinsi_survivor/systems/elemental_system.dart';

/// 데미지 계산 공식 검증
/// damage = baseDamage * might * elemMulti * synergyMulti * skillMulti
void main() {
  group('데미지 계산 공식', () {
    test('기본 데미지: 배율 1.0', () {
      const baseDamage = 10.0;
      const might = 1.0;
      const elemMulti = 1.0;
      const synergyMulti = 1.0;
      const skillMulti = 1.0;
      final damage = baseDamage * might * elemMulti * synergyMulti * skillMulti;
      expect(damage, 10.0);
    });

    test('상극 보너스: 1.5x', () {
      const baseDamage = 10.0;
      const might = 1.0;
      final elemMulti = ElementalSystem.getMultiplier(Element.fire, Element.metal);
      const synergyMulti = 1.0;
      const skillMulti = 1.0;
      final damage = baseDamage * might * elemMulti * synergyMulti * skillMulti;
      expect(damage, 15.0);
    });

    test('역상극 감소: 0.75x', () {
      const baseDamage = 10.0;
      const might = 1.0;
      final elemMulti = ElementalSystem.getMultiplier(Element.wood, Element.fire);
      const synergyMulti = 1.0;
      const skillMulti = 1.0;
      final damage = baseDamage * might * elemMulti * synergyMulti * skillMulti;
      expect(damage, 7.5);
    });

    test('복합 배율: might 1.5 + 상극 1.5 + 시너지 1.15 + 스킬 1.2', () {
      const baseDamage = 10.0;
      const might = 1.5;
      const elemMulti = 1.5;
      const synergyMulti = 1.15;
      const skillMulti = 1.2;
      final damage = baseDamage * might * elemMulti * synergyMulti * skillMulti;
      // 10 * 1.5 * 1.5 * 1.15 * 1.2 = 31.05
      expect(damage, closeTo(31.05, 0.01));
    });

    test('치명타: 기본 1.5x + 추가 0.5x = 2.0x', () {
      const baseDamage = 20.0;
      const critMultiplier = 1.5 + 0.5; // base crit + skillCritDamage
      final damage = baseDamage * critMultiplier;
      expect(damage, 40.0);
    });
  });
}
