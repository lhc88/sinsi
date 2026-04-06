import 'dart:math';
import 'package:flame/components.dart';
import '../../data/enemies.dart';
import '../../data/weapons.dart';
import '../../game/toemalok_game.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';

class ActiveWeapon {
  final String weaponId;
  int level; // 0-indexed (0 = Lv.1)
  double cooldownTimer;

  ActiveWeapon({required this.weaponId, this.level = 0, this.cooldownTimer = 0});

  WeaponInfo get info => weaponTable[weaponId]!;
  WeaponLevelData get data => info.levels[level];
  bool get isMaxLevel => level >= info.levels.length - 1;
}

class WeaponManager {
  final List<ActiveWeapon> weapons = [];
  final Random _rng = Random();
  static const int maxWeaponSlots = 6;

  void addWeapon(String weaponId) {
    if (weapons.length >= maxWeaponSlots) return;
    if (weapons.any((w) => w.weaponId == weaponId)) return;
    weapons.add(ActiveWeapon(weaponId: weaponId));
    SaveService.instance.discover(weaponId);
  }

  bool upgradeWeapon(String weaponId) {
    final weapon = weapons.where((w) => w.weaponId == weaponId).firstOrNull;
    if (weapon == null || weapon.isMaxLevel) return false;
    weapon.level++;
    return true;
  }

  bool hasWeapon(String weaponId) => weapons.any((w) => w.weaponId == weaponId);

  int getWeaponLevel(String weaponId) {
    return weapons.where((w) => w.weaponId == weaponId).firstOrNull?.level ?? -1;
  }

  void update(double dt, ToemalokGame game) {
    for (final weapon in weapons) {
      weapon.cooldownTimer -= dt;
      if (weapon.cooldownTimer > 0) continue;

      final data = weapon.data;
      final cd = data.cooldown * game.player.stats.cooldown * (1.0 - game.player.stats.synergyCooldownBonus);
      weapon.cooldownTimer = cd.clamp(0.1, double.infinity);

      _fireWeapon(weapon, game);
      AudioService.weaponFire(weapon.weaponId);
    }
  }

  void _fireWeapon(ActiveWeapon weapon, ToemalokGame game) {
    final player = game.player;
    final data = weapon.data;
    final might = player.stats.might;
    final projSpeed = data.speed * player.stats.projectileSpeed;
    final damage = data.damage * might * game.reverseTimerMultiplier;
    final area = data.area * player.stats.area * (1 + player.stats.synergyAreaBonus);
    final elem = weapon.info.element;

    // 패시브 보너스: 나침반(투사체+1), 두꺼비석상(관통+1)
    final passives = game.levelUpSystem.passiveLevels;
    int extraAmount = 0;
    int extraPierce = 0;
    if (passives.containsKey('nachimban')) {
      for (int i = 0; i <= passives['nachimban']!; i++) {
        if (i == 1 || i == 3) extraAmount++; // Lv.2, Lv.4에서 +1
      }
    }
    if (passives.containsKey('dukkeobi_seoksang')) {
      for (int i = 0; i <= passives['dukkeobi_seoksang']!; i++) {
        if (i == 2 || i == 4) extraPierce++; // Lv.3, Lv.5에서 +1
      }
    }
    extraPierce += player.stats.skillExtraPierce;

    // skillTripleShot: 직선/부채꼴 무기를 3방향으로 발사
    final tripleShot = game.player.stats.skillTripleShot;
    // skillProjectileHoming: 모든 투사체에 호밍 적용 (chase 제외, 이미 homing)
    final globalHoming = game.player.stats.skillProjectileHoming;

    switch (weapon.info.pattern) {
      case 'fan':
        _fireFan(weapon, game, damage, projSpeed, area, elem, extraAmount, extraPierce, tripleShot: tripleShot, homing: globalHoming);
      case 'homing':
        _fireHoming(weapon, game, damage, projSpeed, elem, extraAmount, extraPierce);
      case 'spin':
        _fireSpin(weapon, game, damage, area);
      case 'straight':
        _fireStraight(weapon, game, damage, projSpeed, elem, extraAmount, extraPierce, tripleShot: tripleShot, homing: globalHoming);
      case 'radial':
      case 'radial8':
        _fireRadial(weapon, game, damage, projSpeed, elem, extraAmount, extraPierce, homing: globalHoming);
      case 'random':
        _fireRandom(weapon, game, damage, area, extraAmount);
      case 'aura':
        _fireAura(weapon, game, damage, area);
      case 'melee':
        _fireMelee(weapon, game, damage, area);
      case 'bounce':
        _fireBounce(weapon, game, damage, projSpeed, elem, extraAmount, extraPierce, homing: globalHoming);
      case 'chase':
        _fireChase(weapon, game, damage, projSpeed, elem, extraAmount, extraPierce);
    }
  }

