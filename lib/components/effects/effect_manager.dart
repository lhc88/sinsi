import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle, TextDirection;
import '../../utils/constants.dart';
import '../../utils/tuning_params.dart';

class _DamageNumber {
  Vector2 position;
  double damage;
  double timer;
  bool isActive;
  bool isCrit;
  bool isHeal;

  _DamageNumber()
      : position = Vector2.zero(),
        damage = 0,
        timer = 0,
        isActive = false,
        isCrit = false,
        isHeal = false;
}

class _DeathParticle {
  Vector2 position;
  Vector2 velocity;
  double timer;
  double maxTime;
  Color color;
  double size;
  bool isActive;

  _DeathParticle()
      : position = Vector2.zero(),
        velocity = Vector2.zero(),
        timer = 0,
        maxTime = 0.5,
        color = Palette.fire1,
        size = 4,
        isActive = false;
}

class _Explosion {
  Vector2 position;
  double radius;
  double timer;
  double maxTime;
  bool isActive;

  _Explosion()
      : position = Vector2.zero(),
        radius = 0,
        timer = 0,
        maxTime = 0.3,
        isActive = false;
}

class _CollectRing {
  Vector2 position;
  double timer;
  double maxTime;
  double radius;
  Color color;
  bool isActive;

  _CollectRing()
      : position = Vector2.zero(),
        timer = 0,
        maxTime = 0.25,
        radius = 20,
        color = const Color(0xFF4ECDC4),
        isActive = false;
}

class EffectManager extends Component with HasGameReference {
  final List<_DamageNumber> _numbers = List.generate(100, (_) => _DamageNumber());
  final List<_DeathParticle> _particles = List.generate(200, (_) => _DeathParticle());
  final List<_Explosion> _explosions = List.generate(30, (_) => _Explosion());
  final List<_CollectRing> _collectRings = List.generate(20, (_) => _CollectRing());
  final Random _rng = Random();

  // 기운 수집 콤보 시스템
  int gemCombo = 0;
  double _comboTimer = 0;
  static const double _comboWindow = 1.5; // 1.5초 내 연속 수집 시 콤보
  double _comboDisplayTimer = 0;

  void spawnDamageNumber(Vector2 pos, double damage, {bool isCrit = false, bool isHeal = false}) {
    for (final n in _numbers) {
      if (!n.isActive) {
        n.position = pos.clone() + Vector2(_rng.nextDouble() * 16 - 8, -10);
        n.damage = damage;
        n.isCrit = isCrit;
        n.isHeal = isHeal;
        n.timer = TuningParams.damageFloatDuration;
        n.isActive = true;
        return;
      }
    }
  }

  void spawnDeathEffect(Vector2 pos, double size) {
    int count = 0;
    for (final p in _particles) {
      if (!p.isActive && count < 5) {
        final angle = _rng.nextDouble() * 2 * pi;
        final speed = 80 + _rng.nextDouble() * 120;
        p.position = pos.clone();
        p.velocity = Vector2(cos(angle), sin(angle)) * speed;
        p.timer = 0;
        p.maxTime = 0.3 + _rng.nextDouble() * 0.3;
        p.size = 3 + _rng.nextDouble() * 4;
        p.color = Color.lerp(Palette.fire2, Palette.fire3, _rng.nextDouble())!;
        p.isActive = true;
        count++;
      }
    }
  }

  // 킬 스트릭 표시
  int _killStreakDisplay = 0;
  double _killStreakDisplayTimer = 0;
  Vector2 _killStreakPos = Vector2.zero();

  void spawnKillStreakText(Vector2 pos, int streak) {
    _killStreakDisplay = streak;
    _killStreakDisplayTimer = 1.5;
    _killStreakPos = pos.clone();
  }

