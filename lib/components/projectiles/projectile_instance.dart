import 'package:flame/components.dart';
import '../../data/enemies.dart';

/// 투사체 데이터 객체 — SpriteComponent 상속 금지
class ProjectileInstance {
  String weaponId = '';
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  double damage = 0;
  double lifetime = 0;
  double maxLifetime = 3;
  double area = 16; // 충돌 반경
  int pierce = 0; // 관통 횟수 (0=충돌 시 소멸)
  int hitCount = 0;
  Element element = Element.none;
  bool isActive = false;
  double size = 12;

  // 특수 행동
  bool homing = false; // 유도
  bool returning = false; // 귀환
  Vector2? returnTarget; // 귀환 목적지

  void init({
    required String weapon,
    required Vector2 pos,
    required Vector2 vel,
    required double dmg,
    double maxLife = 3,
    double hitArea = 16,
    int pierceCount = 0,
    Element elem = Element.none,
    double sz = 12,
  }) {
    weaponId = weapon;
    position = pos.clone();
    velocity = vel.clone();
    damage = dmg;
    lifetime = 0;
    maxLifetime = maxLife;
    area = hitArea;
    pierce = pierceCount;
    hitCount = 0;
    element = elem;
    isActive = true;
    size = sz;
    homing = false;
    returning = false;
    returnTarget = null;
  }

  void reset() {
    isActive = false;
    lifetime = 0;
    hitCount = 0;
  }

  bool get isExpired => lifetime >= maxLifetime;
}
