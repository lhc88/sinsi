import 'dart:math';
import '../../utils/tuning_params.dart';

/// 플레이어 스탯 관리
class PlayerStats {
  double maxHp;
  double currentHp;
  double hpRegen; // 초당
  double moveSpeed; // 배율
  double might; // 공격력 배율
  double projectileSpeed; // 투사체 배율
  double duration; // 지속 배율
  double area; // 범위 배율
  double cooldown; // 쿨다운 배율 (낮을수록 빠름)
  double pickupRange; // 수집 범위 px
  double luck; // 행운 %
  int level;
  double currentExp;
  double expToNext;
  int killCount;
  int revives;

  // 원소 시너지 보너스
  double synergyDamageBonus = 0.0;
  double synergyCooldownBonus = 0.0;
  double synergyExpBonus = 0.0;
  double synergyMoveSpeedBonus = 0.0;
  double synergyDefenseBonus = 0.0;
  double synergyAreaBonus = 0.0;

  // 스킬 트리 보너스 (런타임 효과용 플래그)
  double skillDamageBonus = 0.0; // 무기별 DMG 보너스
  int skillExtraPierce = 0;
  double skillExtraArea = 0.0;
  double skillCritChance = 0.0;
  double skillCritDamage = 0.0;
  double skillLifesteal = 0.0;
  double skillDamageReduction = 0.0;
  double skillExpDropBonus = 0.0;
  double skillGoldDropBonus = 0.0;
  int skillExtraChoices = 0; // 레벨업 선택지 추가
  double skillCounterMultiplier = 0.0; // 상극 배율 추가

  // 스킬 트리 런타임 효과 플래그
  bool skillSplitOnPierce = false;     // 이태양 1-3: 관통 시 분열
  double skillExtraIFrames = 0.0;      // 이태양 2-1: 피격 시 추가 무적
  bool skillDeathExplosion = false;     // 이태양 2-3: 사망 시 폭발
  bool skillAutoMagnet = false;        // 이태양 3-3: 30초 자석
  bool skillSlowOnHit = false;         // 월희 1-2: 방울 슬로우
  bool skillHealOnLevelUp = false;     // 월희 2-2: 레벨업 HP 회복
  bool skillAutoHealBurst = false;     // 월희 2-3: HP 30% 이하 회복 버스트
  double skillExpGemDmgBonus = 0.0;    // 월희 3-2: 대량 수집 시 DMG 버프
  bool skillScreenCollect = false;     // 월희 3-3: 60초마다 전체 수집
  bool skillKnockbackImmune = false;   // 철웅 1-2: 넉백 면역
  bool skillConditionalDefense = false;// 철웅 2-2: HP 50% 이하 방어 2배
  bool skillLastStand = false;         // 철웅 2-3: HP 1로 버티기
  bool _lastStandUsed = false;
  bool skillPushEnemies = false;       // 철웅 3-2: 이동 중 적 밀어내기
  bool skillChargeDash = false;        // 철웅 3-3: 5초마다 돌진
  bool skillCritStealth = false;       // 소연 1-3: 치명타 시 은신
  bool skillCritPenalty = false;       // 일일 도전: 비치명타 0.5배
  bool healBlocked = false;            // 일일 도전: 회복 완전 차단
  double skillStealthTimer = 0.0;
  double skillEvasionChance = 0.0;     // 소연 2-2: 회피 확률
  bool skillDash = false;              // 소연 2-3: 3초마다 대시
  bool skillPoisonOnHit = false;       // 소연 3-1: 독 부여
  double skillPoisonDamage = 0.0;      // 소연 3-2: 독 DMG 보너스
  bool skillPoisonExplode = false;     // 소연 3-3: 독 사망 시 폭발
  double skillKnockbackBonus = 0.0;    // 법운 1-1: 넉백 +50%
  bool skillTripleShot = false;        // 법운 1-2: 3방향
  bool skillBarrier = false;           // 법운 1-3: 주변 방어막
  bool skillReviveInvincible = false;  // 법운 2-2: 부활 시 무적 5초
  bool skillReviveExplosion = false;   // 법운 2-3: 부활 시 전체 공격
  bool skillStandingHealBoost = false; // 법운 3-2: 정지 시 회복 3배
  bool skillFullHpDmgBonus = false;    // 법운 3-3: HP 풀 시 DMG +30%
  bool skillChainExplosion = false;    // 단비 1-2: 연쇄 폭발 20%
  bool skillExplosionSlow = false;     // 단비 1-3: 폭발 슬로우
  bool skillKillCoolReset = false;     // 단비 2-2: 킬 10마리 쿨 리셋
  bool skillFrenzyMode = false;        // 단비 2-3: 광폭화 모드
  bool skillChestGradeUp = false;      // 단비 3-3: 상자 등급 +1
  bool skillShapeshift = false;        // 귀손 1-3: 변신
  double skillCounterDamage = 10.0;    // 귀손 2-1: 반격 DMG
  bool skillCounterKnockback = false;  // 귀손 2-2: 반격 넉백
  bool skillCounterAoe = false;        // 귀손 2-3: 반격 범위
  double skillLowHpSpeedBonus = 0.0;   // 귀손 3-1: HP 50% 이하 이속
  double skillLowHpDmgBonus = 0.0;     // 귀손 3-2: HP 30% 이하 DMG
  bool skillEmergencyInvincible = false;// 귀손 3-3: HP 10% 이하 무적
  bool _emergencyUsed = false;
  int skillExtraProjectiles = 0;       // 천무 1-1: 투사체 +4
  bool skillProjectileHoming = false;  // 천무 1-3: 투사체 추적
  bool skillDoubleSynergy = false;     // 천무 2-3: 시너지 2배
  bool skillPeriodicBurst = false;     // 천무 3-3: 60초마다 전무기 발동