  /// 기운 수집 이펙트: 링 + 콤보 카운트
  void spawnGemCollectEffect(Vector2 pos, int tier) {
    gemCombo++;
    _comboTimer = _comboWindow;
    if (gemCombo >= 5) {
      _comboDisplayTimer = 1.0; // 5콤보 이상이면 표시
    }

    for (final ring in _collectRings) {
      if (!ring.isActive) {
        ring.position = pos.clone();
        ring.timer = 0;
        ring.maxTime = 0.25;
        ring.radius = 12.0 + tier * 6;
        ring.color = tier >= 2
            ? const Color(0xFFFFD700) // 결정: 금색
            : tier >= 1
                ? const Color(0xFF4ECDC4) // 대: 청록
                : const Color(0xFF90EE90); // 소: 연녹
        ring.isActive = true;
        return;
      }
    }
  }

  void spawnExplosion(Vector2 pos, double radius) {
    for (final e in _explosions) {
      if (!e.isActive) {
        e.position = pos.clone();
        e.radius = radius;
        e.timer = 0;
        e.maxTime = 0.3;
        e.isActive = true;
        return;
      }
    }
  }

  @override
  void update(double dt) {
    for (final n in _numbers) {
      if (!n.isActive) continue;
      n.timer -= dt;
      n.position.y -= TuningParams.damageFloatSpeed * dt;
      if (n.timer <= 0) n.isActive = false;
    }

    for (final p in _particles) {
      if (!p.isActive) continue;
      p.timer += dt;
      p.position += p.velocity * dt;
      p.velocity *= 0.95;
      if (p.timer >= p.maxTime) p.isActive = false;
    }

    for (final e in _explosions) {
      if (!e.isActive) continue;
      e.timer += dt;
      if (e.timer >= e.maxTime) e.isActive = false;
    }

    for (final ring in _collectRings) {
      if (!ring.isActive) continue;
      ring.timer += dt;
      if (ring.timer >= ring.maxTime) ring.isActive = false;
    }

    // 킬 스트릭 타이머
    if (_killStreakDisplayTimer > 0) {
      _killStreakDisplayTimer -= dt;
      _killStreakPos.y -= 30 * dt;
    }

    // 콤보 타이머
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        gemCombo = 0;
      }
    }
    if (_comboDisplayTimer > 0) {
      _comboDisplayTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    // 콤보 카운터 (플레이어 위치 기준)
    try {
      final g = game as dynamic;
      renderCombo(canvas, g.player.position as Vector2);
      // 저승사자 렌더링
      if (g.isReaperActive as bool) {
        _renderReaper(canvas, g.reaperPosition as Vector2, g.gameTime as double);
      }
    } catch (_) {}

    // 폭발
    for (final e in _explosions) {
      if (!e.isActive) continue;
      final progress = e.timer / e.maxTime;
      final alpha = ((1 - progress) * 0.6 * 255).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = Palette.fire3.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(
        Offset(e.position.x, e.position.y),
        e.radius * (0.5 + progress * 0.5),
        paint,
      );
    }

    // 파티클
    for (final p in _particles) {
      if (!p.isActive) continue;
      final progress = p.timer / p.maxTime;
      final alpha = ((1 - progress) * 255).toInt().clamp(0, 255);
      final paint = Paint()..color = p.color.withAlpha(alpha);
      canvas.drawCircle(
        Offset(p.position.x, p.position.y),
        p.size * (1 - progress * 0.5),
        paint,
      );
    }

    // 킬 스트릭 표시 + 칭호
    if (_killStreakDisplayTimer > 0 && _killStreakDisplay >= 10) {
      final alpha = (_killStreakDisplayTimer.clamp(0.0, 1.0) * 255).toInt();
      final scale = 1.0 + (_killStreakDisplay / 100).clamp(0.0, 1.0);
      final color = _killStreakDisplay >= 50
          ? Color.fromARGB(alpha, 255, 50, 50)
          : _killStreakDisplay >= 25
              ? Color.fromARGB(alpha, 255, 165, 0)
              : Color.fromARGB(alpha, 255, 255, 100);
      final title = _killStreakDisplay >= 100 ? '귀살의 군주'
          : _killStreakDisplay >= 50 ? '귀신 사냥꾼'
          : _killStreakDisplay >= 25 ? '퇴마 일격'
          : '대량 퇴치';
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title\n',
              style: TextStyle(color: color, fontSize: 14 * scale, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '$_killStreakDisplay KILL!',
              style: TextStyle(
                color: color,
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 12, color: color)],
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();
      tp.paint(canvas, Offset(_killStreakPos.x - tp.width / 2, _killStreakPos.y - 80));
    }

    // 수집 링 이펙트
    for (final ring in _collectRings) {
      if (!ring.isActive) continue;
      final progress = ring.timer / ring.maxTime;
      final alpha = ((1 - progress) * 200).toInt().clamp(0, 255);
      final currentRadius = ring.radius * (0.5 + progress * 1.5);
      final paint = Paint()
        ..color = ring.color.withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * (1 - progress);
      canvas.drawCircle(
        Offset(ring.position.x, ring.position.y),
        currentRadius,
        paint,
      );
    }

    // 데미지 숫자
    for (final n in _numbers) {
      if (!n.isActive) continue;
      final progress = n.timer / TuningParams.damageFloatDuration;
      final alpha = (progress * 255).toInt().clamp(0, 255);

      final textPainter = TextPainter(
        text: TextSpan(
          text: n.isHeal ? '+${n.damage.toInt()}' : n.isCrit ? '${n.damage.toInt()}!' : n.damage.toInt().toString(),
          style: TextStyle(
            color: n.isHeal
                ? Color.fromARGB(alpha, 100, 255, 100)
                : n.isCrit
                    ? Color.fromARGB(alpha, 255, 215, 0)
                    : Color.fromARGB(alpha, 255, 255, 255),
            fontSize: n.isCrit ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(n.position.x - textPainter.width / 2, n.position.y),
      );
    }
  }

  /// 콤보 카운터를 플레이어 위치 기준으로 렌더링
  void renderCombo(Canvas canvas, Vector2 playerPos) {
    if (_comboDisplayTimer <= 0 || gemCombo < 5) return;

    final alpha = (_comboDisplayTimer.clamp(0.0, 1.0) * 255).toInt();
    final scale = 1.0 + (gemCombo / 50).clamp(0.0, 1.0); // 콤보 많을수록 커짐
    final fontSize = 16.0 * scale;

    final comboColor = gemCombo >= 30
        ? Color.fromARGB(alpha, 255, 215, 0) // 30+: 금색
        : gemCombo >= 15
            ? Color.fromARGB(alpha, 255, 140, 0) // 15+: 주황
            : Color.fromARGB(alpha, 100, 255, 100); // 5+: 초록

    final tp = TextPainter(
      text: TextSpan(
        text: '${gemCombo}x COMBO',
        style: TextStyle(
          color: comboColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(playerPos.x - tp.width / 2, playerPos.y - 50));
  }

  /// 저승사자 Canvas 렌더링 (검은 로브 + 낫)
  void _renderReaper(Canvas canvas, Vector2 pos, double time) {
    final cx = pos.x;
    final cy = pos.y;
    final pulse = sin(time * 3) * 0.1 + 1.0;

    // 검은 그림자 아우라
    canvas.drawCircle(
      Offset(cx, cy),
      48 * pulse,
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // 몸체 (어두운 보라)
    canvas.drawCircle(
      Offset(cx, cy),
      28,
      Paint()..color = const Color(0xFF2D0A4E),
    );

    // 머리 부분
    canvas.drawCircle(
      Offset(cx, cy - 20),
      14,
      Paint()..color = const Color(0xFF1A0530),
    );

    // 눈 (빨간 점 2개)
    final eyeGlow = (sin(time * 5) * 0.3 + 0.7).clamp(0.0, 1.0);
    final eyePaint = Paint()
      ..color = Color.fromRGBO(255, 0, 0, eyeGlow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(cx - 5, cy - 22), 3, eyePaint);
    canvas.drawCircle(Offset(cx + 5, cy - 22), 3, eyePaint);

    // 낫 (곡선)
    final scythePaint = Paint()
      ..color = const Color(0xFFC0C0C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path()
      ..moveTo(cx + 15, cy + 10)
      ..quadraticBezierTo(cx + 35, cy - 30, cx + 5, cy - 40);
    canvas.drawPath(path, scythePaint);
  }
}
