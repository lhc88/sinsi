import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle, TextDirection;
import '../../data/bosses.dart';
import '../../data/enemies.dart';
import '../../game/toemalok_game.dart';
import '../../utils/tuning_params.dart';

class Boss extends PositionComponent with HasGameReference {
  final BossData data;
  late double hp;
  late double maxHp;
  double flashTimer = 0;
  final List<double> _patternTimers = [];
  bool _enraged = false;
  double _stealthTimer = 0;
  double _invincibleTimer = 0;
  bool _stealthChargeQueued = false;
  final Random _rng = Random();

  // 돌진 애니메이션
  Vector2? _chargeTarget;
  Vector2? _chargeStart;
  double _chargeProgress = 0;
  bool get isCharging => _chargeTarget != null;

  // 위험 지역 표시
  final List<_DangerZone> _dangerZones = [];

  // 분신 (약한 보스)
  final List<Boss> clones = [];

  Boss({required this.data, double gameTimeMinutes = 0})
      : super(size: Vector2.all(data.size), anchor: Anchor.center) {
    maxHp = data.hp * (1 + gameTimeMinutes * TuningParams.bossHpScale);
    hp = maxHp;
    _patternTimers.addAll(data.patterns.map((p) => p.cooldown * 0.5)); // 첫 패턴 빨리
  }

  bool get isDead => hp <= 0;
  bool get isInvincible => _invincibleTimer > 0;

  @override
  void update(double dt) {
    super.update(dt);
    final gameRef = game as ToemalokGame;
    final playerPos = gameRef.player.position;

    // 스텔스
    if (_stealthTimer > 0) {
      _stealthTimer -= dt;
      if (_stealthTimer <= 0 && _stealthChargeQueued) {
        _stealthChargeQueued = false;
        _chargeStart = position.clone();
        _chargeTarget = playerPos.clone();
        _chargeProgress = 0;
      }
    }

    // 무적
    if (_invincibleTimer > 0) {
      _invincibleTimer -= dt;
    }

    // 돌진 중이면 돌진 애니메이션 처리
    if (_chargeTarget != null && _chargeStart != null) {
      _chargeProgress += dt * 3; // 0.33초에 완료
      if (_chargeProgress >= 1.0) {
        position = _chargeTarget!;
        _chargeTarget = null;
        _chargeStart = null;
        _chargeProgress = 0;
        gameRef.triggerScreenShake(8, 0.3);
        // 도착 지점 주변 데미지
        if (playerPos.distanceTo(position) < data.size) {
          gameRef.player.onHit(30);
        }
      } else {
        position = _chargeStart! + (_chargeTarget! - _chargeStart!) * _chargeProgress;
        // 돌진 경로 적중 체크
        if (playerPos.distanceTo(position) < data.size / 2 + 24) {
          gameRef.player.onHit(20);
        }
      }
    } else {
      // 플레이어 추적
      final dir = playerPos - position;
      if (dir.length > 10) {
        final speed = _enraged ? data.speed * 1.5 : data.speed;
        position += dir.normalized() * speed * dt;
      }

      // 접촉 데미지
      if (dir.length < data.size / 2 + 24) {
        gameRef.player.onHit(_enraged ? 15 : 10);
      }
    }

    // 위험 지역 타이머
    for (final zone in _dangerZones.toList()) {
      zone.timer -= dt;
      if (zone.timer <= 0) {
        // 범위 내 플레이어 데미지
        if (gameRef.player.position.distanceTo(zone.position) < zone.radius) {
          gameRef.player.onHit(zone.damage);
        }
        gameRef.effectManager.spawnExplosion(zone.position, zone.radius);
        _dangerZones.remove(zone);
      }
    }

    // 광폭화 체크
    if (!_enraged && hp / maxHp < 0.3) {
      _enraged = true;
      gameRef.triggerScreenShake(6, 0.3);
    }

    // 패턴 실행
    for (int i = 0; i < data.patterns.length; i++) {
      _patternTimers[i] -= dt;
      if (_patternTimers[i] <= 0) {
        _executePattern(i, gameRef, dt);
        _patternTimers[i] = data.patterns[i].cooldown * (_enraged ? 0.7 : 1.0);
      }
    }

    if (flashTimer > 0) flashTimer -= dt;
  }

