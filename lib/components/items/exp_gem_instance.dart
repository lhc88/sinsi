import 'package:flame/components.dart';

/// 기운(경험치 젬) 데이터 객체
class ExpGemInstance {
  Vector2 position = Vector2.zero();
  double value = 1; // 경험치 양
  bool isActive = false;
  bool isBeingCollected = false; // 자석 수집 중
  double collectSpeed = 0;
  double size = 8;

  // 크기별: 소(1), 대(5), 결정(25)
  int tier = 0; // 0=소, 1=대, 2=결정

  void init(Vector2 pos, double exp) {
    position = pos.clone();
    value = exp;
    isActive = true;
    isBeingCollected = false;
    collectSpeed = 0;

    if (exp >= 25) {
      tier = 2;
      size = 16;
    } else if (exp >= 5) {
      tier = 1;
      size = 12;
    } else {
      tier = 0;
      size = 8;
    }
  }

  void reset() {
    isActive = false;
    isBeingCollected = false;
    collectSpeed = 0;
  }
}
