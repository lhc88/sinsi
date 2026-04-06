import 'dart:math';
import 'dart:ui' show Color;
import 'package:flame/components.dart';
import '../components/enemies/enemy_instance.dart';
import '../components/items/destructible.dart';
import '../data/stages.dart';
import '../game/toemalok_game.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';

class WaveSpawner {
  final StageData stage;
  final Random _rng = Random();
  double _spawnAccumulator = 0;
  int _nextBossIndex = 0;
  int _lastWaveIndex = -1;
  double _destructibleTimer = 0;
  static const double _destructibleInterval = 8.0; // 8초마다 스폰

  WaveSpawner({this.stage = stage1});

  /// 최대 동시 활성 적 수
  static const int maxActiveEnemies = 200;

  void update(double dt, ToemalokGame game) {
    final time = game.gameTime;
    final minutes = time / 60;

    // 보스 체크
    if (_nextBossIndex < stage.bosses.length) {
      final boss = stage.bosses[_nextBossIndex];
      if (time >= boss.time) {
        _nextBossIndex++;
        game.spawnBoss(boss.bossId);
      }
    }

    // 적 상한 도달 시 스폰 중단
    if (game.enemyManager.activeEnemies.length >= maxActiveEnemies) return;

    // 현재 웨이브 찾기
    WaveEntry? currentWave;
    int currentWaveIndex = -1;
    for (int i = 0; i < stage.waves.length; i++) {
      final wave = stage.waves[i];
      if (time >= wave.startTime && time < wave.endTime) {
        currentWave = wave;
        currentWaveIndex = i;
        break;
      }
    }
    if (currentWave == null) return;

    // 웨이브 전환 감지 → 보너스 보상
    if (currentWaveIndex != _lastWaveIndex && _lastWaveIndex >= 0) {
      game.notify('웨이브 ${currentWaveIndex + 1} 시작!');
      game.triggerScreenFlash(const Color(0x2200AAFF), 0.3);
      AudioService.waveStart();
      // 이전 웨이브 클리어 보상: 기운 드롭
      for (int i = 0; i < 5; i++) {
        final offset = Vector2(
          _rng.nextDouble() * 100 - 50,
          _rng.nextDouble() * 100 - 50,
        );
        game.expGemManager.spawnGem(game.player.position + offset, 3);
      }
    }
    _lastWaveIndex = currentWaveIndex;

    // 스폰 공식: baseRate * (1 + minutes * 0.1) — 스케일링 완화
    final rate = currentWave.spawnRate * (1 + minutes * 0.1);
    _spawnAccumulator += rate * dt;

    while (_spawnAccumulator >= 1) {
      _spawnAccumulator -= 1;
      if (game.enemyManager.activeEnemies.length >= maxActiveEnemies) break;
      _spawnEnemy(game, currentWave, minutes);
    }

    // 파괴 오브젝트 스폰
    _destructibleTimer += dt;
    if (_destructibleTimer >= _destructibleInterval) {
      _destructibleTimer -= _destructibleInterval;
      _spawnDestructibles(game);
    }
  }

  void _spawnEnemy(ToemalokGame game, WaveEntry wave, double minutes) {
    // 랜덤 적 타입
    final type = wave.enemies[_rng.nextInt(wave.enemies.length)];

    // 화면 밖 랜덤 위치
    final pos = _randomOffscreenPosition(game.player.position);

    game.enemyManager.spawnEnemy(type, pos, minutes,
        speedMultiplier: game.modeData.enemySpeedMultiplier * game.dailyChallengeEnemySpeed);

    // 엘리트 승격 (3분 이후 5% → 10분 이후 10%)
    if (minutes >= 3) {
      final eliteChance = minutes >= 10 ? 0.10 : 0.05;
      if (_rng.nextDouble() < eliteChance) {
        final enemies = game.enemyManager.activeEnemies;
        if (enemies.isNotEmpty) {
          final last = enemies.last;
          final types = [EliteType.tank, EliteType.swift, EliteType.splitter, EliteType.explosive, EliteType.vampiric];
          last.promoteElite(types[_rng.nextInt(types.length)]);
          AudioService.eliteSpawn();
        }
      }
    }
  }

  Vector2 _randomOffscreenPosition(Vector2 playerPos) {
    // 화면 밖 테두리에서 스폰 (카메라 뷰 800x480 기준)
    final side = _rng.nextInt(4);
    final margin = 60.0;
    double x, y;

    switch (side) {
      case 0: // 위
        x = playerPos.x + _rng.nextDouble() * 900 - 450;
        y = playerPos.y - 300 - margin;
      case 1: // 아래
        x = playerPos.x + _rng.nextDouble() * 900 - 450;
        y = playerPos.y + 300 + margin;
      case 2: // 왼쪽
        x = playerPos.x - 450 - margin;
        y = playerPos.y + _rng.nextDouble() * 700 - 350;
      default: // 오른쪽
        x = playerPos.x + 450 + margin;
        y = playerPos.y + _rng.nextDouble() * 700 - 350;
    }

    // 월드 경계 클램프
    x = x.clamp(0, worldWidth);
    y = y.clamp(0, worldHeight);

    return Vector2(x, y);
  }

  void _spawnDestructibles(ToemalokGame game) {
    final dm = game.destructibleManager;
    final playerPos = game.player.position;
    // 플레이어 주변 200~500px 범위에 1~3개 스폰
    final count = 1 + _rng.nextInt(3);
    const types = DestructibleType.values;
    for (int i = 0; i < count; i++) {
      final type = types[_rng.nextInt(types.length)];
      final angle = _rng.nextDouble() * 2 * pi;
      final dist = 200 + _rng.nextDouble() * 300;
      final x = (playerPos.x + cos(angle) * dist).clamp(40.0, worldWidth - 40);
      final y = (playerPos.y + sin(angle) * dist).clamp(40.0, worldHeight - 40);
      dm.spawn(type, x, y);
    }
  }

  void reset() {
    _spawnAccumulator = 0;
    _nextBossIndex = 0;
    _lastWaveIndex = -1;
    _destructibleTimer = 0;
  }
}