  void _executePattern(int index, ToemalokGame gameRef, double dt) {
    final pattern = data.patterns[index];

    switch (pattern.pattern) {
      case BossPattern.rotate:
        // 주변 원형 데미지
        for (final e in [gameRef.player]) {
          if (e.position.distanceTo(position) < data.size * 1.2) {
            e.onHit(pattern.damage);
          }
        }
        gameRef.effectManager.spawnExplosion(position, data.size * 1.2);

      case BossPattern.summon:
        // 졸개 소환
        for (int i = 0; i < 4; i++) {
          final offset = Vector2(_rng.nextDouble() * 100 - 50, _rng.nextDouble() * 100 - 50);
          gameRef.enemyManager.spawnEnemy(
            EnemyType.dokkaebiJol, position + offset, gameRef.gameTime / 60);
        }

      case BossPattern.enrage:
        break; // 자동 처리

      case BossPattern.charm:
        // 슬로우 효과: 플레이어 이속 50% 감소 3초
        gameRef.player.slowTimer = 3.0;
        gameRef.effectManager.spawnExplosion(position, 200);

      case BossPattern.radial8:
        for (int i = 0; i < 8; i++) {
          final angle = 2 * pi * i / 8;
          gameRef.projectileManager.spawn(
            weaponId: 'boss_${data.id}',
            position: position.clone(),
            velocity: Vector2(cos(angle), sin(angle)) * 200,
            damage: pattern.damage,
            maxLifetime: 3,
            size: 16,
          );
        }

      case BossPattern.clone:
        // 분신: 보스와 같은 외형의 약한 엘리트 적 소환
        for (int i = 0; i < 2; i++) {
          final offset = Vector2(_rng.nextDouble() * 120 - 60, _rng.nextDouble() * 120 - 60);
          // HP가 높은 야차를 보스 색상으로 소환 (보스 분신 느낌)
          gameRef.enemyManager.spawnEnemy(
            EnemyType.yacha, position + offset, gameRef.gameTime / 60,
            speedMultiplier: 1.5);
        }
        gameRef.effectManager.spawnExplosion(position, 80);
        gameRef.triggerScreenShake(4, 0.2);

      case BossPattern.soundWave:
        // 넓은 음파: 3발 부채꼴
        final baseDir = (gameRef.player.position - position).normalized();
        final baseAngle = atan2(baseDir.y, baseDir.x);
        for (int i = -1; i <= 1; i++) {
          final angle = baseAngle + i * 0.3;
          gameRef.projectileManager.spawn(
            weaponId: 'boss_${data.id}',
            position: position.clone(),
            velocity: Vector2(cos(angle), sin(angle)) * 250,
            damage: pattern.damage,
            maxLifetime: 2.5,
            size: 28,
            pierce: 99,
          );
        }

      case BossPattern.buffAllies:
        // 주변 적 강화 (5초 지속)
        for (final enemy in gameRef.enemyManager.activeEnemies) {
          if (enemy.position.distanceTo(position) < 200) {
            enemy.applyBuff(5.0);
          }
        }

      case BossPattern.stealth:
        _stealthTimer = 3;
        _stealthChargeQueued = true;

      case BossPattern.charge:
        // 돌진: 즉시 이동 → 애니메이션으로 변경
        _chargeStart = position.clone();
        _chargeTarget = gameRef.player.position.clone();
        _chargeProgress = 0;
        // 돌진 경로에 위험 지역 표시
        _dangerZones.add(_DangerZone(
          position: gameRef.player.position.clone(),
          radius: data.size * 0.8,
          timer: 0.5,
          damage: pattern.damage,
        ));

      case BossPattern.quake:
        gameRef.triggerScreenShake(10, 0.5);
        // 전체 슬로우 효과
        gameRef.effectManager.spawnExplosion(position, 300);

      case BossPattern.invincible:
        _invincibleTimer = 5;

      case BossPattern.waterPillar:
        // 물기둥 3개: 1초 예고 후 타격 (위험 지역으로 표시)
        for (int i = 0; i < 3; i++) {
          final offset = Vector2(_rng.nextDouble() * 200 - 100, _rng.nextDouble() * 200 - 100);
          _dangerZones.add(_DangerZone(
            position: gameRef.player.position + offset,
            radius: 50,
            timer: 0.8 + i * 0.3, // 순차적으로 터짐
            damage: pattern.damage,
          ));
        }

      case BossPattern.whirlpool:
        // 끌어당김
        final pull = (position - gameRef.player.position).normalized() * 100;
        gameRef.player.position += pull * dt;

      case BossPattern.tsunami:
        // 화면 50% 범위
        if (gameRef.player.position.distanceTo(position) < 300) {
          gameRef.player.onHit(pattern.damage);
        }
        gameRef.triggerScreenShake(12, 0.5);
        gameRef.effectManager.spawnExplosion(position, 300);
    }
  }

