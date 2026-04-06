import 'dart:ui';
import 'package:flame/components.dart';
import 'exp_gem_instance.dart';
import '../../utils/object_pool.dart';
import '../../utils/tuning_params.dart';
import '../../utils/sprite_painter.dart';
import '../../utils/sprite_loader.dart';

class ExpGemManager extends Component with HasGameReference {
  late final ObjectPool<ExpGemInstance> pool;
  double _time = 0;

  ExpGemManager() {
    pool = ObjectPool<ExpGemInstance>(
      create: () => ExpGemInstance(),
      reset: (g) => g.reset(),
      initialSize: 500,
    );
  }

  /// 최대 활성 기운 수
  static const int maxActiveGems = 300;

  List<ExpGemInstance> get activeGems => pool.active;

  void spawnGem(Vector2 position, double expValue) {
    // 상한 도달 시 가장 오래된 기운 제거
    if (pool.active.length >= maxActiveGems) {
      final oldest = pool.active.first;
      oldest.isActive = false;
      pool.release(oldest);
    }
    final gem = pool.acquire();
    gem.init(position, expValue);
  }

  @override
  void update(double dt) {
    _time += dt;
  }

  void collectGem(ExpGemInstance gem) {
    gem.isActive = false;
    pool.release(gem);
  }

  void startCollecting(ExpGemInstance gem) {
    gem.isBeingCollected = true;
    gem.collectSpeed = TuningParams.magnetSpeed * 0.5;
  }

  void updateCollection(double dt, Vector2 playerPos) {
    for (final gem in pool.active.toList()) {
      if (!gem.isActive) continue;
      if (!gem.isBeingCollected) continue;

      gem.collectSpeed += TuningParams.magnetAccel * dt;
      final dir = playerPos - gem.position;
      if (dir.length < 8) {
        // 수집 완료 — 호출자가 경험치 추가 처리
        continue;
      }
      gem.position += dir.normalized() * gem.collectSpeed * dt;
    }
  }

  void collectAllOnScreen(Vector2 playerPos, double screenRadius) {
    for (final gem in pool.active) {
      if (!gem.isActive || gem.isBeingCollected) continue;
      if (gem.position.distanceTo(playerPos) < screenRadius) {
        startCollecting(gem);
      }
    }
  }

  void clearAll() {
    pool.releaseAll();
  }

  int _frameIndex = 0;
  double _frameTimer = 0;
  double _camX = 0, _camY = 0;

  void updateCamera(double camX, double camY) {
    _camX = camX;
    _camY = camY;
  }

  @override
  void render(Canvas canvas) {
    _frameTimer += 0.016;
    if (_frameTimer >= 0.25) {
      _frameTimer = 0;
      _frameIndex = (_frameIndex + 1) % 4;
    }

    final loader = SpriteLoader.instance;
    final hasSprite = loader.getImage('exp_gems') != null;

    for (final gem in pool.active) {
      if (!gem.isActive) continue;

      // 화면 밖 컬링
      if ((gem.position.x - _camX).abs() > 480 || (gem.position.y - _camY).abs() > 320) continue;

      if (hasSprite) {
        final spriteIndex = gem.tier * 4 + _frameIndex;
        final destSize = gem.size * 2;
        loader.drawFrame(canvas, 'exp_gems', spriteIndex,
            frameW: 16, frameH: 16,
            destX: gem.position.x - destSize / 2,
            destY: gem.position.y - destSize / 2,
            destW: destSize, destH: destSize);
      } else {
        SpritePainter.drawExpGem(canvas, gem.position.x, gem.position.y, gem.size, gem.tier, _time);
      }
    }
  }
}
