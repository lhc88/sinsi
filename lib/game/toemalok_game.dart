import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter/services.dart' show HapticFeedback;
import 'dart:ui';
import '../components/effects/background_renderer.dart';
import '../components/player/player.dart';
import '../components/enemies/enemy_manager.dart';
import '../components/enemies/boss.dart';
import '../components/projectiles/projectile_manager.dart';
import '../components/items/exp_gem_manager.dart';
import '../components/items/treasure_chest.dart';
import '../components/items/destructible_manager.dart';
import '../components/weapons/weapon_manager.dart';
import '../components/effects/effect_manager.dart';
import '../systems/wave_spawner.dart';
import '../systems/collision_system.dart';
import '../systems/level_up_system.dart';
import '../systems/evolution_system.dart';
import '../systems/elemental_system.dart';
import '../systems/event_system.dart';
import '../data/bosses.dart';
import '../data/characters.dart';
import '../data/cosmetics.dart';
import '../data/daily_challenge.dart';
import '../data/evolutions.dart';
import '../data/game_modes.dart';
import '../data/stages.dart';
import '../utils/constants.dart';
import '../utils/tuning_params.dart';
import '../utils/sprite_loader.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';

class ToemalokGame extends FlameGame with HasCollisionDetection {
  final String characterId;
  final String stageId;
  final String modeId;
  final DailyChallengeData? dailyChallenge;
  late final GameModeData modeData;
  late Player player;
  late EnemyManager enemyManager;
  late ProjectileManager projectileManager;
  late ExpGemManager expGemManager;
  late WeaponManager weaponManager;
  late EffectManager effectManager;
  late WaveSpawner waveSpawner;
  late CollisionSystem collisionSystem;
  late LevelUpSystem levelUpSystem;
  late EvolutionSystem evolutionSystem;
  late EventSystem eventSystem;
  late DestructibleManager destructibleManager;

  // 활성 보스 목록
  final List<Boss> activeBosses = [];
  // 상자
  final List<TreasureChest> activeChests = [];

  late StageData _stageData;
  double gameTime = 0;
  double stageDuration = 1800;
  bool isPaused = false;
  bool isGameOver = false;
  bool isVictory = false;
  bool isLevelingUp = false;

  // 결과 화면 표시용 (1회 계산)
  int lastCoinsEarned = 0;
  int lastDoryeokEarned = 0;

  // 일일 도전 카운터
  int _dcEliteKills = 0;
  int _dcBossKills = 0;
  int _dcBossRushSpawned = 0; // bossRush 모드 스폰된 보스 수

  // 업적 알림 큐
  final List<String> achievementQueue = [];

  // 신기록 플래그 (결과 화면에서 표시)
  bool isNewBestTime = false;
  bool isNewBestKills = false;

  double _hitStopTimer = 0;
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  Vector2 _shakeOffset = Vector2.zero();
  double _bossKillSlowMo = 0;
  double _bossKillSlowScale = 1.0;

  // 저승사자 (시간 초과 무적 추적자)
  bool _reaperActive = false;
  final Vector2 _reaperPos = Vector2.zero();
  static const double _reaperSpeed = 120; // px/s
  static const double _reaperDamage = 9999;
  double _reaperHitCooldown = 0;

  // 스테이지 클리어 알림
  String? stageNotification;
  double _notificationTimer = 0;
  bool _warningSent = false;

  late JoystickComponent joystick;

  ToemalokGame({
    this.characterId = 'lee_taeyang',
    this.stageId = 'stage1',
    this.modeId = 'normal',
    this.dailyChallenge,
  });

  /// 표시용 시간 (역행 모드일 때 카운트다운)
  double get displayTime => modeData.reverseTimer ? (stageDuration - gameTime).clamp(0, stageDuration) : gameTime;

  /// 시간역행 약화 배율 (1.0→0.5 선형 감소)
  double get reverseTimerMultiplier {
    if (!modeData.reverseTimer || !stageDuration.isFinite) return 1.0;
    final remaining = (stageDuration - gameTime) / stageDuration;
    return 0.5 + 0.5 * remaining.clamp(0.0, 1.0);
  }
  int get gameMinutes => (displayTime / 60).floor();
  int get gameSeconds => (displayTime % 60).floor();
  String get gameTimeString =>
      '${gameMinutes.toString().padLeft(2, '0')}:${gameSeconds.toString().padLeft(2, '0')}';

  @override
  Future<void> onLoad() async {
    // 스프라이트 에셋 로드
    await SpriteLoader.instance.loadAll();

    world = World();
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: 800,
      height: 480,
    );

    world.add(BackgroundRenderer());

    player = Player(characterId: characterId);
    world.add(player);

    enemyManager = EnemyManager();
    projectileManager = ProjectileManager();
    expGemManager = ExpGemManager();
    weaponManager = WeaponManager();
    effectManager = EffectManager();
    destructibleManager = DestructibleManager();
    world.add(enemyManager);
    world.add(projectileManager);
    world.add(expGemManager);
    world.add(effectManager);
    world.add(destructibleManager);

    // 스테이지 데이터로 WaveSpawner 초기화
    _stageData = stageTable[stageId] ?? stage1;
    final stageData = _stageData;
    stageDuration = stageData.duration;
    waveSpawner = WaveSpawner(stage: stageData);

    // 끝없는 밤 모드: 무한 시간
    if (modeId == 'muhan') stageDuration = double.infinity;
    collisionSystem = CollisionSystem();
    levelUpSystem = LevelUpSystem();
    evolutionSystem = EvolutionSystem();
    eventSystem = EventSystem();
    eventSystem.init(stageDuration);

