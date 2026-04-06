import 'dart:ui';
import 'package:flame/components.dart';
import '../../utils/sprite_painter.dart';
import '../../utils/sprite_loader.dart';
import '../../utils/constants.dart';

/// 배경 타일 렌더링 — 카메라 뷰포트 영역만 그림
class BackgroundRenderer extends Component with HasGameReference {
  static const double _tileSize = 128;

  @override
  void render(Canvas canvas) {
    final cam = game.camera;
    final vp = cam.viewport;
    final vpSize = vp.size;
    final camPos = cam.viewfinder.position;

    final startX = ((camPos.x - vpSize.x / 2) / _tileSize).floor() * _tileSize;
    final startY = ((camPos.y - vpSize.y / 2) / _tileSize).floor() * _tileSize;
    final endX = camPos.x + vpSize.x / 2 + _tileSize;
    final endY = camPos.y + vpSize.y / 2 + _tileSize;

    final loader = SpriteLoader.instance;
    final hasSprite = loader.getImage('tiles') != null;

    for (double x = startX; x < endX; x += _tileSize) {
      for (double y = startY; y < endY; y += _tileSize) {
        if (x < 0 || y < 0 || x > worldWidth || y > worldHeight) continue;

        if (hasSprite) {
          // tiles.png: 4종 타일 (각 64x64), 위치 해시로 변형 선택
          final tileIndex = ((x ~/ _tileSize) + (y ~/ _tileSize) * 3) % 2; // 0=풀, 1=흙 변형
          loader.drawFrame(canvas, 'tiles', tileIndex,
              frameW: 64, frameH: 64,
              destX: x, destY: y, destW: _tileSize, destH: _tileSize);
        } else {
          SpritePainter.drawGroundTile(canvas, x, y, _tileSize);
        }
      }
    }

    // 월드 경계선
    final borderPaint = Paint()
      ..color = const Color(0xFF3D0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, worldWidth, worldHeight),
      borderPaint,
    );
  }
}
