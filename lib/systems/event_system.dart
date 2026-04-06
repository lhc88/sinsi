import 'dart:math';
import 'package:flame/components.dart';
import '../components/items/treasure_chest.dart';
import '../data/enemies.dart';
import '../game/toemalok_game.dart';

/// 특수 이벤트 타입
enum SpecialEventType {
  goldenWave,    // 황금 웨이브: 기운 드롭 3배, 화면에 금빛 틴트
  eliteRush,     // 엘리트 러시: 강한 적 몰려옴 (보상 UP)
  bonusTime,     // 보너스 타임: 경험치 2배, 스폰 중단
  treasureRain,  // 보물비: 상자 여러 개 출현
}

class _ScheduledEvent {
  final double triggerTime; // 초
  final SpecialEventType type;
  final double duration;
  bool triggered = false;

  _ScheduledEvent({
    required this.triggerTime,
    required this.type,
    required this.duration,
  });
}

class EventSystem {
  final Random _rng = Random();
  final List<_ScheduledEvent> _scheduled = [];

  SpecialEventType? activeEvent;
  double eventTimer = 0;
  double eventDuration = 0;

  // 이벤트 보너스 배율
  double get expMultiplier =>
      activeEvent == SpecialEventType.bonusTime ? 2.0 : 1.0;
  double get gemDropMultiplier =>
      activeEvent == SpecialEventType.goldenWave ? 3.0 : 1.0;
  bool get isSpawnPaused =>
      activeEvent == SpecialEventType.bonusTime;

  /// 스테이지 시작 시 이벤트 스케줄 생성
  void init(double stageDuration) {
    _scheduled.clear();
    activeEvent = null;
    eventTimer = 0;

    if (stageDuration.isInfinite) {
      // 끝없는 밤: 3분마다 랜덤 이벤트
      for (double t = 180; t < 3600; t += 150 + _rng.nextDouble() * 60) {
        _scheduled.add(_ScheduledEvent(
          triggerTime: t,
          type: _randomEventType(),
          duration: _eventDuration(_randomEventType()),
        ));
      }
    } else {
      // 일반 스테이지: 2분, 5분, 8분, 12분, 20분 근처
      final times = [120.0, 300.0, 480.0, 720.0, 1200.0];
      for (final t in times) {
        if (t < stageDuration - 60) { // 끝 1분 전까지만
          final type = _randomEventType();
          _scheduled.add(_ScheduledEvent(
            triggerTime: t + _rng.nextDouble() * 30 - 15,
            type: type,
            duration: _eventDuration(type),
          ));
        }
      }
    }
  }

  SpecialEventType _randomEventType() {
    final types = SpecialEventType.values;
    return types[_rng.nextInt(types.length)];
  }

  double _eventDuration(SpecialEventType type) => switch (type) {
    SpecialEventType.goldenWave => 15.0,
    SpecialEventType.eliteRush => 12.0,
    SpecialEventType.bonusTime => 10.0,
    SpecialEventType.treasureRain => 5.0,
  };

  String eventName(SpecialEventType type) => switch (type) {
    SpecialEventType.goldenWave => '황금 웨이브!',
    SpecialEventType.eliteRush => '엘리트 러시!',
    SpecialEventType.bonusTime => '보너스 타임!',
    SpecialEventType.treasureRain => '보물비!',
  };

  void update(double dt, ToemalokGame game) {
    final time = game.gameTime;

    // 예약 이벤트 체크
    for (final e in _scheduled) {
      if (!e.triggered && time >= e.triggerTime && activeEvent == null) {
        e.triggered = true;
        _startEvent(e.type, e.duration, game);
      }
    }

    // 활성 이벤트 타이머
    if (activeEvent != null) {
      eventTimer -= dt;
      if (eventTimer <= 0) {
        _endEvent(game);
      }
    }
  }

  void _startEvent(SpecialEventType type, double duration, ToemalokGame game) {
    activeEvent = type;
    eventTimer = duration;
    eventDuration = duration;

    game.notify(eventName(type));
    game.triggerScreenShake(6, 0.3);

    switch (type) {
      case SpecialEventType.goldenWave:
        // 골든 적 추가 스폰
        for (int i = 0; i < 15; i++) {
          final pos = _randomOffscreenPos(game);
          game.enemyManager.spawnEnemy(
            EnemyType.dokkaebiJol, pos, game.gameTime / 60);
        }

      case SpecialEventType.eliteRush:
        // 강한 적 웨이브
        final eliteTypes = [EnemyType.yacha, EnemyType.gapotGwisin, EnemyType.gangsi];
        for (int i = 0; i < 8; i++) {
          final pos = _randomOffscreenPos(game);
          final type = eliteTypes[_rng.nextInt(eliteTypes.length)];
          game.enemyManager.spawnEnemy(type, pos, game.gameTime / 60,
              speedMultiplier: 1.3);
        }

      case SpecialEventType.bonusTime:
        // 기존 적 전부 처치 → 경험치 폭발
        for (final enemy in game.enemyManager.activeEnemies.toList()) {
          if (!enemy.isActive) continue;
          game.expGemManager.spawnGem(enemy.position, enemy.expDrop * 2);
          game.effectManager.spawnDeathEffect(enemy.position, enemy.size);
          game.enemyManager.killEnemy(enemy);
        }

      case SpecialEventType.treasureRain:
        // 상자 3~5개 드롭
        final count = 3 + _rng.nextInt(3);
        for (int i = 0; i < count; i++) {
          final offset = Vector2(
            _rng.nextDouble() * 300 - 150,
            _rng.nextDouble() * 300 - 150,
          );
          game.spawnChest(game.player.position + offset,
              _rng.nextDouble() < 0.3 ? ChestGrade.gold : ChestGrade.iron);
        }
    }
  }

  void _endEvent(ToemalokGame game) {
    activeEvent = null;
    eventTimer = 0;
  }

  Vector2 _randomOffscreenPos(ToemalokGame game) {
    final playerPos = game.player.position;
    final side = _rng.nextInt(4);
    double x, y;
    switch (side) {
      case 0:
        x = playerPos.x + _rng.nextDouble() * 800 - 400;
        y = playerPos.y - 350;
      case 1:
        x = playerPos.x + _rng.nextDouble() * 800 - 400;
        y = playerPos.y + 350;
      case 2:
        x = playerPos.x - 450;
        y = playerPos.y + _rng.nextDouble() * 600 - 300;
      default:
        x = playerPos.x + 450;
        y = playerPos.y + _rng.nextDouble() * 600 - 300;
    }
    return Vector2(x, y);
  }

  void reset() {
    _scheduled.clear();
    activeEvent = null;
    eventTimer = 0;
  }
}