    final knobPaint = Paint()..color = const Color(0x88FFFFFF);
    final bgPaint = Paint()..color = const Color(0x44FFFFFF);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 24, paint: knobPaint),
      background: CircleComponent(radius: 56, paint: bgPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);
    camera.follow(player, maxSpeed: 1000, snap: true);

    // 캐릭터 스탯 적용
    final charData = characterTable[characterId];
    if (charData != null) {
      player.stats.maxHp = charData.baseHp;
      player.stats.currentHp = charData.baseHp;
      player.stats.might = charData.baseMight;
      player.stats.moveSpeed = charData.baseSpeed;
      player.stats.cooldown = charData.baseCooldown;
      player.stats.area = charData.baseArea;
      player.stats.pickupRange = charData.basePickupRange;
      weaponManager.addWeapon(charData.startWeapon);
    } else {
      weaponManager.addWeapon('toema_bujeok');
    }

    // 게임 모드 배율 적용
    modeData = gameModeTable[modeId] ?? gameModeTable['normal']!;
    player.stats.moveSpeed *= modeData.speedMultiplier;
    player.stats.projectileSpeed *= modeData.projSpeedMultiplier;

    // 영구 파워업 적용
    _applyPowerUps();
    // 스킬 트리 보너스 적용
    _applySkillTreeBonuses();

    // 일일 도전 규칙 적용
    if (dailyChallenge != null) {
      _applyDailyChallengeRules(dailyChallenge!.rule);
      // 시간 기반 도전은 10분, 특수 조건 도전은 15분 제한
      final rule = dailyChallenge!.rule;
      if (rule == DailyChallengeRule.speedRun) {
        stageDuration = 900; // 15분
      } else if (rule == DailyChallengeRule.bossRush) {
        stageDuration = 1200; // 20분 (보스 3체 등장 필요)
      } else if (rule == DailyChallengeRule.eliteHunter) {
        stageDuration = 900; // 15분 내 엘리트 10마리
      } else {
        stageDuration = 600; // 10분 생존 기반
      }
    }

    overlays.add('hud');

    // 튜토리얼 (첫 플레이 시)
    if (!SaveService.instance.tutorialDone) {
      overlays.add('tutorial');
    }

    // BGM — 스테이지별
    AudioService.playBgm(_stageData.bgm);
  }

  void recalculateSynergy() {
    final prevCount = activeSynergyNames.length;
    final elements = weaponManager.weapons
        .map((w) => w.info.element)
        .toList();
    final bonus = ElementalSystem.calculateSynergy(elements);
    final synergyMulti = player.stats.skillDoubleSynergy ? 2.0 : 1.0;
    player.stats.synergyDamageBonus = (bonus.globalDamageBonus + bonus.counterBonus) * synergyMulti;
    player.stats.synergyCooldownBonus = bonus.cooldownReduction * synergyMulti;
    player.stats.synergyExpBonus = bonus.expBonus * synergyMulti;
    player.stats.synergyMoveSpeedBonus = bonus.moveSpeedBonus * synergyMulti;
    player.stats.synergyDefenseBonus = bonus.defenseBonus * synergyMulti;
    player.stats.synergyAreaBonus = bonus.areaBonus * synergyMulti;
    activeSynergyNames = bonus.activeNames;

    // 새 시너지 활성 시 이펙트
    if (activeSynergyNames.length > prevCount) {
      triggerScreenFlash(const Color(0x334ECDC4), 0.3);
      effectManager.spawnExplosion(player.position, 100);
      _showNotification('시너지 발동! ${activeSynergyNames.last}');
    }
  }

  /// 현재 활성 시너지 이름 목록 (UI 표시용)
  List<String> activeSynergyNames = [];

  void _applyPowerUps() {
    final save = SaveService.instance;
    final s = player.stats;
    s.might += save.getPowerUpLevel('pu_might') * 0.05;
    s.maxHp += save.getPowerUpLevel('pu_hp') * 10;
    s.currentHp = s.maxHp;
    s.moveSpeed += save.getPowerUpLevel('pu_speed') * 0.05;
    s.pickupRange += save.getPowerUpLevel('pu_pickup') * 0.1 * s.pickupRange;
    s.cooldown -= save.getPowerUpLevel('pu_cooldown') * 0.05;
    s.luck += save.getPowerUpLevel('pu_luck') * 5;
    s.revives += save.getPowerUpLevel('pu_revive');
    s.area += save.getPowerUpLevel('pu_area') * 0.05;

    // 환생(프레스티지) 영구 보너스
    s.might += save.prestigeDamageBonus;
    s.maxHp += save.prestigeHpBonus;
    s.currentHp = s.maxHp;
  }

  void _applySkillTreeBonuses() {
    final save = SaveService.instance;
    final s = player.stats;
    final charData = characterTable[characterId];
    if (charData == null) return;

    for (int pathIdx = 0; pathIdx < charData.skillTree.length; pathIdx++) {
      final level = save.getSkillLevel(characterId, pathIdx);
      if (level <= 0) continue;

      switch (characterId) {
        case 'lee_taeyang':
          switch (pathIdx) {
            case 0: // 퇴마의 불꽃
              if (level >= 1) s.skillDamageBonus += 0.15;
              if (level >= 2) s.skillExtraPierce += 1;
              if (level >= 3) s.skillSplitOnPierce = true;
            case 1: // 수호의 결계
              if (level >= 1) s.skillExtraIFrames = 1.0;
              if (level >= 2) s.skillDamageReduction += 0.30;
              if (level >= 3) { s.revives += 1; s.skillDeathExplosion = true; }
            case 2: // 기운 순환
              if (level >= 1) s.skillExpDropBonus += 0.10;
              if (level >= 2) s.skillExtraChoices += 1;
              if (level >= 3) s.skillAutoMagnet = true;
          }
        case 'wolhui':
          switch (pathIdx) {
            case 0: // 신내림
              if (level >= 1) s.skillExtraArea += 0.20;
              if (level >= 2) s.skillSlowOnHit = true;
              if (level >= 3) s.skillExtraPierce += 99;
            case 1: // 치유의 춤
              if (level >= 1) s.hpRegen += 0.3;
              if (level >= 2) s.skillHealOnLevelUp = true;
              if (level >= 3) s.skillAutoHealBurst = true;
            case 2: // 기운 폭풍
              if (level >= 1) s.pickupRange *= 1.2;
              if (level >= 2) s.skillExpGemDmgBonus = 0.15;
              if (level >= 3) s.skillScreenCollect = true;
          }
        case 'cheolwoong':
          switch (pathIdx) {
            case 0: // 무장의 힘
              if (level >= 1) s.skillDamageBonus += 0.20;
              if (level >= 2) s.skillKnockbackImmune = true;
              if (level >= 3) s.skillExtraArea += 0.40;
            case 1: // 철벽
              if (level >= 1) s.skillDamageReduction += 0.10;
              if (level >= 2) s.skillConditionalDefense = true;
              if (level >= 3) s.skillLastStand = true;
            case 2: // 진군
              if (level >= 1) s.moveSpeed *= 1.10;
              if (level >= 2) s.skillPushEnemies = true;
              if (level >= 3) s.skillChargeDash = true;
          }
        case 'soyeon':
          switch (pathIdx) {
            case 0: // 암살
              if (level >= 1) s.skillCritChance += 0.10;
              if (level >= 2) s.skillCritDamage += 0.50;
              if (level >= 3) s.skillCritStealth = true;
            case 1: // 민첩
              if (level >= 1) s.moveSpeed *= 1.15;
              if (level >= 2) s.skillEvasionChance = 0.10;
              if (level >= 3) s.skillDash = true;
            case 2: // 독
              if (level >= 1) s.skillPoisonOnHit = true;
              if (level >= 2) s.skillPoisonDamage = 0.30;
              if (level >= 3) s.skillPoisonExplode = true;
          }
        case 'beopwoon':
          switch (pathIdx) {
            case 0: // 금강
              if (level >= 1) s.skillKnockbackBonus = 0.50;
              if (level >= 2) s.skillTripleShot = true;
              if (level >= 3) s.skillBarrier = true;
            case 1: // 자비
              if (level >= 1) s.revives += 1;
              if (level >= 2) s.skillReviveInvincible = true;
              if (level >= 3) s.skillReviveExplosion = true;
            case 2: // 명상
              if (level >= 1) s.hpRegen += 0.5;
              if (level >= 2) s.skillStandingHealBoost = true;
              if (level >= 3) s.skillFullHpDmgBonus = true;
          }
        case 'danbi':
          switch (pathIdx) {
            case 0: // 신명
              if (level >= 1) s.skillExtraArea += 0.30;
              if (level >= 2) s.skillChainExplosion = true;
              if (level >= 3) s.skillExplosionSlow = true;
            case 1: // 흥
              if (level >= 1) s.cooldown *= 0.90;
              if (level >= 2) s.skillKillCoolReset = true;
              if (level >= 3) s.skillFrenzyMode = true;
            case 2: // 축제
              if (level >= 1) s.skillExpDropBonus += 0.15;
              if (level >= 2) s.skillGoldDropBonus += 0.20;
              if (level >= 3) s.skillChestGradeUp = true;
          }
        case 'gwison':
          switch (pathIdx) {
            case 0: // 요기
              if (level >= 1) s.cooldown *= 0.80;
              if (level >= 2) s.skillLifesteal += 0.05;
              if (level >= 3) s.skillShapeshift = true;
            case 1: // 반격
              if (level >= 1) s.skillCounterDamage = 30;
              if (level >= 2) s.skillCounterKnockback = true;
              if (level >= 3) s.skillCounterAoe = true;
            case 2: // 야성
              if (level >= 1) s.skillLowHpSpeedBonus = 0.20;
              if (level >= 2) s.skillLowHpDmgBonus = 0.30;
              if (level >= 3) s.skillEmergencyInvincible = true;
          }
        case 'cheonmoo':
          switch (pathIdx) {
            case 0: // 도술
              if (level >= 1) s.skillExtraProjectiles = 4;
              if (level >= 2) s.skillExtraPierce += 2;
              if (level >= 3) s.skillProjectileHoming = true;
            case 1: // 오행
              if (level >= 1) s.skillDamageBonus += 0.10;
              if (level >= 2) s.skillCounterMultiplier += 0.5;
              if (level >= 3) s.skillDoubleSynergy = true;
            case 2: // 영적 수련
              if (level >= 1) s.duration *= 1.15;
              if (level >= 2) s.cooldown *= 0.90;
              if (level >= 3) s.skillPeriodicBurst = true;
          }
      }
    }

    if (s.cooldown < 0.2) s.cooldown = 0.2;
    s.area += s.skillExtraArea;
  }

  @override
  void update(double dt) {
    if (isPaused || isGameOver || isVictory || isLevelingUp) return;

    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
      return;
    }

    AudioService.resetFrameThrottle();

    // 보스 처치 슬로모션
    if (_bossKillSlowMo > 0) {
      _bossKillSlowMo -= dt;
      dt *= _bossKillSlowScale;
    }

    super.update(dt);
    gameTime += dt;

    // 알림 타이머
    if (_notificationTimer > 0) {
      _notificationTimer -= dt;
      if (_notificationTimer <= 0) stageNotification = null;
    }

    // 잔여 30초 경고
    if (stageDuration.isFinite && !_warningSent && gameTime >= stageDuration - 30) {
      _warningSent = true;
      _showNotification('최종 퇴마 시간! 30초 남았습니다!');
    }

    // 승리 조건 체크 (끝없는 밤 모드는 승리 없음)
    if (stageDuration.isFinite && gameTime >= stageDuration && !_reaperActive) {
      onVictory();
      return;
    }

    // 저승사자 업데이트
    if (_reaperActive) {
      _updateReaper(dt);
    }

    // 보스 러시: 2분, 6분, 10분에 보스 강제 스폰
    if (dailyChallenge?.rule == DailyChallengeRule.bossRush && _dcBossRushSpawned < 3) {
      const bossRushTimes = [120.0, 360.0, 600.0];
      if (gameTime >= bossRushTimes[_dcBossRushSpawned] && activeBosses.isEmpty) {
        const bossIds = ['dokkaebi_daejang', 'gumiho', 'jangsanbeom'];
        spawnBoss(bossIds[_dcBossRushSpawned]);
        _dcBossRushSpawned++;
      }
    }

    // 조이스틱
    if (joystick.delta.length > TuningParams.joystickDeadZone) {
      player.moveDirection = joystick.relativeDelta;
    } else {
      player.moveDirection = Vector2.zero();
    }

    // 카메라 위치를 렌더러에 전달 (화면 밖 컬링용)
    final camPos = camera.viewfinder.position;
    enemyManager.updateCamera(camPos.x, camPos.y);
    projectileManager.updateCamera(camPos.x, camPos.y);
    projectileManager.setEnemiesRef(enemyManager.activeEnemies);
    expGemManager.updateCamera(camPos.x, camPos.y);
    destructibleManager.updateCamera(camPos.x, camPos.y);

    eventSystem.update(dt, this);
    if (!eventSystem.isSpawnPaused) {
      waveSpawner.update(dt, this);
    }
    weaponManager.update(dt, this);
    collisionSystem.updateTimers(dt);
    collisionSystem.update(this, dt);

    // 스킬트리 런타임 효과
    _updateSkillTreeRuntime(dt);

    // 보스-투사체 충돌
    _updateBossCollisions();

    // 상자 수집
    _updateChestPickup();

    // BGM 동적 강도
    AudioService.updateBgmIntensity(
      enemyManager.activeEnemies.length,
      activeBosses.isNotEmpty,
    );

    // 마일스톤 체크
    _checkMilestones();

    // 화면 필 이펙트
    if (_screenFlashTimer > 0) {
      _screenFlashTimer -= dt;
    }

    // 화면 흔들림
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final progress = _shakeTimer / TuningParams.shakeDuration;
      final seed = (gameTime * 1000).toInt();
      _shakeOffset = Vector2(
        (seed % 100 - 50) / 50 * _shakeIntensity * progress,
        (seed % 73 - 36) / 36 * _shakeIntensity * progress,
      );
      // 카메라에 흔들림 적용
      camera.viewfinder.position = player.position + _shakeOffset;
    } else if (_shakeOffset.length > 0) {
      _shakeOffset = Vector2.zero();
      camera.viewfinder.position = player.position;
    }
  }

  void _updateBossCollisions() {
    for (final boss in activeBosses.toList()) {
      if (boss.isDead) {
        _onBossKilled(boss);
        continue;
      }
      // 투사체-보스 충돌
      for (final proj in projectileManager.activeProjectiles.toList()) {
        if (!proj.isActive) continue;
        if (proj.position.distanceTo(boss.position) < boss.data.size / 2 + proj.area) {
          if (boss.isInvincible) {
            // 무적 상태: 투사체만 소모
            proj.hitCount++;
            if (proj.hitCount > proj.pierce) {
              projectileManager.killProjectile(proj);
            }
            continue;
          }
          var elemMulti = ElementalSystem.getMultiplier(proj.element, boss.data.element);
          if (elemMulti > 1.0) {
            elemMulti = modeData.counterMultiplier + player.stats.skillCounterMultiplier;
          }
          final skillMulti = 1.0 + player.stats.skillDamageBonus;
          final synergyMulti = 1.0 + player.stats.synergyDamageBonus;
          final dmg = proj.damage * player.stats.effectiveMight * elemMulti * skillMulti * synergyMulti;
          boss.takeDamage(dmg);
          effectManager.spawnDamageNumber(boss.position, dmg);
          proj.hitCount++;
          if (proj.hitCount > proj.pierce) {
            projectileManager.killProjectile(proj);
          }
        }
      }
    }
  }

  void _onBossKilled(Boss boss) {
    activeBosses.remove(boss);
    world.remove(boss);
    player.stats.killCount++;
    _dcBossKills++;
    _checkDailyChallengeCompletion();

    // 슬로모션 연출 (0.5초간 게임 속도 20%)
    _bossKillSlowMo = 0.5;
    _bossKillSlowScale = 0.2;

    // 강력한 화면 흔들림
    triggerScreenShake(15, 0.6);

    // 대형 폭발 이펙트 (다중)
    effectManager.spawnExplosion(boss.position, boss.data.size * 1.5);
    effectManager.spawnDeathEffect(boss.position, boss.data.size * 2);
    // 추가 파티클 폭발
    for (int i = 0; i < 3; i++) {
      final offset = Vector2(
        (_hitStopTimer * 100 + i * 37) % 80 - 40,
        (_hitStopTimer * 100 + i * 53) % 80 - 40,
      );
      effectManager.spawnDeathEffect(boss.position + offset, boss.data.size);
    }

    // 히트스톱
    triggerHitStop(0.15);

    // 햅틱 피드백 (강)
    HapticFeedback.heavyImpact();

    // 보스 처치 알림
    _showNotification('${boss.data.name} 퇴치!');

    // 보스 모두 처치 시 일반 BGM 복귀
    if (activeBosses.isEmpty) {
      AudioService.playBgm(_stageData.bgm);
    }
    SaveService.instance.discover(boss.data.id);

    // 보물상자 드롭
    final grade = chestGradeFromString(boss.data.dropChest);
    spawnChest(boss.position, grade);

    // 경험치 보너스 (방사형으로 기운 산개)
    for (int i = 0; i < 8; i++) {
      final angle = 2 * 3.14159 * i / 8;
      final offset = Vector2(cos(angle), sin(angle)) * 40;
      expGemManager.spawnGem(boss.position + offset, 5);
    }
  }

  void spawnBoss(String bossId) {
    final data = bossTable[bossId];
    if (data == null) return;

    final boss = Boss(data: data, gameTimeMinutes: gameTime / 60);
    boss.position = player.position + Vector2(400, 0);
    activeBosses.add(boss);
    world.add(boss);

    triggerScreenShake(6, 0.3);
    AudioService.bossAppear();
    AudioService.playBgm(_stageData.bossBgm);
    HapticFeedback.mediumImpact();
    // 보스 등장 슬로모션 (0.8초간 30%)
    _bossKillSlowMo = 0.8;
    _bossKillSlowScale = 0.3;
    _showNotification('${data.name} 출현!');
  }

  void spawnChest(Vector2 position, ChestGrade grade) {
    final chest = TreasureChest(grade: grade, pos: position);
    activeChests.add(chest);
    world.add(chest);
  }

  void _updateChestPickup() {
    for (final chest in activeChests.toList()) {
      if (chest.isOpened) continue;
      if (player.position.distanceTo(chest.position) < 40) {
        chest.isOpened = true;
        _openChest(chest);
      }
    }
  }

  void _openChest(TreasureChest chest) {
    AudioService.chestOpen();
    HapticFeedback.lightImpact();
    // 상자 열기 연출
    effectManager.spawnExplosion(chest.position, 60 + chest.grade.index * 20.0);
    triggerScreenShake(3 + chest.grade.index.toDouble(), 0.15);
    // 단비 3-3: 상자 등급 +1
    if (player.stats.skillChestGradeUp && chest.grade.index < ChestGrade.dragon.index) {
      chest.grade = ChestGrade.values[chest.grade.index + 1];
    }
    // 상자 카운트 추적
    SaveService.instance.addChestCount();
    // 진화 체크
    final evolutions = evolutionSystem.getAvailableEvolutions(weaponManager, levelUpSystem);
    if (evolutions.isNotEmpty && chest.maxEvolutions > 0) {
      evolutionSystem.evolve(evolutions.first.id, weaponManager);
      triggerScreenShake(10, 0.5);
      triggerHitStop(0.8);
      triggerScreenFlash(const Color(0x66FFD166), 0.5);
      _bossKillSlowMo = 0.8; // 슬로모션
      _bossKillSlowScale = 0.15;
      effectManager.spawnExplosion(player.position, 150);
      _showNotification('무기 진화!');
      AudioService.evolution();
      recalculateSynergy();
    }

    // 합체 체크
    final unions = evolutionSystem.getAvailableUnions(weaponManager);
    if (unions.isNotEmpty && chest.grade.index >= ChestGrade.gold.index) {
      evolutionSystem.unite(unions.first.id, weaponManager);
      triggerScreenShake(10, 0.4);
      triggerHitStop(0.6);
      AudioService.evolution();
      recalculateSynergy();
    }

    // 업그레이드 보너스 (등급별, TuningParams 참조)
    final upgradeCount = switch (chest.grade) {
      ChestGrade.wood => 0,
      ChestGrade.iron => TuningParams.chestUpgradeIron,
      ChestGrade.gold => TuningParams.chestUpgradeGold,
      ChestGrade.jade => TuningParams.chestUpgradeJade,
      ChestGrade.dragon => TuningParams.chestUpgradeDragon,
    };
    for (int i = 0; i < upgradeCount; i++) {
      final w = weaponManager.weapons.where((w) => !w.isMaxLevel).firstOrNull;
      if (w != null) weaponManager.upgradeWeapon(w.weaponId);
    }

    // 상자 제거
    activeChests.remove(chest);
    world.remove(chest);
  }

  double _magnetCooldown = 0;

  void _updateSkillTreeRuntime(double dt) {
    final s = player.stats;
    s.updateSkillTimers(dt);

    // 자석 자동 발동 (이태양 3-3)
    if (s.skillAutoMagnet) {
      _magnetCooldown -= dt;
      if (_magnetCooldown <= 0) {
        _magnetCooldown = 30;
        expGemManager.collectAllOnScreen(player.position, 600);
      }
    }

    // 화면 전체 수집 (월희 3-3)
    if (s.canScreenCollect()) {
      s.useScreenCollect();
      expGemManager.collectAllOnScreen(player.position, 2000);
    }

    // 전무기 추가 발동 (천무 3-3)
    if (s.canPeriodicBurst()) {
      s.usePeriodicBurst();
      weaponManager.update(0, this); // 추가 1회 발동
    }

    // 소연 대시 (3초마다)
    if (s.canDash()) {
      final dir = player.facingDirection;
      if (player.moveDirection.length > 0.01) {
        s.useDash();
        player.position += dir * 120;
        player.setInvincible(0.3);
      }
    }

    // 철웅 돌진 (5초마다)
    if (s.canCharge()) {
      s.useCharge();
      final dir = player.facingDirection;
      player.position += dir * 200;
      player.setInvincible(0.5);
      triggerScreenShake(4, 0.2);
      // 돌진 경로 적에게 데미지
      for (final enemy in enemyManager.activeEnemies) {
        if (!enemy.isActive) continue;
        if (enemy.position.distanceTo(player.position) < 80) {
          enemyManager.applyDamage(enemy, s.effectiveMight * 30);
        }
      }
    }

    // 철웅 이동 중 적 밀어내기
    if (s.skillPushEnemies && player.moveDirection.length > 0.01) {
      for (final enemy in enemyManager.activeEnemies) {
        if (!enemy.isActive) continue;
        final dist = enemy.position.distanceTo(player.position);
        if (dist < 50) {
          final push = (enemy.position - player.position).normalized() * 3;
          enemy.position += push;
        }
      }
    }

    // 반격 데미지 처리
    final counterDmg = s.consumeCounterDamage();
    if (counterDmg > 0) {
      final range = s.skillCounterAoe ? 200.0 : 60.0;
      for (final enemy in enemyManager.activeEnemies) {
        if (!enemy.isActive) continue;
        if (enemy.position.distanceTo(player.position) < range) {
          enemyManager.applyDamage(enemy, counterDmg);
          if (s.skillCounterKnockback) {
            final push = (enemy.position - player.position).normalized() * 80;
            enemy.position += push;
          }
        }
      }
    }

    // 긴급 무적 (귀손 3-3)
    if (s.consumeEmergencyInvincible()) {
      player.setInvincible(3.0);
    }

    // 무기 쿨 리셋 (단비 2-2)
    if (s.consumeCoolReset()) {
      for (final w in weaponManager.weapons) {
        w.cooldownTimer = 0;
      }
    }

    // 법운 방어막 (1-3): 주변 적 데미지
    if (s.skillBarrier) {
      for (final enemy in enemyManager.activeEnemies) {
        if (!enemy.isActive) continue;
        if (enemy.position.distanceTo(player.position) < 80) {
          enemyManager.applyDamage(enemy, 5 * dt);
        }
      }
    }

    // 시너지 2배 (천무 2-3)
    if (s.skillDoubleSynergy) {
      s.synergyDamageBonus = s.synergyDamageBonus.clamp(0, 10); // 이미 recalculate에서 설정됨, 여기서 2배
    }
  }

  void _showNotification(String text) {
    stageNotification = text;
    _notificationTimer = 3.0;
  }

  /// 외부 시스템에서 호출 가능한 알림
  void notify(String text) => _showNotification(text);

  // ──── 저승사자 시스템 ────
  /// 저승사자 소환 (무적 추적자, 시간 초과 페널티)
  void spawnReaper() {
    if (_reaperActive) return;
    _reaperActive = true;
    // 화면 밖에서 등장
    _reaperPos.setFrom(player.position + Vector2(500, 0));
    _showNotification('저승사자 출현!');
    triggerScreenShake(10, 0.5);
    AudioService.bossAppear();
  }

  void _updateReaper(double dt) {
    // 플레이어를 향해 일정 속도로 추적
    final dir = player.position - _reaperPos;
    if (dir.length > 5) {
      _reaperPos.add(dir.normalized() * _reaperSpeed * dt);
    }

    _reaperHitCooldown -= dt;

    // 접촉 시 즉사급 데미지
    if (dir.length < 40 && _reaperHitCooldown <= 0) {
      player.onHit(_reaperDamage);
      _reaperHitCooldown = 1.0;
      if (player.stats.isDead) {
        onPlayerDeath();
      }
    }
  }

  /// 저승사자 활성 여부 (HUD 미니맵 표시용)
  bool get isReaperActive => _reaperActive;
  Vector2 get reaperPosition => _reaperPos;

  void triggerHitStop(double duration) {
    _hitStopTimer = duration;
  }

  void triggerScreenShake([double? intensity, double? duration]) {
    _shakeIntensity = intensity ?? TuningParams.shakeIntensity;
    _shakeTimer = duration ?? TuningParams.shakeDuration;
  }

  // ──────── 마일스톤 시스템 ────────
  final Set<int> _killMilestones = {};
  final Set<int> _timeMilestones = {};

  void _checkMilestones() {
    final kills = player.stats.killCount;
    final minutes = (gameTime / 60).floor();

    // 킬 마일스톤
    for (final threshold in [100, 500, 1000, 2000, 5000]) {
      if (kills >= threshold && !_killMilestones.contains(threshold)) {
        _killMilestones.add(threshold);
        _showNotification('$threshold 처치 달성!');
        triggerScreenFlash(const Color(0x44FFD166));
        triggerScreenShake(5, 0.3);
        AudioService.milestone();
      }
    }

    // 시간 마일스톤
    for (final min in [5, 10, 15, 20, 25]) {
      if (minutes >= min && !_timeMilestones.contains(min)) {
        _timeMilestones.add(min);
        _showNotification('$min분 생존!');
        triggerScreenFlash(const Color(0x4400FF88));
        AudioService.milestone();
      }
    }
  }

  // ──────── 화면 필 이펙트 ────────
  double _screenFlashTimer = 0;
  Color _screenFlashColor = const Color(0x00000000);

  void triggerScreenFlash(Color color, [double duration = 0.3]) {
    _screenFlashColor = color;
    _screenFlashTimer = duration;
  }

  // ──────── 대량 처치 슬로우 ────────
  void triggerMassKillSlowMo() {
    if (_bossKillSlowMo <= 0) {
      _bossKillSlowMo = 0.2;
      _bossKillSlowScale = 0.4;
    }
  }

  /// HUD에서 화면 필 이펙트 읽기용
  Color? get screenFlashColor =>
      _screenFlashTimer > 0 ? _screenFlashColor : null;
  double get screenFlashAlpha =>
      _screenFlashTimer > 0 ? (_screenFlashTimer / 0.3).clamp(0.0, 1.0) : 0;

  void onPlayerLevelUp() {
    isLevelingUp = true;
    overlays.add('levelUp');
    AudioService.levelUp();
    HapticFeedback.lightImpact();
    triggerScreenFlash(const Color(0x227EC850), 0.2);
    effectManager.spawnExplosion(player.position, 80);

    // 월희 2-2: 레벨업 시 HP 20% 회복
    if (player.stats.skillHealOnLevelUp) {
      player.stats.heal(player.stats.maxHp * 0.2);
    }
  }

  void onLevelUpChoiceMade() {
    isLevelingUp = false;
    overlays.remove('levelUp');
    recalculateSynergy();
  }

  void onPlayerDeath() {
    // 부활 체크
    if (player.stats.revives > 0) {
      player.stats.revives--;
      player.stats.currentHp = player.stats.maxHp;
      // 법운 2-2: 부활 시 무적 5초 (기본 3초보다 길게)
      player.setInvincible(player.stats.skillReviveInvincible ? 5.0 : 3.0);
      // 법운 2-3: 부활 시 화면 전체 공격
      if (player.stats.skillReviveExplosion) {
        for (final enemy in enemyManager.activeEnemies) {
          if (!enemy.isActive) continue;
          enemyManager.applyDamage(enemy, player.stats.effectiveMight * 50);
          effectManager.spawnDamageNumber(enemy.position, 50);
        }
        effectManager.spawnExplosion(player.position, 400);
        triggerScreenShake(12, 0.5);
      }
      // 이태양 2-3: 사망 시 폭발
      if (player.stats.skillDeathExplosion) {
        for (final enemy in enemyManager.activeEnemies) {
          if (!enemy.isActive) continue;
          if (enemy.position.distanceTo(player.position) < 200) {
            enemyManager.applyDamage(enemy, 100);
          }
        }
        effectManager.spawnExplosion(player.position, 200);
        triggerScreenShake(8, 0.3);
      }
      return;
    }
    isGameOver = true;
    _saveEndResults(victoryBonus: false);
    overlays.add('gameOver');
    AudioService.stopBgm();
  }

  void _applyDailyChallengeRules(DailyChallengeRule rule) {
    switch (rule) {
      case DailyChallengeRule.survivalHard:
        // 적 이속 1.5배
        // wave_spawner에서 modeData.enemySpeedMultiplier 활용
        // 여기서는 직접 적 이속 배율 설정
        break;
      case DailyChallengeRule.noHeal:
        player.stats.hpRegen = 0;
        player.stats.healBlocked = true;
        player.stats.skillHealOnLevelUp = false;
        player.stats.skillAutoHealBurst = false;
      case DailyChallengeRule.lowHp:
        player.stats.maxHp = (player.stats.maxHp * 0.5).round().toDouble();
        player.stats.currentHp = player.stats.maxHp;
      case DailyChallengeRule.critOnly:
        player.stats.skillCritPenalty = true; // 비치명타 0.5배
      default:
        break;
    }
  }

  void onEliteKilled() {
    _dcEliteKills++;
    _checkDailyChallengeCompletion();
  }

  void _checkDailyChallengeCompletion() {
    if (dailyChallenge == null || isVictory || isGameOver) return;
    final rule = dailyChallenge!.rule;
    bool completed = false;
    switch (rule) {
      case DailyChallengeRule.speedRun:
        completed = _dcBossKills >= 1;
      case DailyChallengeRule.eliteHunter:
        completed = _dcEliteKills >= 10;
      case DailyChallengeRule.bossRush:
        completed = _dcBossKills >= 3;
      default:
        return; // 시간 기반은 onVictory에서 처리
    }
    if (completed) onVictory();
  }

  /// 일일 도전 진행도 (HUD 표시용)
  String? get dailyChallengeProgress {
    if (dailyChallenge == null) return null;
    return switch (dailyChallenge!.rule) {
      DailyChallengeRule.speedRun => '보스 처치 $_dcBossKills/1',
      DailyChallengeRule.eliteHunter => '엘리트 처치 $_dcEliteKills/10',
      DailyChallengeRule.bossRush => '보스 처치 $_dcBossKills/3',
      _ => null,
    };
  }

  /// 일일 도전 적 이속 배율
  double get dailyChallengeEnemySpeed =>
      dailyChallenge?.rule == DailyChallengeRule.survivalHard ? 1.5 : 1.0;

  void onVictory() {
    isVictory = true;
    _saveEndResults(victoryBonus: true);
    overlays.add('victory');
    AudioService.stopBgm();

    // 다음 스테이지 해금
    final save = SaveService.instance;
    const stageOrder = ['stage1', 'stage2', 'stage3', 'stage4', 'stage5'];
    final idx = stageOrder.indexOf(stageId);
    if (idx >= 0 && idx < stageOrder.length - 1) {
      save.unlockStage(stageOrder[idx + 1]);
    }
    // 보너스 스테이지 해금 (스테이지3 클리어 시 bonus1, 스테이지5 시 bonus2)
    if (stageId == 'stage3') save.unlockStage('bonus1');
    if (stageId == 'stage5') save.unlockStage('bonus2');

    // 게임 모드 해금
    // 광란: 아무 스테이지 클리어
    save.unlockMode('gwangran');
    // 무한: 광란 모드로 클리어
    if (modeId == 'gwangran') save.unlockMode('muhan');
    // 귀문: 무한 모드 20분 이상 생존
    if (modeId == 'muhan' && gameTime >= 1200) save.unlockMode('gwimun');
    // 역행: 귀문 모드 클리어
    if (modeId == 'gwimun') save.unlockMode('yeokhaeng');
  }

  void _saveEndResults({required bool victoryBonus}) {
    final save = SaveService.instance;
    final goldBonus = (1.0 + save.getPowerUpLevel('pu_gold') * 0.1) * modeData.goldMultiplier;
    final multiplier = victoryBonus ? 1.5 : 1.0;
    lastCoinsEarned = (player.stats.killCount * TuningParams.baseGoldPerKill * goldBonus * multiplier * (1.0 + player.stats.skillGoldDropBonus)).round();
    lastDoryeokEarned = victoryBonus ? 5 : (gameTime > 300 ? 2 : 1); // 패배: 5분 이상 2, 미만 1

    save.coins = save.coins + lastCoinsEarned;
    save.doryeok = save.doryeok + lastDoryeokEarned;
    save.totalKills = save.totalKills + player.stats.killCount;
    save.totalRuns = save.totalRuns + 1;
    // 신기록 체크
    isNewBestTime = gameTime > save.bestTime;
    isNewBestKills = player.stats.killCount > save.bestKills;
    if (isNewBestTime) save.bestTime = gameTime;
    if (isNewBestKills) save.bestKills = player.stats.killCount;
    final newAchievements = save.checkAchievements();
    achievementQueue.addAll(newAchievements);

    // 일일 도전 보상 지급
    if (dailyChallenge != null && victoryBonus) {
      final today = DateTime.now();
      final dateStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      if (!save.isDailyChallengeCompleted(dateStr)) {
        save.completeDailyChallenge(dateStr);
        save.coins = save.coins + dailyChallenge!.rewardCoins;
        save.soulStones = save.soulStones + dailyChallenge!.rewardSoulStones;
        lastCoinsEarned += dailyChallenge!.rewardCoins;
        _showNotification('일일 도전 완료! +${dailyChallenge!.rewardCoins} 엽전');
      }
    }

    // 캐릭터 자동 해금 체크
    _checkCharacterUnlocks(save);
    // 스킨 자동 해금 체크
    _checkSkinUnlocks(save);
  }

  void _checkCharacterUnlocks(SaveService save) {
    // 월희: 기본 해금
    save.unlockCharacter('wolhui');
    // 철웅: 스테이지 1 클리어
    if (stageId == 'stage1') save.unlockCharacter('cheolwoong');
    // 법운: 스테이지 2 클리어
    if (stageId == 'stage2') save.unlockCharacter('beopwoon');
    // 소연: 적 1000마리 처치 (누적)
    if (save.totalKills >= 1000) save.unlockCharacter('soyeon');
    // 단비: 상자 50개 (누적)
    if (save.chestCount >= 50) save.unlockCharacter('danbi');
    // 귀손: 도깨비 대장 처치
    if (save.discoveredEntries.contains('dokkaebi_daejang')) save.unlockCharacter('gwison');
    // 천무: 무기 5종 진화 (발견 목록에서 진화 무기 수 카운트)
    final evoCount = save.discoveredEntries
        .where((id) => evolutionTable.containsKey(id))
        .length;
    if (evoCount >= 5) save.unlockCharacter('cheonmoo');
  }

  void _checkSkinUnlocks(SaveService save) {
    for (final skin in skinTable.values) {
      if (save.isSkinUnlocked(skin.id)) continue;
      if (skin.unlockType == SkinUnlockType.defaultSkin) {
        save.unlockSkin(skin.id);
        continue;
      }
      bool unlocked = false;
      switch (skin.unlockType) {
        case SkinUnlockType.killCount:
          unlocked = save.totalKills >= (int.tryParse(skin.unlockParam ?? '') ?? 9999);
        case SkinUnlockType.stageComplete:
          unlocked = save.isStageUnlocked(skin.unlockParam ?? '');
        case SkinUnlockType.achievement:
          unlocked = save.isAchievementDone(skin.unlockParam ?? '');
        case SkinUnlockType.prestige:
          unlocked = save.prestigeLevel >= (int.tryParse(skin.unlockParam ?? '') ?? 9999);
        case SkinUnlockType.defaultSkin:
          unlocked = true;
      }
      if (unlocked) {
        save.unlockSkin(skin.id);
        _showNotification('스킨 해금: ${skin.name}');
      }
    }
  }

  void pauseGame() {
    isPaused = true;
    overlays.add('pause');
    AudioService.pauseBgm();
  }

  void resumeGame() {
    isPaused = false;
    overlays.remove('pause');
    AudioService.resumeBgm();
  }

  void restartGame() {
    isGameOver = false;
    isVictory = false;
    isPaused = false;
    isLevelingUp = false;
    lastCoinsEarned = 0;
    lastDoryeokEarned = 0;
    gameTime = 0;
    stageNotification = null;
    _notificationTimer = 0;
    _warningSent = false;
    achievementQueue.clear();
    overlays.remove('gameOver');
    overlays.remove('victory');
    overlays.remove('pause');
    overlays.remove('levelUp');

    player.stats.currentHp = player.stats.maxHp;
    player.stats.level = 1;
    player.stats.currentExp = 0;
    player.stats.expToNext = player.stats.expRequired;
    player.stats.killCount = 0;
    player.position = Vector2(worldWidth / 2, worldHeight / 2);

    // 보스/상자 제거
    for (final b in activeBosses) {
      world.remove(b);
    }
    activeBosses.clear();
    for (final c in activeChests) {
      world.remove(c);
    }
    activeChests.clear();

    enemyManager.clearAll();
    projectileManager.clearAll();
    expGemManager.clearAll();
    destructibleManager.clearAll();
    weaponManager.reset();
    levelUpSystem.reset();
    weaponManager.addWeapon('toema_bujeok');
    waveSpawner.reset();
  }
}
