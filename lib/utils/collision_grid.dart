import 'package:flame/components.dart';
import 'constants.dart';

/// 64px 셀 기반 공간 분할 충돌 시스템
class CollisionGrid {
  final double cellSize;
  final Map<int, List<CollisionEntity>> _cells = {};

  CollisionGrid({this.cellSize = collisionCellSize});

  int _hash(int cx, int cy) => cx * 73856093 ^ cy * 19349663;

  (int, int) _cellCoords(Vector2 pos) {
    return (pos.x ~/ cellSize, pos.y ~/ cellSize);
  }

  void clear() {
    _cells.clear();
  }

  void insert(CollisionEntity entity) {
    final (cx, cy) = _cellCoords(entity.position);
    final key = _hash(cx, cy);
    (_cells[key] ??= []).add(entity);
  }

  /// 주어진 위치 + 반경과 충돌하는 엔티티 조회 (같은 셀 + 인접 8셀)
  List<CollisionEntity> query(Vector2 pos, double radius, CollisionLayer layer) {
    final results = <CollisionEntity>[];
    final (cx, cy) = _cellCoords(pos);

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final key = _hash(cx + dx, cy + dy);
        final cell = _cells[key];
        if (cell == null) continue;
        for (final entity in cell) {
          if (entity.layer != layer) continue;
          final dist = entity.position.distanceTo(pos);
          if (dist < radius + entity.radius) {
            results.add(entity);
          }
        }
      }
    }
    return results;
  }
}

enum CollisionLayer { enemy, projectile, item, player }

class CollisionEntity {
  Vector2 position;
  double radius;
  CollisionLayer layer;
  int id; // 풀 인덱스 참조용

  CollisionEntity({
    required this.position,
    this.radius = 16,
    required this.layer,
    this.id = 0,
  });
}
