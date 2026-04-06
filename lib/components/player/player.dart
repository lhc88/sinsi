import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'player_stats.dart';
import '../../data/cosmetics.dart';
import '../../utils/constants.dart';
import '../../utils/tuning_params.dart';
import '../../utils/sprite_painter.dart';
import '../../utils/sprite_loader.dart';
import '../../services/audio_service.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../services/save_service.dart';

class Player extends PositionComponent {
  final String characterId;
  final PlayerStats stats = PlayerStats();
  late final Color skinTint;
  Vector2 moveDirection = Vector2.zero();
  Vector2 facingDirection = Vector2(1, 0); // 기본 오른쪽
  Vector2 _smoothedDirection = Vector2.zero();

  // 무적 타이머
  double _invincibleTimer = 0;
  bool get isInvincible => _invincibleTimer > 0;

  // 피격 플래시
  double _flashTimer = 0;

  // 디버프 타이머
  double slowTimer = 0;
  double _magnetTimer = 0; // 스킬: 자석 자동 발동

  // 애니메이션 시간
  double _animTime = 0;
  int _frameIndex = 0;
  double _frameTimer = 0;
  bool _isWalking = false;

  Player({this.characterId = 'lee_taeyang'}) : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(worldWidth / 2, worldHeight / 2);
    // 선택된 스킨의 tint 적용
    final selectedSkinId = SaveService.instance.getSelectedSkin(characterId);
    final skin = skinTable[selectedSkinId];
    skinTint = skin?.tint ?? const Color(0xFFFFFFFF);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 부드러운 이동
    _smoothedDirection = _smoothedDirection * TuningParams.moveSmoothing +
        moveDirection * (1 - TuningParams.moveSmoothing);

    final isMoving = _smoothedDirection.length > 0.01;
    if (isMoving) {
      facingDirection = _smoothedDirection.normalized();
      final slowMult = slowTimer > 0 ? 0.5 : 1.0;
      position += _smoothedDirection *
          stats.effectiveMoveSpeed *
          defaultPlayerSpeed *
          slowMult *
          dt;

      // 월드 경계
      position.x = position.x.clamp(32, worldWidth - 32);
      position.y = position.y.clamp(32, worldHeight - 32);
    }

    // HP 리젠 (법운 3-2: 정지 시 3배)
    final regen = stats.effectiveHpRegen(!isMoving);
    if (regen > 0 && stats.currentHp < stats.maxHp) {
      stats.heal(regen * dt);
    }

    // 타이머 감소
    if (_invincibleTimer > 0) _invincibleTimer -= dt;
    if (_flashTimer > 0) _flashTimer -= dt;
    if (slowTimer > 0) slowTimer -= dt;
    if (_magnetTimer > 0) _magnetTimer -= dt;

    // 애니메이션
    _isWalking = _smoothedDirection.length > 0.01;
    if (_isWalking) {
      _animTime += dt;
    }
    _frameTimer += dt;
    if (_frameTimer >= 0.15) {
      _frameTimer = 0;
      _frameIndex = (_frameIndex + 1) % 4;
    }
  }

  @override
  void render(Canvas canvas) {
    final loader = SpriteLoader.instance;
    final imgName = SpriteLoader.playerImageName(characterId);
    final hasSprite = loader.getImage(imgName) != null;

    if (hasSprite) {
      // 스프라이트 시트: 8프레임 (0-3 idle, 4-7 walk), 각 32x32
      final spriteFrame = _isWalking ? (_frameIndex + 4) : _frameIndex;
      final flipX = facingDirection.x < 0;

      // 스킨 tint (기본=흰색=변형 없음)
      final hasTint = skinTint != const Color(0xFFFFFFFF);
      if (hasTint) {
        canvas.saveLayer(Rect.fromLTWH(0, 0, 64, 64), Paint());
      }

      if (_flashTimer > 0) {
        loader.drawFrameFlash(canvas, imgName, spriteFrame,
            frameW: 32, frameH: 32,
            destX: 0, destY: 0, destW: 64, destH: 64,
            flipX: flipX);
      } else {
        loader.drawFrame(canvas, imgName, spriteFrame,
            frameW: 32, frameH: 32,
            destX: 0, destY: 0, destW: 64, destH: 64,
            flipX: flipX);
      }

      if (hasTint) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, 64, 64),
          Paint()..colorFilter = ColorFilter.mode(skinTint.withValues(alpha: 0.35), BlendMode.srcATop),
        );
        canvas.restore();
      }

      // 무적 실드
      if (isInvincible) {
        canvas.drawCircle(
          Offset(32, 32), 36,
          Paint()
            ..color = Color.fromRGBO(69, 123, 157, 0.25 + math.sin(_animTime * 10) * 0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    } else {
      // 폴백: Canvas 렌더링
      SpritePainter.drawPlayer(
        canvas, size.x / 2, size.y / 2, facingDirection.x,
        flash: _flashTimer > 0, invincible: isInvincible, animTime: _animTime,
      );
    }
  }

  void onHit(double damage) {
    if (isInvincible) return;
    if (stats.isStealthed) return; // 은신 중 피격 무효
    stats.takeDamage(damage);
    _flashTimer = TuningParams.flashDuration;
    _invincibleTimer = TuningParams.playerIFrameDuration + stats.skillExtraIFrames;
    AudioService.playSfx('player_hit');
    HapticFeedback.mediumImpact();
  }

  void setInvincible(double seconds) {
    _invincibleTimer = seconds;
  }
}
