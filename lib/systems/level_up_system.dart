import 'dart:math';
import '../data/enemies.dart' show Element;
import '../data/weapons.dart';
import '../data/passives.dart';
import '../components/weapons/weapon_manager.dart';

class LevelUpChoice {
  final String id;
  final String name;
  final String description;
  final bool isWeapon;
  final bool isNew;
  final int currentLevel; // -1 if new

  const LevelUpChoice({
    required this.id,
    required this.name,
    required this.description,
    required this.isWeapon,
    required this.isNew,
    required this.currentLevel,
  });
}

class LevelUpSystem {
  final Random _rng = Random();

  // 보유 패시브: id → level (0-indexed)
  final Map<String, int> passiveLevels = {};
  static const int maxPassiveSlots = 6;

  List<LevelUpChoice> generateChoices(WeaponManager weaponManager, {int count = 3, int extraChoices = 0, Element? onlyElement, bool noPassive = false}) {
    count += extraChoices;
    final candidates = <LevelUpChoice>[];

    // 무기 업그레이드 후보
    for (final weapon in weaponManager.weapons) {
      if (!weapon.isMaxLevel) {
        final nextLevel = weapon.level + 1;
        final nextData = weapon.info.levels[nextLevel];
        candidates.add(LevelUpChoice(
          id: weapon.weaponId,
          name: weapon.info.name,
          description: 'Lv.${nextLevel + 1} ${nextData.bonus.isNotEmpty ? nextData.bonus : "강화"}',
          isWeapon: true,
          isNew: false,
          currentLevel: weapon.level,
        ));
      }
    }

    // 새 무기 후보 (슬롯 여유 있을 때)
    if (weaponManager.weapons.length < WeaponManager.maxWeaponSlots) {
      for (final entry in weaponTable.entries) {
        if (!weaponManager.hasWeapon(entry.key)) {
          // 일일 도전 원소 필터
          if (onlyElement != null && entry.value.element != onlyElement) continue;
          candidates.add(LevelUpChoice(
            id: entry.key,
            name: entry.value.name,
            description: entry.value.description,
            isWeapon: true,
            isNew: true,
            currentLevel: -1,
          ));
        }
      }
    }

    // 패시브 업그레이드 후보 (일일 도전 noPassive 시 스킵)
    if (noPassive) {
      candidates.shuffle(_rng);
      return candidates.take(count).toList();
    }
    for (final entry in passiveLevels.entries) {
      final info = passiveTable[entry.key];
      if (info == null) continue;
      if (entry.value < info.levels.length - 1) {
        candidates.add(LevelUpChoice(
          id: entry.key,
          name: info.name,
          description: 'Lv.${entry.value + 2} ${info.description}',
          isWeapon: false,
          isNew: false,
          currentLevel: entry.value,
        ));
      }
    }

    // 새 패시브 후보
    if (passiveLevels.length < maxPassiveSlots) {
      for (final entry in passiveTable.entries) {
        if (!passiveLevels.containsKey(entry.key)) {
          candidates.add(LevelUpChoice(
            id: entry.key,
            name: entry.value.name,
            description: entry.value.description,
            isWeapon: false,
            isNew: true,
            currentLevel: -1,
          ));
        }
      }
    }

    // 셔플 후 count개 선택
    candidates.shuffle(_rng);
    return candidates.take(count).toList();
  }

  void applyChoice(LevelUpChoice choice, WeaponManager weaponManager, dynamic playerStats) {
    if (choice.isWeapon) {
      if (choice.isNew) {
        weaponManager.addWeapon(choice.id);
      } else {
        weaponManager.upgradeWeapon(choice.id);
      }
    } else {
      if (choice.isNew) {
        passiveLevels[choice.id] = 0;
      } else {
        passiveLevels[choice.id] = passiveLevels[choice.id]! + 1;
      }
      _applyPassiveStats(playerStats);
    }
  }

