import 'dart:math';
import 'package:flame/components.dart';
import '../../data/enemies.dart';
import '../../utils/tuning_params.dart';

enum EliteType {
  none,       // 일반
  tank,       // HP 3배, 크기 1.3배, 이속 0.7배
  swift,      // 이속 2배, 크기 0.8배
  splitter,   // 사망 시 2마리 분열
  explosive,  // 사망 시 주변 폭발
  vampiric,   // 접촉 시 HP 회복
}

/// 적 데이터 객체 — SpriteComponent 상속 금지, 순수 데이터
class EnemyInstance {
  EnemyType type = EnemyType.jabgwi;
  Vector2 position = Vector2.zero();
  double hp = 0;
  double maxHp = 0;
  double damage = 0;
  double speed = 0;
  double expDrop = 1;
  Element element = Element.none;
  double size = 36;
  bool isActive = false;
  int aiGroup = 0; // 0~4, AI 로테이션용
  Vector2 moveDir = Vector2.zero();
  double knockbackTimer = 0;
  Vector2 knockbackVelocity = Vector2.zero();
  double flashTimer = 0;
  double contactCooldown = 0; // 접촉 데미지 쿨다운
  double poisonTimer = 0;     // 독 지속 시간
  double poisonDamage = 0;    // 독 초당 데미지
  double slowTimer = 0;       // 슬로우 지속 시간
  double buffTimer = 0;       // 보스 buffAllies 지속 시간
  double _buffSpeedOrig = 0;
  double _buffDmgOrig = 0;

  // 엘리트 시스템
  EliteType eliteType = EliteType.none;
  bool get isElite => eliteType != EliteType.none;

  /// timeScale = 경과 분(minutes)
  void init(EnemyData data, Vector2 pos, double timeScale, int group) {
    type = data.type;
    position = pos.clone();
    maxHp = data.baseHp * (1 + timeScale * TuningParams.enemyHpScale);
    hp = maxHp;
    damage = data.baseDamage * (1 + timeScale * TuningParams.enemyDmgScale);
    final speedMulti = min(1 + timeScale * TuningParams.enemySpeedScale, TuningParams.enemySpeedCap);
    speed = data.baseSpeed * speedMulti;
    expDrop = data.expDrop;
    element = data.element;
    size = data.size;
    isActive = true;
    aiGroup = group;
    moveDir = Vector2.zero();
    knockbackTimer = 0;
    flashTimer = 0;
    contactCooldown = 0;
    poisonTimer = 0;
    poisonDamage = 0;
    slowTimer = 0;
    buffTimer = 0;
    eliteType = EliteType.none;
  }

  void applyBuff(double duration) {
    if (buffTimer > 0) return; // 이미 버프 중
    _buffSpeedOrig = speed;
    _buffDmgOrig = damage;
    speed *= 1.3;
    damage *= 1.2;
    buffTimer = duration;
  }

  void updateBuff(double dt) {
    if (buffTimer <= 0) return;
    buffTimer -= dt;
    if (buffTimer <= 0) {
      speed = _buffSpeedOrig;
      damage = _buffDmgOrig;
    }
  }

  /// 엘리트로 승격
  void promoteElite(EliteType elite) {
    eliteType = elite;
    switch (elite) {
      case EliteType.tank:
        hp *= 3;
        maxHp *= 3;
        size *= 1.3;
        speed *= 0.7;
        expDrop *= 3;
      case EliteType.swift:
        speed *= 2;
        size *= 0.8;
        expDrop *= 2;
      case EliteType.splitter:
        hp *= 1.5;
        maxHp *= 1.5;
        expDrop *= 2;
      case EliteType.explosive:
        hp *= 2;
        maxHp *= 2;
        damage *= 1.5;
        expDrop *= 2.5;
      case EliteType.vampiric:
        hp *= 2;
        maxHp *= 2;
        speed *= 1.2;
        expDrop *= 2;
      case EliteType.none:
        break;
    }
  }

  void reset() {
    isActive = false;
    hp = 0;
    position = Vector2.zero();
  }

  bool get isDead => hp <= 0;
}
