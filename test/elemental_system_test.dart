import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/enemies.dart';
import 'package:sinsi_survivor/systems/elemental_system.dart';

void main() {
  group('ElementalSystem.getMultiplier', () {
    test('상극: 목→토 = 1.5x', () {
      expect(ElementalSystem.getMultiplier(Element.wood, Element.earth), 1.5);
    });

    test('상극: 화→금 = 1.5x', () {
      expect(ElementalSystem.getMultiplier(Element.fire, Element.metal), 1.5);
    });

    test('상극: 토→수 = 1.5x', () {
      expect(ElementalSystem.getMultiplier(Element.earth, Element.water), 1.5);
    });

    test('상극: 금→목 = 1.5x', () {
      expect(ElementalSystem.getMultiplier(Element.metal, Element.wood), 1.5);
    });

    test('상극: 수→화 = 1.5x', () {
      expect(ElementalSystem.getMultiplier(Element.water, Element.fire), 1.5);
    });

    test('역상극: 토→목 = 0.75x', () {
      expect(ElementalSystem.getMultiplier(Element.earth, Element.wood), 1.0);
    });

    test('역상극: 목→화 = 0.75x', () {
      expect(ElementalSystem.getMultiplier(Element.wood, Element.fire), 0.75);
    });

    test('동일 원소 = 1.0x', () {
      expect(ElementalSystem.getMultiplier(Element.fire, Element.fire), 1.0);
    });

    test('none 원소 = 1.0x', () {
      expect(ElementalSystem.getMultiplier(Element.none, Element.fire), 1.0);
      expect(ElementalSystem.getMultiplier(Element.fire, Element.none), 1.0);
    });
  });

  group('ElementalSystem.calculateSynergy', () {
    test('동일 원소 2개: DMG +15%', () {
      final bonus = ElementalSystem.calculateSynergy([Element.fire, Element.fire]);
      expect(bonus.elementDamageBonus[Element.fire], 0.15);
    });

    test('동일 원소 3개: DMG +30%, 쿨 -10%', () {
      final bonus = ElementalSystem.calculateSynergy([Element.fire, Element.fire, Element.fire]);
      expect(bonus.elementDamageBonus[Element.fire], 0.30);
      expect(bonus.cooldownReduction, 0.10);
    });

    test('5원소 조화: 전체 DMG +20%, 기운 +20%', () {
      final bonus = ElementalSystem.calculateSynergy([
        Element.wood, Element.fire, Element.earth, Element.metal, Element.water,
      ]);
      expect(bonus.globalDamageBonus, 0.20);
      expect(bonus.expBonus, 0.20);
    });

    test('상극 원소 2개: 상극 DMG +10%', () {
      final bonus = ElementalSystem.calculateSynergy([Element.fire, Element.metal]);
      expect(bonus.counterBonus, 0.10);
    });

    test('none 원소는 시너지에 불포함', () {
      final bonus = ElementalSystem.calculateSynergy([Element.none, Element.none]);
      expect(bonus.elementDamageBonus.isEmpty, true);
    });
  });
}
