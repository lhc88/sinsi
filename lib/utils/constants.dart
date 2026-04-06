import 'dart:ui';

// 게임 월드
const double worldWidth = 4000;
const double worldHeight = 4000;

// 플레이어 기본값
const double defaultPlayerSpeed = 200.0;
const double defaultPlayerHp = 100.0;
const double defaultPickupRange = 64.0;

// 충돌 그리드
const double collisionCellSize = 64.0;

// 카메라
const double cameraLag = 0.1;

// 색상 팔레트 (24색 마스터 팔레트)
class Palette {
  // 피부/따뜻함
  static const Color skin1 = Color(0xFFF2D2A9);
  static const Color skin2 = Color(0xFFD4915C);
  static const Color skin3 = Color(0xFF8B5E34);
  static const Color skin4 = Color(0xFF5C3A1E);

  // 목(木)
  static const Color wood1 = Color(0xFF7EC850);
  static const Color wood2 = Color(0xFF3E8948);
  static const Color wood3 = Color(0xFF265C2F);
  static const Color wood4 = Color(0xFF1A3A20);

  // 화(火)
  static const Color fire1 = Color(0xFFE63946);
  static const Color fire2 = Color(0xFFFF8C42);
  static const Color fire3 = Color(0xFFFFD166);
  static const Color fire4 = Color(0xFFFFF1C1);

  // 토(土)
  static const Color earth1 = Color(0xFFC9A96E);
  static const Color earth2 = Color(0xFF8B6914);
  static const Color earth3 = Color(0xFF5C4033);
  static const Color earth4 = Color(0xFF3D2B1F);

  // 금(金)
  static const Color metal1 = Color(0xFFF1FAEE);
  static const Color metal2 = Color(0xFFC0C0C0);
  static const Color metal3 = Color(0xFF808080);
  static const Color metal4 = Color(0xFF404040);

  // 수(水)
  static const Color water1 = Color(0xFF457B9D);
  static const Color water2 = Color(0xFF1D3557);
  static const Color water3 = Color(0xFF0D1B2A);
  static const Color water4 = Color(0xFFA8DADC);

  // UI
  static const Color background = Color(0xFF0D1B2A);
  static const Color hpBar = Color(0xFFE63946);
  static const Color expBar = Color(0xFF7EC850);
  static const Color gold = Color(0xFFFFD166);
}
