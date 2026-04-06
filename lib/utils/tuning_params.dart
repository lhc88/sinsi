/// 게임 필 튜닝 파라미터 — 디버그 패널에서 실시간 조절 가능
class TuningParams {
  // 화면 진동
  static double shakeIntensity = 4.0;
  static double shakeDuration = 0.15;

  // 히트스톱
  static double hitStopDuration = 0.03;
  static double bossHitStopDuration = 0.08;

  // 넉백
  static double knockbackForce = 120.0;
  static double knockbackDuration = 0.2;

  // 피격 플래시
  static double flashDuration = 0.05;

  // 데미지 숫자
  static double damageFloatSpeed = 60.0;
  static double damageFloatDuration = 0.8;

  // 기운 수집
  static double magnetSpeed = 350.0;
  static double magnetAccel = 800.0;

  // 레벨업
  static double levelUpSlowMo = 0.3;
  static double levelUpFlashIntensity = 0.7;

  // 카메라
  static double cameraLag = 0.1;
  static double bossZoomOut = 1.2;

  // 조이스틱
  static double joystickDeadZone = 0.15;
  static double moveSmoothing = 0.85;

  // ──────── 밸런스 스케일링 ────────

  // 적 HP: baseHp * (1 + minutes * enemyHpScale)
  static double enemyHpScale = 0.08;

  // 적 데미지: baseDmg * (1 + minutes * enemyDmgScale)
  static double enemyDmgScale = 0.06;

  // 적 이동속도: baseSpeed * (1 + minutes * enemySpeedScale) — 최대 cap
  static double enemySpeedScale = 0.018;
  static double enemySpeedCap = 1.8; // 최대 1.8배

  // 보스 HP: bossHp * (1 + stageMinutes * bossHpScale)
  static double bossHpScale = 0.04;

  // 플레이어 무적 시간 (피격 후)
  static double playerIFrameDuration = 0.5;

  // 적 접촉 데미지 쿨다운 (같은 적이 연속 데미지를 주는 간격)
  static double enemyContactCooldown = 0.5;

  // EXP 곡선: expRequired = expBase + level * expPerLevel
  static double expBase = 5.0;
  static double expPerLevel = 10.0;

  // 엽전 드롭: 적 사망 시 기본 드롭량 (엘리트 3배, 보스 50배 별도)
  static double baseGoldPerKill = 1.5;

  // 보물상자 무기 업그레이드 횟수 (등급별)
  static int chestUpgradeIron = 1;
  static int chestUpgradeGold = 1;
  static int chestUpgradeJade = 3;
  static int chestUpgradeDragon = 5;

  static void resetDefaults() {
    shakeIntensity = 4.0;
    shakeDuration = 0.15;
    hitStopDuration = 0.03;
    bossHitStopDuration = 0.08;
    knockbackForce = 120.0;
    knockbackDuration = 0.2;
    flashDuration = 0.05;
    damageFloatSpeed = 60.0;
    damageFloatDuration = 0.8;
    magnetSpeed = 350.0;
    magnetAccel = 800.0;
    levelUpSlowMo = 0.3;
    levelUpFlashIntensity = 0.7;
    cameraLag = 0.1;
    bossZoomOut = 1.2;
    joystickDeadZone = 0.15;
    moveSmoothing = 0.85;
    enemyHpScale = 0.08;
    enemyDmgScale = 0.06;
    enemySpeedScale = 0.018;
    enemySpeedCap = 1.8;
    bossHpScale = 0.04;
    playerIFrameDuration = 0.5;
    enemyContactCooldown = 0.5;
    expBase = 5.0;
    expPerLevel = 10.0;
    baseGoldPerKill = 1.5;
    chestUpgradeIron = 1;
    chestUpgradeGold = 1;
    chestUpgradeJade = 3;
    chestUpgradeDragon = 5;
  }
}
