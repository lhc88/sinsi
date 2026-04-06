import '../data/evolutions.dart';
import '../components/weapons/weapon_manager.dart';
import '../systems/level_up_system.dart';

class EvolutionSystem {
  /// 진화 가능한 무기 목록 반환
  List<EvolutionData> getAvailableEvolutions(
      WeaponManager weaponManager, LevelUpSystem levelUpSystem) {
    final results = <EvolutionData>[];

    for (final evo in evolutionTable.values) {
      // 무기 Lv.8 (index 7) 확인
      final weaponLevel = weaponManager.getWeaponLevel(evo.sourceWeapon);
      if (weaponLevel < 7) continue; // 0-indexed, 7 = Lv.8

      // 대응 패시브 보유 확인
      if (!levelUpSystem.passiveLevels.containsKey(evo.requiredPassive)) continue;

      // 이미 진화했으면 스킵
      if (weaponManager.hasWeapon(evo.id)) continue;

      results.add(evo);
    }

    return results;
  }

  /// 진화 실행
  bool evolve(String evolutionId, WeaponManager weaponManager) {
    final evo = evolutionTable[evolutionId];
    if (evo == null) return false;

    // 원본 무기 제거
    weaponManager.weapons.removeWhere((w) => w.weaponId == evo.sourceWeapon);

    // 진화 무기 추가 (최고 레벨)
    weaponManager.weapons.add(ActiveWeapon(
      weaponId: evolutionId,
      level: 0, // 진화 무기는 단일 레벨
    ));

    return true;
  }

  /// 진화 미리보기: 보유 무기별 필요한 패시브 + 진도 표시
  List<EvolutionHint> getEvolutionHints(
      WeaponManager weaponManager, LevelUpSystem levelUpSystem) {
    final hints = <EvolutionHint>[];

    for (final evo in evolutionTable.values) {
      // 이미 진화했으면 스킵
      if (weaponManager.hasWeapon(evo.id)) continue;

      // 해당 무기 보유 중인지
      final weaponLevel = weaponManager.getWeaponLevel(evo.sourceWeapon);
      if (weaponLevel < 0) continue; // 미보유

      final hasPassive = levelUpSystem.passiveLevels.containsKey(evo.requiredPassive);
      final isMaxLevel = weaponLevel >= 7;

      hints.add(EvolutionHint(
        evolutionId: evo.id,
        evolutionName: evo.name,
        sourceWeapon: evo.sourceWeapon,
        requiredPassive: evo.requiredPassive,
        weaponLevel: weaponLevel + 1,
        hasPassive: hasPassive,
        isMaxLevel: isMaxLevel,
        isReady: isMaxLevel && hasPassive,
      ));
    }

    return hints;
  }

  /// 합체 가능한 목록
  List<UnionData> getAvailableUnions(WeaponManager weaponManager) {
    final results = <UnionData>[];

    for (final union in unionTable.values) {
      if (weaponManager.hasWeapon(union.weapon1) &&
          weaponManager.hasWeapon(union.weapon2)) {
        results.add(union);
      }
    }

    return results;
  }

  /// 합체 실행
  bool unite(String unionId, WeaponManager weaponManager) {
    final union = unionTable[unionId];
    if (union == null) return false;

    // 두 무기 제거
    weaponManager.weapons.removeWhere(
        (w) => w.weaponId == union.weapon1 || w.weaponId == union.weapon2);

    // 합체 무기 추가
    weaponManager.weapons.add(ActiveWeapon(weaponId: unionId, level: 0));

    return true;
  }
}

class EvolutionHint {
  final String evolutionId;
  final String evolutionName;
  final String sourceWeapon;
  final String requiredPassive;
  final int weaponLevel; // 현재 레벨 (1-8)
  final bool hasPassive;
  final bool isMaxLevel;
  final bool isReady; // 진화 가능

  const EvolutionHint({
    required this.evolutionId,
    required this.evolutionName,
    required this.sourceWeapon,
    required this.requiredPassive,
    required this.weaponLevel,
    required this.hasPassive,
    required this.isMaxLevel,
    required this.isReady,
  });
}
