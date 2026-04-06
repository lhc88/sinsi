import 'dart:math';
import 'dart:ui';
import '../data/enemies.dart' show Element;
import 'constants.dart';

/// 프로그래매틱 스프라이트 — 한국 신화풍 캐릭터/적/무기 Canvas 렌더링
class SpritePainter {
  // ═══════════════════════════════════════════
  //  플레이어 캐릭터
  // ═══════════════════════════════════════════

  static void drawPlayer(Canvas canvas, double cx, double cy, double facing,
      {bool flash = false, bool invincible = false, double animTime = 0}) {
    final bobY = sin(animTime * 8) * 2; // 걷기 바운스

    // 그림자
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 28), width: 40, height: 12),
      Paint()..color = const Color(0x33000000),
    );

    // 도포 (한복 상의) — 흰색 기본
    final dopoPath = Path();
    dopoPath.moveTo(cx - 16, cy - 8 + bobY);
    dopoPath.lineTo(cx - 20, cy + 24 + bobY);
    dopoPath.lineTo(cx + 20, cy + 24 + bobY);
    dopoPath.lineTo(cx + 16, cy - 8 + bobY);
    dopoPath.close();
    canvas.drawPath(dopoPath, Paint()..color = flash ? const Color(0xFFFFFFFF) : const Color(0xFFF1FAEE));
    // 도포 외곽선
    canvas.drawPath(dopoPath, Paint()
      ..color = const Color(0xFF404040)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // 띠 (남색)
    canvas.drawRect(
      Rect.fromLTWH(cx - 17, cy + 4 + bobY, 34, 5),
      Paint()..color = const Color(0xFF1D3557),
    );

    // 머리
    final headPaint = Paint()..color = flash ? const Color(0xFFFFFFFF) : Palette.skin1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 16 + bobY), width: 28, height: 26),
        const Radius.circular(10),
      ),
      headPaint,
    );
    // 머리 외곽선
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 16 + bobY), width: 28, height: 26),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF404040)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // 상투 + 갓
    final hatPath = Path();
    hatPath.moveTo(cx - 18, cy - 24 + bobY);
    hatPath.lineTo(cx + 18, cy - 24 + bobY);
    hatPath.lineTo(cx + 14, cy - 28 + bobY);
    hatPath.lineTo(cx - 14, cy - 28 + bobY);
    hatPath.close();
    canvas.drawPath(hatPath, Paint()..color = const Color(0xFF3D2B1F));
    // 갓 윗부분
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 32 + bobY), width: 16, height: 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF3D2B1F),
    );

    // 눈
    if (!flash) {
      final eyeX = facing >= 0 ? 4.0 : -4.0;
      canvas.drawCircle(Offset(cx - 5 + eyeX * 0.3, cy - 18 + bobY), 2.5, Paint()..color = const Color(0xFF1A1A1A));
      canvas.drawCircle(Offset(cx + 5 + eyeX * 0.3, cy - 18 + bobY), 2.5, Paint()..color = const Color(0xFF1A1A1A));
      // 하이라이트
      canvas.drawCircle(Offset(cx - 4 + eyeX * 0.3, cy - 19 + bobY), 1, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(Offset(cx + 6 + eyeX * 0.3, cy - 19 + bobY), 1, Paint()..color = const Color(0xFFFFFFFF));
    }

    // 부적 (오른손에 들고 있음)
    final bujeokX = cx + (facing >= 0 ? 22 : -22);
    final bujeokY = cy + bobY;
    _drawBujeok(canvas, bujeokX, bujeokY, 8, animTime);

    // 무적 실드
    if (invincible) {
      canvas.drawCircle(
        Offset(cx, cy + bobY),
        36,
        Paint()
          ..color = Palette.water4.withValues(alpha: 0.25 + sin(animTime * 10) * 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  static void _drawBujeok(Canvas canvas, double cx, double cy, double size, double time) {
    // 부적 종이
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: size, height: size * 1.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1)),
      Paint()..color = Palette.fire4,
    );
    // 부적 문양 (세로선 + 가로선)
    final ink = Paint()..color = Palette.fire1..strokeWidth = 1;
    canvas.drawLine(Offset(cx, cy - size * 0.6), Offset(cx, cy + size * 0.6), ink);
    canvas.drawLine(Offset(cx - size * 0.3, cy - size * 0.2), Offset(cx + size * 0.3, cy - size * 0.2), ink);
    canvas.drawLine(Offset(cx - size * 0.3, cy + size * 0.2), Offset(cx + size * 0.3, cy + size * 0.2), ink);
    // 발광
    canvas.drawCircle(
      Offset(cx, cy),
      size * 0.8,
      Paint()..color = Palette.fire3.withValues(alpha: 0.15 + sin(time * 6) * 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  // ═══════════════════════════════════════════
  //  적 — 타입별 디테일
  // ═══════════════════════════════════════════

  /// 잡귀 — 흐릿한 유령
  static void drawJabgwi(Canvas canvas, double cx, double cy, double size, {bool flash = false, double time = 0}) {
    final bob = sin(time * 5) * 3;
    final alpha = flash ? 1.0 : 0.8;
    // 몸통 (부유하는 형태)
    final bodyPath = Path();
    bodyPath.moveTo(cx - size * 0.4, cy - size * 0.3 + bob);
    bodyPath.quadraticBezierTo(cx, cy - size * 0.6 + bob, cx + size * 0.4, cy - size * 0.3 + bob);
    bodyPath.quadraticBezierTo(cx + size * 0.45, cy + size * 0.2 + bob, cx + size * 0.3, cy + size * 0.4 + bob);
    // 물결치는 하단
    bodyPath.quadraticBezierTo(cx + size * 0.15, cy + size * 0.3 + bob, cx, cy + size * 0.45 + bob);
    bodyPath.quadraticBezierTo(cx - size * 0.15, cy + size * 0.3 + bob, cx - size * 0.3, cy + size * 0.4 + bob);
    bodyPath.quadraticBezierTo(cx - size * 0.45, cy + size * 0.2 + bob, cx - size * 0.4, cy - size * 0.3 + bob);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = (flash ? const Color(0xFFFFFFFF) : Palette.metal3).withValues(alpha: alpha));
    // 눈 (빨간 점)
    canvas.drawCircle(Offset(cx - 4, cy - size * 0.15 + bob), 3, Paint()..color = const Color(0xFFFF3333));
    canvas.drawCircle(Offset(cx + 4, cy - size * 0.15 + bob), 3, Paint()..color = const Color(0xFFFF3333));
    // 발광 아우라
    canvas.drawCircle(Offset(cx, cy + bob), size * 0.5,
      Paint()..color = const Color(0x15AAAAAA)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  /// 도깨비졸 — 뿔 달린 작은 요괴
  static void drawDokkaebiJol(Canvas canvas, double cx, double cy, double size, {bool flash = false, double time = 0}) {
    final bob = sin(time * 6) * 1.5;
    final c = flash ? const Color(0xFFFFFFFF) : Palette.wood1;
    // 그림자
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + size * 0.45), width: size * 0.7, height: 8), Paint()..color = const Color(0x33000000));
    // 몸통
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + bob), width: size * 0.75, height: size * 0.8), Radius.circular(size * 0.15)),
      Paint()..color = c,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + bob), width: size * 0.75, height: size * 0.8), Radius.circular(size * 0.15)),
      Paint()..color = const Color(0xFF1A3A20)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    // 뿔 (2개)
    final hornPaint = Paint()..color = Palette.earth2;
    canvas.drawLine(Offset(cx - 6, cy - size * 0.35 + bob), Offset(cx - 8, cy - size * 0.55 + bob), hornPaint..strokeWidth = 3);
    canvas.drawLine(Offset(cx + 6, cy - size * 0.35 + bob), Offset(cx + 8, cy - size * 0.55 + bob), hornPaint..strokeWidth = 3);
    // 눈 (분노)
    if (!flash) {
      canvas.drawCircle(Offset(cx - 5, cy - 3 + bob), 3, Paint()..color = const Color(0xFFFF0000));
      canvas.drawCircle(Offset(cx + 5, cy - 3 + bob), 3, Paint()..color = const Color(0xFFFF0000));
    }
    // 방망이
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + size * 0.3, cy - 2 + bob, 4, 18), const Radius.circular(2)),
      Paint()..color = Palette.skin3,
    );
  }

  /// 처녀귀신 — 긴 머리 유령
  static void drawCheonyeoGwisin(Canvas canvas, double cx, double cy, double size, {bool flash = false, double time = 0}) {
    final float = sin(time * 3) * 4;
    final c = flash ? const Color(0xFFFFFFFF) : Palette.water4;
    // 긴 머리카락
    for (int i = -2; i <= 2; i++) {
      final hairPath = Path();
      hairPath.moveTo(cx + i * 5, cy - size * 0.3 + float);
      hairPath.quadraticBezierTo(
        cx + i * 7 + sin(time * 4 + i) * 3, cy + size * 0.1 + float,
        cx + i * 4, cy + size * 0.5 + float,
      );
      canvas.drawPath(hairPath, Paint()..color = const Color(0xFF1A1A2E)..strokeWidth = 3..style = PaintingStyle.stroke);
    }
    // 한복 (흰색)
    final bodyPath = Path();
    bodyPath.moveTo(cx - 12, cy - size * 0.15 + float);
    bodyPath.lineTo(cx - 14, cy + size * 0.4 + float);
    bodyPath.quadraticBezierTo(cx, cy + size * 0.5 + float, cx + 14, cy + size * 0.4 + float);
    bodyPath.lineTo(cx + 12, cy - size * 0.15 + float);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = c.withValues(alpha: 0.85));
    // 얼굴 (창백)
    canvas.drawCircle(Offset(cx, cy - size * 0.2 + float), 10, Paint()..color = const Color(0xFFE8E8F0));
    // 눈 (검은 구멍)
    if (!flash) {
      canvas.drawCircle(Offset(cx - 4, cy - size * 0.22 + float), 2.5, Paint()..color = const Color(0xFF000000));
      canvas.drawCircle(Offset(cx + 4, cy - size * 0.22 + float), 2.5, Paint()..color = const Color(0xFF000000));
    }
    // 발광 아우라 (수 원소)
    canvas.drawCircle(Offset(cx, cy + float), size * 0.5,
      Paint()..color = Palette.water4.withValues(alpha: 0.12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }

  /// 범용 적 (나머지 타입용) — 색상+뿔 수로 구분
  static void drawGenericEnemy(Canvas canvas, double cx, double cy, double size, Color color,
      {bool flash = false, double time = 0, int horns = 0, bool armored = false}) {
    final bob = sin(time * 5 + cx * 0.01) * 1.5;
    final c = flash ? const Color(0xFFFFFFFF) : color;

    // 그림자
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + size * 0.45), width: size * 0.6, height: 8), Paint()..color = const Color(0x33000000));
    // 몸통
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + bob), width: size * 0.8, height: size * 0.85), Radius.circular(size * 0.2)),
      Paint()..color = c,
    );
    // 외곽선
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + bob), width: size * 0.8, height: size * 0.85), Radius.circular(size * 0.2)),
      Paint()..color = const Color(0xFF222222)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    // 갑옷
    if (armored) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + bob), width: size * 0.7, height: size * 0.6), Radius.circular(size * 0.1)),
        Paint()..color = const Color(0x44C0C0C0)..style = PaintingStyle.stroke..strokeWidth = 2,
      );
    }
    // 뿔
    final hornPaint = Paint()..color = Palette.earth2..strokeWidth = 3..strokeCap = StrokeCap.round;
    if (horns >= 1) canvas.drawLine(Offset(cx, cy - size * 0.4 + bob), Offset(cx, cy - size * 0.6 + bob), hornPaint);
    if (horns >= 2) {
      canvas.drawLine(Offset(cx - 8, cy - size * 0.35 + bob), Offset(cx - 10, cy - size * 0.55 + bob), hornPaint);
      canvas.drawLine(Offset(cx + 8, cy - size * 0.35 + bob), Offset(cx + 10, cy - size * 0.55 + bob), hornPaint);
    }
    // 눈
    if (!flash) {
      canvas.drawCircle(Offset(cx - 5, cy - 3 + bob), 3, Paint()..color = const Color(0xFFFF0000));
      canvas.drawCircle(Offset(cx + 5, cy - 3 + bob), 3, Paint()..color = const Color(0xFFFF0000));
    }
  }

  // ═══════════════════════════════════════════
  //  투사체
  // ═══════════════════════════════════════════

  /// 퇴마부적 투사체
  static void drawBujeokProjectile(Canvas canvas, double cx, double cy, double size, double time) {
    _drawBujeok(canvas, cx, cy, size, time);
  }

  /// 비녀검 투사체
  static void drawBinyeoGeom(Canvas canvas, double cx, double cy, double size, double angle, double time) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    // 검신
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: size * 2, height: 4), const Radius.circular(2)),
      Paint()..color = Palette.metal1,
    );
    // 장식 (비녀 머리)
    canvas.drawCircle(Offset(-size, 0), 4, Paint()..color = const Color(0xFFE63946));
    // 발광
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: size * 2.2, height: 8), const Radius.circular(4)),
      Paint()..color = Palette.metal1.withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();
  }

  /// 충격파 투사체
  static void drawShockwave(Canvas canvas, double cx, double cy, double size, double time) {
    final progress = (time * 3) % 1.0;
    canvas.drawCircle(
      Offset(cx, cy), size * (0.5 + progress * 0.5),
      Paint()..color = Palette.earth1.withValues(alpha: 1.0 - progress)..style = PaintingStyle.stroke..strokeWidth = 3,
    );
  }

  /// 음파 (원형 확산)
  static void drawSoundWave(Canvas canvas, double cx, double cy, double size, double time) {
    for (int i = 0; i < 3; i++) {
      final p = ((time * 2 + i * 0.3) % 1.0);
      canvas.drawCircle(
        Offset(cx, cy), size * p,
        Paint()..color = Palette.water4.withValues(alpha: (1.0 - p) * 0.5)..style = PaintingStyle.stroke..strokeWidth = 2,
      );
    }
  }

  /// 화염 폭발
  static void drawExplosion(Canvas canvas, double cx, double cy, double radius, double progress) {
    // 외곽 원
    canvas.drawCircle(
      Offset(cx, cy), radius * (0.3 + progress * 0.7),
      Paint()..color = Palette.fire2.withValues(alpha: (1.0 - progress) * 0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // 내부 밝은 원
    canvas.drawCircle(
      Offset(cx, cy), radius * (0.2 + progress * 0.3),
      Paint()..color = Palette.fire4.withValues(alpha: (1.0 - progress) * 0.8),
    );
  }

  /// 도깨비불 (추적형)
  static void drawWillOWisp(Canvas canvas, double cx, double cy, double size, double time) {
    final flicker = sin(time * 12) * 2;
    // 불꽃 코어
    canvas.drawCircle(Offset(cx, cy + flicker), size * 0.4, Paint()..color = Palette.fire3);
    canvas.drawCircle(Offset(cx, cy + flicker), size * 0.25, Paint()..color = Palette.fire4);
    // 발광
    canvas.drawCircle(Offset(cx, cy + flicker), size * 0.7,
      Paint()..color = Palette.fire2.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // 꼬리
    final tailPath = Path();
    tailPath.moveTo(cx, cy + size * 0.3 + flicker);
    tailPath.quadraticBezierTo(cx - 3, cy + size * 0.6, cx, cy + size * 0.8);
    canvas.drawPath(tailPath, Paint()..color = Palette.fire2.withValues(alpha: 0.5)..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  // ═══════════════════════════════════════════
  //  추가 무기 투사체 (고유 이펙트)
  // ═══════════════════════════════════════════

  /// 청룡도 회전 참격
  static void drawCheongryongdo(Canvas canvas, double cx, double cy, double size, double time) {
    final angle = time * 8; // 빠른 회전
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    // 초승달 형태 참격
    final path = Path()
      ..addArc(Rect.fromCircle(center: Offset.zero, radius: size * 0.8), -0.8, 1.6);
    canvas.drawPath(path, Paint()..color = Palette.wood2..strokeWidth = 3..style = PaintingStyle.stroke);
    canvas.drawPath(path, Paint()..color = Palette.wood1.withValues(alpha: 0.3)..strokeWidth = 6..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.restore();
  }

  /// 금강저 직선 충격파
  static void drawGeumgangeo(Canvas canvas, double cx, double cy, double size, double angle, double time) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    // 금빛 쐐기
    final path = Path()
      ..moveTo(size, 0)
      ..lineTo(-size * 0.3, -size * 0.4)
      ..lineTo(-size * 0.3, size * 0.4)
      ..close();
    canvas.drawPath(path, Paint()..color = Palette.earth2);
    canvas.drawPath(path, Paint()..color = Palette.earth1.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // 중심 밝은 점
    canvas.drawCircle(Offset.zero, 3, Paint()..color = Palette.fire4);
    canvas.restore();
  }

  /// 신성 방울 음파 탄
  static void drawBangul(Canvas canvas, double cx, double cy, double size, double time) {
    final pulse = sin(time * 10) * 0.2 + 0.8;
    canvas.drawCircle(Offset(cx, cy), size * 0.3 * pulse, Paint()..color = Palette.water3);
    canvas.drawCircle(Offset(cx, cy), size * 0.5,
      Paint()..color = Palette.water4.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset(cx, cy), size * 0.4,
      Paint()..color = Palette.water1.withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  /// 풍물북 폭발 투사체 (낙하 표시)
  static void drawPungmulBuk(Canvas canvas, double cx, double cy, double size, double time) {
    final pulse = (sin(time * 6) + 1) / 2;
    // 적색 원형 경고
    canvas.drawCircle(Offset(cx, cy), size * (0.6 + pulse * 0.4),
      Paint()..color = Palette.fire2.withValues(alpha: 0.3 + pulse * 0.3));
    // 중심 불꽃
    canvas.drawCircle(Offset(cx, cy), size * 0.25,
      Paint()..color = Palette.fire4);
    canvas.drawCircle(Offset(cx, cy), size * 0.5,
      Paint()..color = Palette.fire3.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  /// 요기 발톱 근접 할퀴기
  static void drawYogiBaltop(Canvas canvas, double cx, double cy, double size, double angle, double time) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    // 3줄 할퀴기 자국
    for (int i = -1; i <= 1; i++) {
      final y = i * size * 0.25;
      canvas.drawLine(Offset(-size * 0.4, y - 2), Offset(size * 0.6, y + 2),
        Paint()..color = Palette.wood3..strokeWidth = 2..strokeCap = StrokeCap.round);
    }
    // 잔광
    canvas.drawRect(Rect.fromCenter(center: Offset(size * 0.1, 0), width: size, height: size * 0.6),
      Paint()..color = Palette.wood1.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.restore();
  }

  /// 팔괘진 기운탄
  static void drawPalgwaejin(Canvas canvas, double cx, double cy, double size, double time) {
    final rotate = time * 4;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotate);
    // 태극 무늬 느낌 원
    canvas.drawCircle(Offset.zero, size * 0.3, Paint()..color = Palette.earth3);
    // 음양 반원
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: size * 0.3), 0, pi,
      true, Paint()..color = Palette.earth1);
    // 글로우
    canvas.drawCircle(Offset.zero, size * 0.5,
      Paint()..color = Palette.earth2.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.restore();
  }

  /// 화살 투사체
  static void drawHwasal(Canvas canvas, double cx, double cy, double size, double angle, double time) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    // 화살대
    canvas.drawLine(Offset(-size * 0.8, 0), Offset(size * 0.5, 0),
      Paint()..color = Palette.metal2..strokeWidth = 2);
    // 촉
    final tip = Path()
      ..moveTo(size * 0.7, 0)
      ..lineTo(size * 0.3, -3)
      ..lineTo(size * 0.3, 3)
      ..close();
    canvas.drawPath(tip, Paint()..color = Palette.metal1);
    // 깃
    canvas.drawLine(Offset(-size * 0.6, -3), Offset(-size * 0.8, 0),
      Paint()..color = Palette.fire2..strokeWidth = 1.5);
    canvas.drawLine(Offset(-size * 0.6, 3), Offset(-size * 0.8, 0),
      Paint()..color = Palette.fire2..strokeWidth = 1.5);
    canvas.restore();
  }

  /// 독안개 오라
  static void drawDokangae(Canvas canvas, double cx, double cy, double size, double time) {
    for (int i = 0; i < 3; i++) {
      final phase = (time * 1.5 + i * 0.7) % 2.0;
      final alpha = phase < 1 ? phase : 2 - phase;
      final offset = sin(time * 2 + i * 2) * size * 0.2;
      canvas.drawCircle(Offset(cx + offset, cy + cos(time * 1.5 + i) * size * 0.15),
        size * (0.3 + alpha * 0.2),
        Paint()..color = Palette.water2.withValues(alpha: alpha * 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    // 독 코어
    canvas.drawCircle(Offset(cx, cy), size * 0.15,
      Paint()..color = const Color(0xFF7EC850).withValues(alpha: 0.6));
  }

  /// 돌팔매 바운스 돌
  static void drawDolpalmae(Canvas canvas, double cx, double cy, double size, double time) {
    final rotate = time * 6;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotate);
    // 불규칙한 돌 형태
    final path = Path()
      ..moveTo(0, -size * 0.35)
      ..lineTo(size * 0.3, -size * 0.15)
      ..lineTo(size * 0.25, size * 0.25)
      ..lineTo(-size * 0.2, size * 0.3)
      ..lineTo(-size * 0.35, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = Palette.earth3);
    // 하이라이트
    canvas.drawCircle(Offset(-size * 0.05, -size * 0.1), size * 0.1,
      Paint()..color = Palette.earth1.withValues(alpha: 0.4));
    canvas.restore();
  }

  /// 투사체 히트 이펙트 (원소별 색상)
  static void drawHitEffect(Canvas canvas, double cx, double cy, double size, Element element, double time) {
    final color = _elementColor(element);
    final progress = (time % 0.2) / 0.2;
    final alpha = (1.0 - progress) * 0.7;
    canvas.drawCircle(Offset(cx, cy), size * (0.5 + progress),
      Paint()..color = color.withValues(alpha: alpha)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  static Color _elementColor(Element e) => switch (e) {
    Element.wood => Palette.wood2,
    Element.fire => Palette.fire3,
    Element.earth => Palette.earth2,
    Element.metal => Palette.metal1,
    Element.water => Palette.water3,
    Element.none => Palette.fire4,
  };

  // ═══════════════════════════════════════════
  //  기운 (경험치 젬)
  // ═══════════════════════════════════════════

  static void drawExpGem(Canvas canvas, double cx, double cy, double size, int tier, double time) {
    final glow = sin(time * 4) * 0.15 + 0.85;
    Color color;
    switch (tier) {
      case 2: color = const Color(0xFF00FF88);
      case 1: color = Palette.expBar;
      default: color = Palette.wood2;
    }

    // 다이아몬드
    final s = size / 2 * glow;
    final path = Path()
      ..moveTo(cx, cy - s * 1.2)
      ..lineTo(cx + s * 0.8, cy)
      ..lineTo(cx, cy + s * 1.2)
      ..lineTo(cx - s * 0.8, cy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    // 하이라이트
    final hlPath = Path()
      ..moveTo(cx, cy - s * 1.0)
      ..lineTo(cx + s * 0.3, cy - s * 0.2)
      ..lineTo(cx, cy)
      ..lineTo(cx - s * 0.3, cy - s * 0.2)
      ..close();
    canvas.drawPath(hlPath, Paint()..color = const Color(0x44FFFFFF));

    // 발광
    canvas.drawCircle(Offset(cx, cy), size * 0.8,
      Paint()..color = color.withValues(alpha: 0.2 * glow)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  // ═══════════════════════════════════════════
  //  보물상자
  // ═══════════════════════════════════════════

  static void drawChest(Canvas canvas, double cx, double cy, Color color, double time) {
    final shine = (sin(time * 3) * 0.5 + 0.5);
    // 본체
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 4), width: 32, height: 22), const Radius.circular(3)),
      Paint()..color = color,
    );
    // 뚜껑
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 6), width: 36, height: 12), const Radius.circular(3)),
      Paint()..color = Color.lerp(color, Colors.white, 0.15)!,
    );
    // 외곽선
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 28), const Radius.circular(3)),
      Paint()..color = const Color(0xFF222222)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    // 잠금장치
    canvas.drawCircle(Offset(cx, cy + 2), 4, Paint()..color = Color.lerp(Palette.gold, Colors.white, shine)!);
    canvas.drawCircle(Offset(cx, cy + 2), 2, Paint()..color = const Color(0xFF8B6914));
    // 빛줄기
    canvas.drawCircle(Offset(cx, cy), 20,
      Paint()..color = Palette.gold.withValues(alpha: 0.08 * shine)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
  }

  // ═══════════════════════════════════════════
  //  배경 타일
  // ═══════════════════════════════════════════

  static void drawGroundTile(Canvas canvas, double x, double y, double size) {
    // 어두운 땅
    canvas.drawRect(
      Rect.fromLTWH(x, y, size, size),
      Paint()..color = const Color(0xFF1A2A1A),
    );
    // 풀 점
    final grassPaint = Paint()..color = const Color(0xFF2A3A2A);
    for (int i = 0; i < 4; i++) {
      final gx = x + ((i * 37 + y.toInt()) % size.toInt()).toDouble();
      final gy = y + ((i * 53 + x.toInt()) % size.toInt()).toDouble();
      canvas.drawCircle(Offset(gx, gy), 1.5, grassPaint);
    }
  }
}

// Colors 클래스 (flutter/material 없이 사용)
class Colors {
  static const Color white = Color(0xFFFFFFFF);
}
