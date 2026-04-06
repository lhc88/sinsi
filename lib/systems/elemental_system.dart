import '../data/enemies.dart';

/// 음양오행 상성 시스템
class ElementalSystem {
  // 상성표: 공격 원소 → 방어 원소 → 배율
  static const Map<Element, Map<Element, double>> _table = {
    Element.wood:  {Element.wood: 1.0, Element.fire: 0.75, Element.earth: 1.5, Element.metal: 1.0, Element.water: 1.0},
    Element.fire:  {Element.wood: 1.0, Element.fire: 1.0,  Element.earth: 0.75, Element.metal: 1.5, Element.water: 1.0},
    Element.earth: {Element.wood: 1.0, Element.fire: 1.0,  Element.earth: 1.0,  Element.metal: 0.75, Element.water: 1.5},
    Element.metal: {Element.wood: 1.5, Element.fire: 1.0,  Element.earth: 1.0,  Element.metal: 1.0,  Element.water: 0.75},
    Element.water: {Element.wood: 0.75, Element.fire: 1.5, Element.earth: 1.0,  Element.metal: 1.0,  Element.water: 1.0},
    Element.none:  {},
  };

  static double getMultiplier(Element attack, Element defend) {
    if (attack == Element.none || defend == Element.none) return 1.0;
    return _table[attack]?[defend] ?? 1.0;
  }

  /// 시너지 보너스 계산
  static SynergyBonus calculateSynergy(List<Element> weaponElements) {
    final bonus = SynergyBonus();
    final counts = <Element, int>{};

    for (final e in weaponElements) {
      if (e == Element.none) continue;
      counts[e] = (counts[e] ?? 0) + 1;
    }

    // 동일 원소 2개: 해당 원소 DMG +15%
    // 동일 원소 3개: 해당 원소 DMG +30%, 쿨 -10%
    for (final entry in counts.entries) {
      if (entry.value >= 3) {
        bonus.elementDamageBonus[entry.key] = 0.30;
        bonus.cooldownReduction += 0.10;
        bonus.activeNames.add('삼재합일 (${_elementName(entry.key)})');
      } else if (entry.value >= 2) {
        bonus.elementDamageBonus[entry.key] = 0.15;
        bonus.activeNames.add('이기동심 (${_elementName(entry.key)})');
      }
    }

    // 5원소 각 1개+: 전체 DMG +20%, 기운 +20%
    if (counts.length >= 5) {
      bonus.globalDamageBonus += 0.20;
      bonus.expBonus += 0.20;
      bonus.activeNames.add('오행조화');
    }

    // 상극 원소 2개 보유: 상극 DMG +10%
    final elements = counts.keys.toList();
    for (int i = 0; i < elements.length; i++) {
      for (int j = i + 1; j < elements.length; j++) {
        if (_isCounter(elements[i], elements[j])) {
          bonus.counterBonus += 0.10;
          bonus.activeNames.add('상극상승');
          break;
        }
      }
    }

    // 상생 조합: 인접 원소 보유 시 이속 +5%, 방어 +5%
    // 상생 순서: 목→화→토→금→수→목
    int adjacentCount = 0;
    for (final e in elements) {
      final next = _nextInCycle(e);
      if (counts.containsKey(next)) {
        adjacentCount++;
      }
    }
    if (adjacentCount >= 2) {
      bonus.moveSpeedBonus += 0.08;
      bonus.defenseBonus += 0.08;
      bonus.activeNames.add('상생순환');
    } else if (adjacentCount >= 1) {
      bonus.moveSpeedBonus += 0.04;
      bonus.defenseBonus += 0.04;
      bonus.activeNames.add('상생조화');
    }

    // 삼합 (목+화+토, 화+토+금, 토+금+수 등): 범위 +10%
    if (counts.length >= 3) {
      for (int i = 0; i < _cycleOrder.length; i++) {
        final a = _cycleOrder[i];
        final b = _cycleOrder[(i + 1) % 5];
        final c = _cycleOrder[(i + 2) % 5];
        if (counts.containsKey(a) && counts.containsKey(b) && counts.containsKey(c)) {
          bonus.areaBonus += 0.10;
          bonus.activeNames.add('삼합 (${_elementName(a)}${_elementName(b)}${_elementName(c)})');
          break;
        }
      }
    }

    return bonus;
  }

  static const _cycleOrder = [Element.wood, Element.fire, Element.earth, Element.metal, Element.water];

  static Element _nextInCycle(Element e) => switch (e) {
    Element.wood => Element.fire,
    Element.fire => Element.earth,
    Element.earth => Element.metal,
    Element.metal => Element.water,
    Element.water => Element.wood,
    Element.none => Element.none,
  };

  static bool _isCounter(Element a, Element b) {
    final mul = getMultiplier(a, b);
    return mul > 1.0 || getMultiplier(b, a) > 1.0;
  }

  static String _elementName(Element e) => switch (e) {
    Element.wood => '목',
    Element.fire => '화',
    Element.earth => '토',
    Element.metal => '금',
    Element.water => '수',
    Element.none => '-',
  };
}

class SynergyBonus {
  final Map<Element, double> elementDamageBonus = {};
  double globalDamageBonus = 0;
  double cooldownReduction = 0;
  double expBonus = 0;
  double counterBonus = 0;
  double moveSpeedBonus = 0;
  double defenseBonus = 0;
  double areaBonus = 0;
  final List<String> activeNames = [];
}