  // 런타임 쿨다운
  double _dashCooldown = 0;
  double _chargeCooldown = 0;
  double _shapeshiftTimer = 0;
  double _frenzyTimer = 0;
  double _screenCollectCooldown = 0;
  double _periodicBurstCooldown = 0;
  int _killsSinceCoolReset = 0;
  double _autoHealBurstCooldown = 0;
  bool get isShapeshifted => _shapeshiftTimer > 0;
  bool get isFrenzy => _frenzyTimer > 0;
  bool get isStealthed => skillStealthTimer > 0;

  // 결과 화면 통계
  double totalDamageDealt = 0;
  double totalDamageTaken = 0;
  int bestKillStreak = 0;

  PlayerStats({
    this.maxHp = 100,
    this.currentHp = 100,
    this.hpRegen = 0.0,
    this.moveSpeed = 1.0,
    this.might = 1.0,
    this.projectileSpeed = 1.0,
    this.duration = 1.0,
    this.area = 1.0,
    this.cooldown = 1.0,
    this.pickupRange = 64,
    this.luck = 0,
    this.level = 1,
    this.currentExp = 0,
    this.expToNext = 15,
    this.killCount = 0,
    this.revives = 0,
  });

  // 비선형 EXP 곡선: 초반 빠른 레벨업, 후반 둔화
  double get expRequired => TuningParams.expBase + level * TuningParams.expPerLevel + level * level * 0.5;

  bool addExp(double amount) {
    currentExp += amount * (1 + synergyExpBonus);
    if (currentExp >= expToNext) {
      currentExp -= expToNext;
      level++;
      expToNext = expRequired;
      return true; // 레벨업!
    }
    return false;
  }

  void takeDamage(double rawDamage) {
    // 회피 판정
    if (skillEvasionChance > 0 && _rng.nextDouble() < skillEvasionChance) {
      return; // 회피 성공
    }

    // 방어력 적용 (시너지 방어 보너스 포함)
    double reduction = (skillDamageReduction + synergyDefenseBonus).clamp(0.0, 0.8);
    // 철웅 2-2: HP 50% 이하 방어 2배
    if (skillConditionalDefense && hpPercent < 0.5) {
      reduction = (reduction * 2).clamp(0.0, 0.9);
    }
    final damage = rawDamage * (1.0 - reduction);
    totalDamageTaken += damage;
    currentHp = (currentHp - damage).clamp(0, maxHp);

    // 반격 데미지 (귀손)
    if (skillCounterDamage > 10) {
      _pendingCounterDamage = skillCounterDamage;
    }

    // 철웅 2-3: HP 1로 버티기
    if (currentHp <= 0 && skillLastStand && !_lastStandUsed) {
      currentHp = 1;
      _lastStandUsed = true;
    }

    // 귀손 3-3: HP 10% 이하 무적 (1회)
    if (skillEmergencyInvincible && !_emergencyUsed && hpPercent < 0.1) {
      _emergencyUsed = true;
      _pendingEmergencyInvincible = true;
    }
  }

  double _pendingCounterDamage = 0;
  bool _pendingEmergencyInvincible = false;

  /// 반격 데미지가 있으면 반환 후 리셋
  double consumeCounterDamage() {
    final d = _pendingCounterDamage;
    _pendingCounterDamage = 0;
    return d;
  }

