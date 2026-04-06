import 'dart:ui';
import 'package:flame/components.dart';
import '../../utils/constants.dart';
import '../../utils/sprite_painter.dart';
import '../../utils/sprite_loader.dart';

enum ChestGrade { wood, iron, gold, jade, dragon }

class TreasureChest extends PositionComponent {
  ChestGrade grade;
  bool isOpened = false;
  double _time = 0;

  TreasureChest({required this.grade, required Vector2 pos})
      : super(size: Vector2(32, 28), anchor: Anchor.center, position: pos);

  Color get _color => switch (grade) {
    ChestGrade.wood => Palette.earth3,
    ChestGrade.iron => Palette.metal3,
    ChestGrade.gold => Palette.gold,
    ChestGrade.jade => Palette.wood1,
    ChestGrade.dragon => Palette.water4,
  };

  String get gradeName => switch (grade) {
    ChestGrade.wood => '나무 상자',
    ChestGrade.iron => '철 상자',
    ChestGrade.gold => '금 상자',
    ChestGrade.jade => '옥 상자',
    ChestGrade.dragon => '용왕 상자',
  };

  int get maxEvolutions => switch (grade) {
    ChestGrade.wood => 0,
    ChestGrade.iron => 0,
    ChestGrade.gold => 1,
    ChestGrade.jade => 3,
    ChestGrade.dragon => 5,
  };

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  int get _gradeIndex => switch (grade) {
    ChestGrade.wood => 0,
    ChestGrade.iron => 0,
    ChestGrade.gold => 1,
    ChestGrade.jade => 2,
    ChestGrade.dragon => 3,
  };

  @override
  void render(Canvas canvas) {
    if (isOpened) return;

    final loader = SpriteLoader.instance;
    if (loader.getImage('chests') != null) {
      // chests.png: 4등급, 각 32x32
      loader.drawFrame(canvas, 'chests', _gradeIndex,
          frameW: 32, frameH: 32,
          destX: -4, destY: -4, destW: 40, destH: 36);
    } else {
      SpritePainter.drawChest(canvas, size.x / 2, size.y / 2, _color, _time);
    }
  }
}

ChestGrade chestGradeFromString(String s) => switch (s) {
  'wood' => ChestGrade.wood,
  'iron' => ChestGrade.iron,
  'gold' => ChestGrade.gold,
  'jade' => ChestGrade.jade,
  'dragon' => ChestGrade.dragon,
  _ => ChestGrade.iron,
};