  void _fireFan(ActiveWeapon weapon, ToemalokGame game, double damage, double speed, double areaAngle, Element elem, int extraAmount, int extraPierce, {bool tripleShot = false, bool homing = false}) {
    final player = game.player;
    final data = weapon.data;
    final amount = data.amount + extraAmount;
    final facing = player.facingDirection;
    final baseAngle = atan2(facing.y, facing.x);
    final spreadRad = areaAngle * pi / 180;

    // tripleShot: 전방/좌45°/우45° 3방향
    final offsets = tripleShot ? [0.0, -pi / 4, pi / 4] : [0.0];

    for (final angleOffset in offsets) {
      for (int i = 0; i < amount; i++) {
        double angle;
        if (amount == 1) {
          angle = baseAngle + angleOffset;
        } else {
          angle = baseAngle + angleOffset - spreadRad / 2 + spreadRad * i / (amount - 1);
        }
        final vel = Vector2(cos(angle), sin(angle)) * speed;
        game.projectileManager.spawn(
          weaponId: weapon.weaponId,
          position: player.position.clone(),
          velocity: vel,
          damage: tripleShot ? damage * 0.6 : damage,
          pierce: data.pierce + extraPierce,
          area: 24,
          size: 10,
          element: elem,
          homing: homing,
        );
      }
    }
  }

  void _fireHoming(ActiveWeapon weapon, ToemalokGame game, double damage, double speed, Element elem, int extraAmount, int extraPierce) {
    final player = game.player;
    final data = weapon.data;
    final enemies = game.enemyManager.activeEnemies;

    // 가장 가까운 적 찾기
    Vector2? targetDir;
    double closest = double.infinity;
    for (final e in enemies) {
      if (!e.isActive) continue;
      final dist = e.position.distanceTo(player.position);
      if (dist < closest) {
        closest = dist;
        targetDir = (e.position - player.position).normalized();
      }
    }

    targetDir ??= player.facingDirection;

    for (int i = 0; i < data.amount + extraAmount; i++) {
      final offset = Vector2(_rng.nextDouble() * 20 - 10, _rng.nextDouble() * 20 - 10);
      game.projectileManager.spawn(
        weaponId: weapon.weaponId,
        position: player.position + offset,
        velocity: targetDir * speed,
        damage: damage,
        pierce: data.pierce + extraPierce,
        maxLifetime: data.duration,
        area: 24,
        size: 8,
        element: elem,
      );
    }
  }

  void _fireSpin(ActiveWeapon weapon, ToemalokGame game, double damage, double area) {
    // 회전 참격: 플레이어 주변 원형 범위에 있는 적 직접 데미지
    final player = game.player;
    for (final enemy in game.enemyManager.activeEnemies) {
      if (!enemy.isActive) continue;
      if (enemy.position.distanceTo(player.position) < area) {
        game.enemyManager.applyDamage(enemy, damage);
        game.effectManager.spawnDamageNumber(enemy.position, damage);
      }
    }
  }

  void _fireStraight(ActiveWeapon weapon, ToemalokGame game, double damage, double speed, Element elem, int extraAmount, int extraPierce, {bool tripleShot = false, bool homing = false}) {
    final player = game.player;
    final data = weapon.data;
    final area = data.area * player.stats.area * (1 + player.stats.synergyAreaBonus);
    final facing = player.facingDirection;
    final baseAngle = atan2(facing.y, facing.x);

    final offsets = tripleShot ? [0.0, -pi / 6, pi / 6] : [0.0];

    for (final angleOffset in offsets) {
      final dir = Vector2(cos(baseAngle + angleOffset), sin(baseAngle + angleOffset));
      for (int i = 0; i < data.amount + extraAmount; i++) {
        final spread = Vector2(
          _rng.nextDouble() * 10 - 5,
          _rng.nextDouble() * 10 - 5,
        );
        game.projectileManager.spawn(
          weaponId: weapon.weaponId,
          position: player.position.clone(),
          velocity: dir * speed + spread,
          damage: tripleShot ? damage * 0.6 : damage,
          pierce: data.pierce + extraPierce,
          area: area,
          size: 12,
          element: elem,
          homing: homing,
        );
      }
    }
  }

