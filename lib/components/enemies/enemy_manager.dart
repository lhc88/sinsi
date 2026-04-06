import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'enemy_instance.dart' show EnemyInstance, EliteType;
import '../../data/enemies.dart';
import '../../utils/object_pool.dart';
import '../../utils/tuning_params.dart';
import '../../utils/sprite_painter.dart';
import '../../utils/sprite_loader.dart';

class EnemyManager extends Component with HasGameReference {
  late final ObjectPool<EnemyInstance> pool;
  int _currentAiFrame = 0;
  final Random _rng = Random();
  double _time = 0;

  EnemyManager() {
    pool = ObjectPool<EnemyInstance>(
      create: () => EnemyInstance(),
      reset: (e) => e.reset(),
      initialSize: 300,
    );
  }

  List<EnemyInstance> get activeEnemies => pool.active;

  void spawnEnemy(EnemyType type, Vector2 position, double gameTimeMinutes,
      {double speedMultiplier = 1.0}) {
    final data = enemyTable[type]!;
    final enemy = pool.acquire();
    enemy.init(data, position, gameTimeMinutes, _rng.nextInt(5));
    enemy.speed *= speedMultiplier;
  }

  @override
  void update(double dt) {
    _time += dt;
    _currentAiFrame = (_currentAiFrame + 1) % 5;

    final playerPos = (game as dynamic).player.position as Vector2;

    for (final enemy in pool.active.toList()) {
      if (!enemy.isActive) continue;

      // 넉백 처리
      if (enemy.knockbackTimer > 0) {
        enemy.knockbackTimer -= dt;
        enemy.position += enemy.knockbackVelocity * dt;
        continue;
      }

      // 화면 밖 적: 5프레임마다만 갱신
      final distToPlayer = enemy.position.distanceTo(playerPos);
      final isOffscreen = distToPlayer > 500; // 카메라 뷰 밖
      if (isOffscreen && enemy.aiGroup != _currentAiFrame) {
        continue; // 오프스크린이면 자기 AI 프레임에서만 갱신
      }

      // AI는 5그룹 로테이션
      if (enemy.aiGroup == _currentAiFrame) {
        _updateAi(enemy);
      }

      // 이동 (슬로우 적용)
      if (enemy.moveDir.length > 0) {
        final dtMulti = isOffscreen ? dt * 5 : dt;
        final slowMult = enemy.slowTimer > 0 ? 0.5 : 1.0;
        enemy.position += enemy.moveDir * enemy.speed * slowMult * dtMulti;
      }

      // 독 데미지 틱
      if (enemy.poisonTimer > 0) {
        enemy.poisonTimer -= dt;
        enemy.hp -= enemy.poisonDamage * dt;
      }

      // 타이머 감소
      if (enemy.flashTimer > 0) enemy.flashTimer -= dt;
      if (enemy.contactCooldown > 0) enemy.contactCooldown -= dt;
      if (enemy.slowTimer > 0) enemy.slowTimer -= dt;
      enemy.updateBuff(dt);
    }
  }

  void _updateAi(EnemyInstance enemy) {
    final playerPos = (game as dynamic).player.position as Vector2;
    final dir = playerPos - enemy.position;
    if (dir.length > 0) {
      enemy.moveDir = dir.normalized();
    }
  }

  void applyDamage(EnemyInstance enemy, double damage) {
    enemy.hp -= damage;
    enemy.flashTimer = TuningParams.flashDuration;

    // 넉백
    final playerPos = (game as dynamic).player.position as Vector2;
    final dir = enemy.position - playerPos;
    if (dir.length > 0) {
      enemy.knockbackVelocity = dir.normalized() * TuningParams.knockbackForce;
      enemy.knockbackTimer = TuningParams.knockbackDuration;
    }
  }

  void killEnemy(EnemyInstance enemy) {
    enemy.isActive = false;
    pool.release(enemy);
  }

  void clearAll() {
    pool.releaseAll();
  }

  int _frameIndex = 0;
  double _frameTimer = 0;

  // 화면 컬링용 캐시 (매 프레임 갱신)
  double _camX = 0, _camY = 0;
  static const double _cullMargin = 80; // 화면 밖 여유
  static const double _halfW = 400 + _cullMargin; // 800/2 + margin
  static const double _halfH = 240 + _cullMargin; // 480/2 + margin