  void takeDamage(double damage) {
    if (isInvincible) return;
    hp -= damage;
    flashTimer = TuningParams.flashDuration;
    (game as ToemalokGame).triggerHitStop(TuningParams.bossHitStopDuration);
  }

  @override
  void render(Canvas canvas) {
    final alpha = _stealthTimer > 0 ? 0.3 : 1.0;
    final bodyPaint = Paint()
      ..color = (flashTimer > 0 ? const Color(0xFFFFFFFF) : data.color)
          .withValues(alpha: alpha);

    // 몸체
    final half = data.size / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(half, half), width: data.size * 0.9, height: data.size * 0.9),
        Radius.circular(data.size * 0.15),
      ),
      bodyPaint,
    );

    // 무적 표시
    if (isInvincible) {
      final shieldPaint = Paint()
        ..color = const Color(0x66FFD166)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(half, half), half, shieldPaint);
    }

    // 눈 (빨간 눈 3개 - 요괴)
    final eyePaint = Paint()..color = const Color(0xFFFF0000).withValues(alpha: alpha);
    canvas.drawCircle(Offset(half - 15, half - 10), 5, eyePaint);
    canvas.drawCircle(Offset(half + 15, half - 10), 5, eyePaint);
    canvas.drawCircle(Offset(half, half - 20), 4, eyePaint);

    // HP바
    final barWidth = data.size * 0.8;
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(half - barWidth / 2, -10, barWidth, 6),
      Paint()..color = const Color(0xFF333333),
    );
    canvas.drawRect(
      Rect.fromLTWH(half - barWidth / 2, -10, barWidth * hpRatio, 6),
      Paint()..color = _enraged ? const Color(0xFFFF0000) : const Color(0xFFE63946),
    );

    // 이름
    final tp = TextPainter(
      text: TextSpan(
        text: data.name,
        style: TextStyle(color: const Color(0xFFFFFFFF).withValues(alpha: alpha), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(half - tp.width / 2, -20));

    // 위험 지역 렌더링
    for (final zone in _dangerZones) {
      final relX = zone.position.x - position.x + half;
      final relY = zone.position.y - position.y + half;
      final pulse = 0.5 + 0.5 * sin(zone.timer * 10);
      final zoneAlpha = (0.3 + pulse * 0.3).clamp(0.0, 1.0);

      // 채우기 (빨간색 반투명)
      final fillPaint = Paint()
        ..color = Color.fromRGBO(255, 50, 50, zoneAlpha * 0.4);
      canvas.drawCircle(Offset(relX, relY), zone.radius, fillPaint);

      // 테두리 (밝은 빨강)
      final strokePaint = Paint()
        ..color = Color.fromRGBO(255, 80, 30, zoneAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(relX, relY), zone.radius, strokePaint);
    }
  }
}

class _DangerZone {
  final Vector2 position;
  final double radius;
  double timer;
  final double damage;

  _DangerZone({
    required this.position,
    required this.radius,
    required this.timer,
    required this.damage,
  });
}