  void _fireRadial(ActiveWeapon weapon, ToemalokGame game, double damage, double speed, Element elem, int extraAmount, int extraPierce, {bool homing = false}) {
    final player = game.player;
    final data = weapon.data;
    final amount = data.amount + extraAmount;

    for (int i = 0; i < amount; i++) {
      final angle = 2 * pi * i / amount;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.projectileManager.spawn(
        weaponId: weapon.weaponId,
        position: player.position.clone(),
        velocity: vel,
        damage: damage,
        pierce: data.pierce + extraPierce,
        area: 24,
        size: 8,
        element: elem,
        homing: homing,
      );
    }
  }

  void _fireRandom(ActiveWeapon weapon, ToemalokGame game, double damage, double area, int extraAmount) {
    final player = game.player;
    final data = weapon.data;

    for (int i = 0; i < data.amount + extraAmount; i++) {
      final offset = Vector2(
        _rng.nextDouble() * 400 - 200,
        _rng.nextDouble() * 300 - 150,
      );
      final pos = player.position + offset;
      // 즉발 폭발: 범위 내 적에게 데미지
      for (final enemy in game.enemyManager.activeEnemies) {
        if (!enemy.isActive) continue;
        if (enemy.position.distanceTo(pos) < area) {
          game.enemyManager.applyDamage(enemy, damage);
          game.effectManager.spawnDamageNumber(enemy.position, damage);
        }
      }
      game.effectManager.spawnExplosion(pos, area);
    }
  }

  void _fireAura(ActiveWeapon weapon, ToemalokGame game, double damage, double area) {
    final player = game.player;
    for (final enemy in game.enemyManager.activeEnemies) {
      if (!enemy.isActive) continue;
      if (enemy.position.distanceTo(player.position) < area) {
        game.enemyManager.applyDamage(enemy, damage);
      }
    }
  }

  void _fireMelee(ActiveWeapon weapon, ToemalokGame game, double damage, double area) {
    final player = game.player;
    final facing = player.facingDirection;
    final hitPos = player.position + facing * (area * 0.5);

    for (final enemy in game.enemyManager.activeEnemies) {
      if (!enemy.isActive) continue;
      if (enemy.position.distanceTo(hitPos) < area) {
        game.enemyManager.applyDamage(enemy, damage);
        game.effectManager.spawnDamageNumber(enemy.position, damage);
      }
    }
  }

  void _fireBounce(ActiveWeapon weapon, ToemalokGame game, double damage, double speed, Element elem, int extraAmount, int extraPierce, {bool homing = false}) {
    final player = game.player;
    final data = weapon.data;

    for (int i = 0; i < data.amount + extraAmount; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.projectileManager.spawn(
        weaponId: weapon.weaponId,
        position: player.position.clone(),
        velocity: vel,
        damage: damage,
        pierce: data.pierce + extraPierce,
        area: 28,
        size: 14,
        element: elem,
        homing: homing,
      );
    }
  }

  void _fireChase(ActiveWeapon weapon, ToemalokGame game, double damage, double speed, Element elem, int extraAmount, int extraPierce) {
    final player = game.player;
    final data = weapon.data;
    final enemies = game.enemyManager.activeEnemies;

    for (int i = 0; i < data.amount + extraAmount; i++) {
      Vector2 vel;
      if (enemies.isNotEmpty) {
        final target = enemies[_rng.nextInt(enemies.length)];
        vel = (target.position - player.position).normalized() * speed;
      } else {
        vel = player.facingDirection * speed;
      }
      final proj = game.projectileManager.spawn(
        weaponId: weapon.weaponId,
        position: player.position.clone(),
        velocity: vel,
        damage: damage,
        maxLifetime: data.duration,
        area: 24,
        size: 10,
        element: elem,
      );
      proj.homing = true;
    }
  }

  void reset() {
    weapons.clear();
  }
}