  /// 긴급 무적 트리거 확인
  bool consumeEmergencyInvincible() {
    final v = _pendingEmergencyInvincible;
    _pendingEmergencyInvincible = false;
    return v;
  }

  void heal(double amount) {
    if (healBlocked) return;
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  bool get isDead => currentHp <= 0;

  double get hpPercent => currentHp / maxHp;
  double get expPercent => currentExp / expToNext;

  /// 킬 카운트 증가 + 쿨 리셋 체크
  void onKill() {
    killCount++;
    if (skillKillCoolReset) {
      _killsSinceCoolReset++;
      if (_killsSinceCoolReset >= 10) {
        _killsSinceCoolReset = 0;
        _pendingCoolReset = true;
      }
    }
  }

  bool _pendingCoolReset = false;
  bool consumeCoolReset() {
    final v = _pendingCoolReset;
    _pendingCoolReset = false;
    return v;
  }

  /// 프레임마다 호출: 런타임 타이머 갱신
  void updateSkillTimers(double dt) {
    if (skillStealthTimer > 0) skillStealthTimer -= dt;
    if (_dashCooldown > 0) _dashCooldown -= dt;
    if (_chargeCooldown > 0) _chargeCooldown -= dt;
    if (_shapeshiftTimer > 0) _shapeshiftTimer -= dt;
    if (_frenzyTimer > 0) _frenzyTimer -= dt;
    if (_screenCollectCooldown > 0) _screenCollectCooldown -= dt;
    if (_periodicBurstCooldown > 0) _periodicBurstCooldown -= dt;
    if (_autoHealBurstCooldown > 0) _autoHealBurstCooldown -= dt;

    // 귀손 3-1: HP 50% 이하 이속 보너스 (조건부, 매 프레임)
    // → moveSpeed는 기본값에 매 프레임 적용하면 누적이므로 게임 루프에서 별도 처리

    // 월희 2-3: HP 30% 이하 자동 회복 버스트
    if (skillAutoHealBurst && hpPercent < 0.3 && _autoHealBurstCooldown <= 0) {
      heal(maxHp * 0.3);
      _autoHealBurstCooldown = 30; // 30초 쿨다운
    }

    // 법운 3-2: 정지 시 회복 3배 (게임 루프에서 이동 체크 후 호출)
  }

  /// 대시 사용 가능 여부
  bool canDash() => skillDash && _dashCooldown <= 0;
  void useDash() => _dashCooldown = 3;

  /// 돌진 사용 가능 여부
  bool canCharge() => skillChargeDash && _chargeCooldown <= 0;
  void useCharge() => _chargeCooldown = 5;

  /// 변신 활성화
  void activateShapeshift() {
    _shapeshiftTimer = 30;
  }

  /// 광폭화 활성화
  void activateFrenzy() {
    _frenzyTimer = 15;
  }

  /// 화면 전체 수집 사용 가능 여부
  bool canScreenCollect() => skillScreenCollect && _screenCollectCooldown <= 0;
  void useScreenCollect() => _screenCollectCooldown = 60;

  /// 전무기 추가 발동 사용 가능 여부
  bool canPeriodicBurst() => skillPeriodicBurst && _periodicBurstCooldown <= 0;
  void usePeriodicBurst() => _periodicBurstCooldown = 60;

  /// 현재 공격력 배율 (조건부 보너스 포함)
  double get effectiveMight {
    double m = might;
    if (skillFullHpDmgBonus && hpPercent >= 0.99) m *= 1.3;
    if (skillLowHpDmgBonus > 0 && hpPercent < 0.3) m *= (1 + skillLowHpDmgBonus);
    if (isShapeshifted) m *= 1.3;
    if (isFrenzy) m *= 1.5;
    if (skillExpGemDmgBonus > 0) m *= (1 + skillExpGemDmgBonus);
    return m;
  }

  /// 현재 이동속도 배율 (조건부 보너스 포함)
  double get effectiveMoveSpeed {
    double s = moveSpeed * (1 + synergyMoveSpeedBonus);
    if (skillLowHpSpeedBonus > 0 && hpPercent < 0.5) s *= (1 + skillLowHpSpeedBonus);
    if (isShapeshifted) s *= 1.3;
    return s;
  }

  /// 현재 HP 회복 (조건부 보너스 포함)
  double effectiveHpRegen(bool isStanding) {
    if (healBlocked) return 0;
    double r = hpRegen;
    if (skillStandingHealBoost && isStanding) r *= 3;
    return r;
  }

  final _rng = Random();
}