  // HP바 Paint 재사용 (GC 방지)
  static final Paint _hpBgPaint = Paint()..color = const Color(0xFF333333);
  static final Paint _hpFillPaint = Paint()..color = const Color(0xFFE63946);

  void updateCamera(double camX, double camY) {
    _camX = camX;
    _camY = camY;
  }

  @override
  void render(Canvas canvas) {
    _frameTimer += 0.016;
    if (_frameTimer >= 0.2) {
      _frameTimer = 0;
      _frameIndex = (_frameIndex + 1) % 4;
    }

    final loader = SpriteLoader.instance;

    for (final enemy in pool.active) {
      if (!enemy.isActive) continue;

      final cx = enemy.position.x;
      final cy = enemy.position.y;

      // 화면 밖 컬링 — 렌더링 스킵
      if ((cx - _camX).abs() > _halfW || (cy - _camY).abs() > _halfH) continue;

      final flash = enemy.flashTimer > 0;
      final s = enemy.size;

      final imgName = SpriteLoader.enemyImageName(enemy.type.name);
      final hasSprite = loader.getImage(imgName) != null;

      if (hasSprite) {
        final destSize = s * 1.8;
        final destX = cx - destSize / 2;
        final destY = cy - destSize / 2;

        if (flash) {
          loader.drawFrameFlash(canvas, imgName, _frameIndex,
              frameW: 32, frameH: 32,
              destX: destX, destY: destY, destW: destSize, destH: destSize);
        } else {
          loader.drawFrame(canvas, imgName, _frameIndex,
              frameW: 32, frameH: 32,
              destX: destX, destY: destY, destW: destSize, destH: destSize);
        }
      } else {
        switch (enemy.type) {
          case EnemyType.jabgwi:
            SpritePainter.drawJabgwi(canvas, cx, cy, s, flash: flash, time: _time);
          case EnemyType.dokkaebiJol:
            SpritePainter.drawDokkaebiJol(canvas, cx, cy, s, flash: flash, time: _time);
          case EnemyType.cheonyeoGwisin:
            SpritePainter.drawCheonyeoGwisin(canvas, cx, cy, s, flash: flash, time: _time);
          case EnemyType.yacha:
            SpritePainter.drawGenericEnemy(canvas, cx, cy, s, enemyTable[enemy.type]!.color,
                flash: flash, time: _time, horns: 2);
          default:
            SpritePainter.drawGenericEnemy(canvas, cx, cy, s, enemyTable[enemy.type]!.color,
                flash: flash, time: _time, horns: 1);
        }
      }

      // 상태이상 시각화
      if (enemy.poisonTimer > 0) {
        // 독: 초록 파티클
        final poisonAlpha = (sin(_time * 6) * 0.2 + 0.3).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(cx, cy - s * 0.3), 3,
          Paint()..color = Color.fromRGBO(100, 255, 50, poisonAlpha));
      }
      if (enemy.slowTimer > 0) {
        // 슬로우: 파란 링
        canvas.drawCircle(Offset(cx, cy), s * 0.5,
          Paint()..color = const Color(0x334488FF)..style = PaintingStyle.stroke..strokeWidth = 2);
      }

      // 엘리트 오라
      if (enemy.isElite) {
        final eliteColor = switch (enemy.eliteType) {
          EliteType.tank => const Color(0x66FFD700),
          EliteType.swift => const Color(0x6600FFFF),
          EliteType.splitter => const Color(0x66FF00FF),
          EliteType.explosive => const Color(0x66FF4500),
          EliteType.vampiric => const Color(0x66FF0000),
          EliteType.none => const Color(0x00000000),
        };
        canvas.drawCircle(Offset(cx, cy), s * 0.8,
          Paint()..color = eliteColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }

      // HP바 (데미지 입은 경우에만)
      if (enemy.hp < enemy.maxHp) {
        final half = s / 2;
        final barWidth = s * 0.8;
        final hpRatio = enemy.hp / enemy.maxHp;
        final barY = cy - half - 6;

        canvas.drawRect(Rect.fromLTWH(cx - barWidth / 2, barY, barWidth, 4), _hpBgPaint);
        canvas.drawRect(Rect.fromLTWH(cx - barWidth / 2, barY, barWidth * hpRatio, 4), _hpFillPaint);
      }
    }
  }
}
