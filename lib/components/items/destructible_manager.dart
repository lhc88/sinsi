import 'dart:ui';
import 'package:flame/components.dart';
import 'destructible.dart';
import '../../utils/object_pool.dart';

/// 파괴 오브젝트 관리 — 풀링 + Canvas 일괄 렌더링
class DestructibleManager extends Component {
  late final ObjectPool<DestructibleInstance> pool;

  static const int maxActive = 40;

  DestructibleManager() {
    pool = ObjectPool<DestructibleInstance>(
      create: () => DestructibleInstance(),
      reset: (d) => d.reset(),
      initialSize: 40,
    );
  }

  List<DestructibleInstance> get activeDestructibles => pool.active;

  void spawn(DestructibleType type, double x, double y) {
    if (pool.activeCount >= maxActive) return;
    final d = pool.acquire();
    d.init(type, x, y);
  }

  void kill(DestructibleInstance d) {
    d.isActive = false;
    pool.release(d);
  }

  void clearAll() {
    pool.releaseAll();
  }

  double _camX = 0, _camY = 0;

  void updateCamera(double camX, double camY) {
    _camX = camX;
    _camY = camY;
  }

  @override
  void render(Canvas canvas) {
    for (final d in pool.active) {
      if (!d.isActive || d.isDestroyed) continue;

      // 화면 밖 컬링
      if ((d.x - _camX).abs() > 480 || (d.y - _camY).abs() > 320) continue;

      _renderDestructible(canvas, d);
    }
  }

  void _renderDestructible(Canvas canvas, DestructibleInstance d) {
    final cx = d.x;
    final cy = d.y;
    final half = d.size / 2;

    switch (d.type) {
      case DestructibleType.tree:
        // 나무 줄기
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + 8), width: 8, height: 20),
          Paint()..color = const Color(0xFF8B6914),
        );
        // 나뭇잎
        canvas.drawCircle(Offset(cx, cy - 5), 14,
          Paint()..color = const Color(0xFF3E8948));
        canvas.drawCircle(Offset(cx - 6, cy - 2), 10,
          Paint()..color = const Color(0xFF4AA052));

      case DestructibleType.rock:
        final path = Path()
          ..moveTo(cx, cy - 12)
          ..lineTo(cx + 14, cy + 4)
          ..lineTo(cx + 8, cy + 12)
          ..lineTo(cx - 10, cy + 10)
          ..lineTo(cx - 14, cy + 2)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF777777));
        canvas.drawPath(path, Paint()..color = const Color(0xFF999999)..style = PaintingStyle.stroke..strokeWidth = 1);

      case DestructibleType.pot:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 2), width: 16, height: 18),
          Paint()..color = const Color(0xFFC67A38),
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy - 8), width: 12, height: 4),
          Paint()..color = const Color(0xFFB06A28),
        );

      case DestructibleType.lantern:
        // 등불 기둥
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + 4), width: 4, height: 12),
          Paint()..color = const Color(0xFF666666),
        );
        // 불꽃
        canvas.drawCircle(Offset(cx, cy - 4), 6,
          Paint()..color = const Color(0xFFFFAA33));
        canvas.drawCircle(Offset(cx, cy - 4), 8,
          Paint()..color = const Color(0x44FFCC00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    // HP 바 (데미지 입었을 때만)
    if (d.hp < d.maxHp) {
      final barW = d.size * 0.8;
      final barH = 3.0;
      final barX = cx - barW / 2;
      final barY = cy - half - 6;
      final ratio = (d.hp / d.maxHp).clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(barX, barY, barW, barH),
        Paint()..color = const Color(0x88000000));
      canvas.drawRect(Rect.fromLTWH(barX, barY, barW * ratio, barH),
        Paint()..color = const Color(0xFFFF6644));
    }
  }
}
