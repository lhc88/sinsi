import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/evolutions.dart';
import 'package:sinsi_survivor/data/weapons.dart';
import 'package:sinsi_survivor/components/weapons/weapon_manager.dart';
import 'package:sinsi_survivor/systems/evolution_system.dart';
import 'package:sinsi_survivor/systems/level_up_system.dart';

/// Test helper: adds weapon without triggering SaveService.discover()
void _addWeaponForTest(WeaponManager wm, String weaponId) {
  if (wm.weapons.length >= WeaponManager.maxWeaponSlots) return;
  if (wm.weapons.any((w) => w.weaponId == weaponId)) return;
  wm.weapons.add(ActiveWeapon(weaponId: weaponId));
}

void main() {
  group('EvolutionSystem', () {
    late EvolutionSystem evoSystem;
    late WeaponManager weaponManager;
    late LevelUpSystem levelUpSystem;

    setUp(() {
      evoSystem = EvolutionSystem();
      weaponManager = WeaponManager();
      levelUpSystem = LevelUpSystem();
    });

    test('진화 조건: 무기 Lv.8 미만이면 불가', () {
      _addWeaponForTest(weaponManager, 'toema_bujeok');
      levelUpSystem.passiveLevels['hwatotbul'] = 0;
      // Lv.1 (level index 0)
      final evos = evoSystem.getAvailableEvolutions(weaponManager, levelUpSystem);
      expect(evos, isEmpty);
    });

    test('진화 조건: 무기 Lv.8 + 패시브 보유 시 가능', () {
      _addWeaponForTest(weaponManager, 'toema_bujeok');
      // Lv.8 = index 7
      for (int i = 0; i < 7; i++) {
        weaponManager.upgradeWeapon('toema_bujeok');
      }
      levelUpSystem.passiveLevels['hwatotbul'] = 0;
      final evos = evoSystem.getAvailableEvolutions(weaponManager, levelUpSystem);
      expect(evos.length, 1);
      expect(evos.first.id, 'cheonloe_bujeok');
    });

    test('진화 조건: 패시브 미보유 시 불가', () {
      _addWeaponForTest(weaponManager, 'toema_bujeok');
      for (int i = 0; i < 7; i++) {
        weaponManager.upgradeWeapon('toema_bujeok');
      }
      // 패시브 없음
      final evos = evoSystem.getAvailableEvolutions(weaponManager, levelUpSystem);
      expect(evos, isEmpty);
    });

    test('진화 실행: 원본 제거 + 진화 무기 추가', () {
      _addWeaponForTest(weaponManager, 'toema_bujeok');
      final result = evoSystem.evolve('cheonloe_bujeok', weaponManager);
      expect(result, true);
      expect(weaponManager.hasWeapon('toema_bujeok'), false);
      expect(weaponManager.hasWeapon('cheonloe_bujeok'), true);
    });

    test('모든 진화 무기가 유효한 원본+패시브 참조', () {
      for (final evo in evolutionTable.values) {
        expect(weaponTable.containsKey(evo.sourceWeapon), true,
            reason: '${evo.id}의 sourceWeapon ${evo.sourceWeapon}이 weaponTable에 없음');
      }
    });

    test('합체: 두 무기 보유 시 가능', () {
      // samsin_halmi: sinseong_bangul + geumgangeo
      _addWeaponForTest(weaponManager, 'sinseong_bangul');
      _addWeaponForTest(weaponManager, 'geumgangeo');
      final unions = evoSystem.getAvailableUnions(weaponManager);
      expect(unions.any((u) => u.id == 'samsin_halmi'), true);
    });

    test('합체 실행: 두 무기 제거 + 합체 무기 추가', () {
      _addWeaponForTest(weaponManager, 'sinseong_bangul');
      _addWeaponForTest(weaponManager, 'geumgangeo');
      final result = evoSystem.unite('samsin_halmi', weaponManager);
      expect(result, true);
      expect(weaponManager.hasWeapon('sinseong_bangul'), false);
      expect(weaponManager.hasWeapon('geumgangeo'), false);
      expect(weaponManager.hasWeapon('samsin_halmi'), true);
    });
  });
}