  // 패시브 누적 보너스 (기존 스탯 위에 가산)
  double _prevMight = 0;
  double _prevProjSpeed = 0;
  double _prevDuration = 0;
  double _prevArea = 0;
  double _prevCooldown = 0;
  double _prevHpRegen = 0;
  double _prevMaxHpBonus = 0;
  double _prevLifesteal = 0;
  double _prevCrit = 0;

  void _applyPassiveStats(dynamic stats) {
    // 이전 패시브 보너스를 되돌리기
    stats.might -= _prevMight;
    stats.projectileSpeed -= _prevProjSpeed;
    stats.duration -= _prevDuration;
    stats.area -= _prevArea;
    stats.cooldown += _prevCooldown; // 쿨다운은 감소였으므로 복원은 가산
    stats.hpRegen -= _prevHpRegen;
    stats.maxHp -= _prevMaxHpBonus;
    stats.skillLifesteal -= _prevLifesteal;
    stats.skillCritChance -= _prevCrit;

    // 새 패시브 보너스 계산
    double newMight = 0, newProjSpeed = 0, newDuration = 0;
    double newArea = 0, newCooldown = 0, newHpRegen = 0;
    double newMaxHpBonus = 0, newLifesteal = 0, newCrit = 0;

    for (final entry in passiveLevels.entries) {
      final info = passiveTable[entry.key];
      if (info == null) continue;
      for (int i = 0; i <= entry.value; i++) {
        final levelData = info.levels[i];
        switch (levelData.effect) {
          case 'might':
            newMight += levelData.value;
          case 'proj_speed':
            newProjSpeed += levelData.value;
          case 'duration':
            newDuration += levelData.value;
          case 'area':
            newArea += levelData.value;
          case 'cooldown':
            newCooldown += levelData.value;
          case 'hp_regen':
            newHpRegen += levelData.value;
            newMaxHpBonus += 20;
          case 'lifesteal':
            newLifesteal += levelData.value;
          case 'crit':
            newCrit += levelData.value;
          case 'poison':
            // poison DMG는 collision_system에서 passiveLevels 직접 참조
            break;
          case 'amount':
            // 투사체 수는 weapon_manager에서 passiveLevels 직접 참조
            break;
          case 'bounce':
            // 바운스도 weapon_manager에서 passiveLevels 직접 참조
            break;
          case 'summon':
            // 소환수 공격력은 weapon_manager에서 passiveLevels 직접 참조
            break;
        }
      }
    }

    // 새 보너스 적용
    stats.might += newMight;
    stats.projectileSpeed += newProjSpeed;
    stats.duration += newDuration;
    stats.area += newArea;
    stats.cooldown -= newCooldown;
    stats.hpRegen += newHpRegen;
    stats.maxHp += newMaxHpBonus;
    stats.skillLifesteal += newLifesteal;
    stats.skillCritChance += newCrit;

    // 캐시 저장
    _prevMight = newMight;
    _prevProjSpeed = newProjSpeed;
    _prevDuration = newDuration;
    _prevArea = newArea;
    _prevCooldown = newCooldown;
    _prevHpRegen = newHpRegen;
    _prevMaxHpBonus = newMaxHpBonus;
    _prevLifesteal = newLifesteal;
    _prevCrit = newCrit;

    // 쿨다운 하한
    if (stats.cooldown < 0.2) stats.cooldown = 0.2;
    // HP 상한 반영
    if (stats.currentHp > stats.maxHp) stats.currentHp = stats.maxHp;
  }

  void reset() {
    passiveLevels.clear();
    _prevMight = 0;
    _prevProjSpeed = 0;
    _prevDuration = 0;
    _prevArea = 0;
    _prevCooldown = 0;
    _prevHpRegen = 0;
    _prevMaxHpBonus = 0;
    _prevLifesteal = 0;
    _prevCrit = 0;
  }
}
