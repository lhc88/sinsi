/// 파괴 가능 환경 오브젝트 (나무, 바위, 항아리, 등불)
enum DestructibleType { tree, rock, pot, lantern }

/// 풀링용 경량 인스턴스 (SpriteComponent 상속 금지)
class DestructibleInstance {
  DestructibleType type = DestructibleType.tree;
  double x = 0, y = 0;
  double hp = 0;
  double maxHp = 0;
  double size = 0;
  bool isActive = false;
  bool isDestroyed = false;

  void init(DestructibleType t, double px, double py) {
    type = t;
    x = px;
    y = py;
    maxHp = _maxHpFor(t);
    hp = maxHp;
    size = _sizeFor(t);
    isActive = true;
    isDestroyed = false;
  }

  void reset() {
    isActive = false;
    isDestroyed = false;
    hp = 0;
  }

  static double _maxHpFor(DestructibleType t) => switch (t) {
    DestructibleType.tree => 30,
    DestructibleType.rock => 60,
    DestructibleType.pot => 10,
    DestructibleType.lantern => 15,
  };

  static double _sizeFor(DestructibleType t) => switch (t) {
    DestructibleType.tree => 40,
    DestructibleType.rock => 36,
    DestructibleType.pot => 20,
    DestructibleType.lantern => 16,
  };

  /// 드롭 속성
  bool get dropsExp => type == DestructibleType.pot;
  bool get dropsHeal => type == DestructibleType.lantern;
  double get expDrop => 3;
  double get healAmount => 5;

  void takeDamage(double damage) {
    if (!isActive || isDestroyed) return;
    hp -= damage;
    if (hp <= 0) {
      hp = 0;
      isDestroyed = true;
    }
  }
}
