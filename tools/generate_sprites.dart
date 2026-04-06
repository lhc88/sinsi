// ignore_for_file: avoid_print
/// 픽셀아트 스프라이트 시트 생성기
/// 실행: dart run tools/generate_sprites.dart
library;

import 'dart:io';
import 'package:image/image.dart' as img;

// ══════════════════════════════════════════
//  색상 팔레트 — 한국 신화 테마
// ══════════════════════════════════════════
class C {
  // 피부/머리
  static final skin = img.ColorRgba8(235, 200, 160, 255);
  static final skinDark = img.ColorRgba8(200, 165, 130, 255);
  static final hair = img.ColorRgba8(30, 20, 15, 255);

  // 한복 — 백색/남색
  static final hanbok = img.ColorRgba8(240, 238, 230, 255);
  static final hanbokShade = img.ColorRgba8(200, 198, 190, 255);
  static final navy = img.ColorRgba8(29, 53, 87, 255);
  static final navyLight = img.ColorRgba8(45, 75, 115, 255);

  // 갓
  static final gat = img.ColorRgba8(50, 35, 25, 255);
  static final gatLight = img.ColorRgba8(75, 55, 40, 255);

  // 오행 원소
  static final fire = img.ColorRgba8(230, 57, 70, 255);
  static final fireLight = img.ColorRgba8(255, 140, 66, 255);
  static final fireBright = img.ColorRgba8(255, 209, 102, 255);
  static final water = img.ColorRgba8(69, 123, 157, 255);
  static final waterLight = img.ColorRgba8(168, 218, 220, 255);
  static final wood = img.ColorRgba8(62, 137, 72, 255);
  static final woodDark = img.ColorRgba8(40, 90, 48, 255);
  static final metal = img.ColorRgba8(192, 192, 192, 255);
  static final metalDark = img.ColorRgba8(140, 140, 150, 255);
  static final earth = img.ColorRgba8(180, 140, 100, 255);
  static final earthDark = img.ColorRgba8(140, 105, 72, 255);

  // 적 공통
  static final ghostWhite = img.ColorRgba8(200, 200, 220, 180);
  static final ghostBlue = img.ColorRgba8(150, 160, 200, 150);
  static final eyeRed = img.ColorRgba8(255, 50, 50, 255);
  static final eyeYellow = img.ColorRgba8(255, 200, 0, 255);
  static final hornBrown = img.ColorRgba8(160, 120, 70, 255);

  // 보스
  static final bossRed = img.ColorRgba8(180, 30, 30, 255);
  static final bossPurple = img.ColorRgba8(120, 50, 150, 255);
  static final bossGold = img.ColorRgba8(220, 180, 50, 255);

  // 아이템
  static final gold = img.ColorRgba8(255, 209, 102, 255);
  static final goldDark = img.ColorRgba8(180, 140, 50, 255);
  static final expGreen = img.ColorRgba8(80, 200, 120, 255);
  static final expBlue = img.ColorRgba8(100, 150, 255, 255);

  // 기본
  static final black = img.ColorRgba8(20, 20, 25, 255);
  static final outline = img.ColorRgba8(35, 30, 40, 255);
  static final white = img.ColorRgba8(255, 255, 255, 255);
  static final transparent = img.ColorRgba8(0, 0, 0, 0);

  // 배경
  static final bgGrass = img.ColorRgba8(30, 50, 30, 255);
  static final bgGrassLight = img.ColorRgba8(38, 62, 38, 255);
  static final bgDirt = img.ColorRgba8(55, 42, 30, 255);
  static final bgDirtLight = img.ColorRgba8(70, 55, 40, 255);
  static final bgStone = img.ColorRgba8(60, 60, 65, 255);
}

// ══════════════════════════════════════════
//  헬퍼
// ══════════════════════════════════════════

void px(img.Image im, int x, int y, img.Color c) {
  if (x >= 0 && x < im.width && y >= 0 && y < im.height) {
    im.setPixel(x, y, c);
  }
}

void rect(img.Image im, int x1, int y1, int x2, int y2, img.Color c) {
  for (int y = y1; y <= y2; y++) {
    for (int x = x1; x <= x2; x++) {
      px(im, x, y, c);
    }
  }
}

void circle(img.Image im, int cx, int cy, int r, img.Color c) {
  for (int y = cy - r; y <= cy + r; y++) {
    for (int x = cx - r; x <= cx + r; x++) {
      if ((x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r) {
        px(im, x, y, c);
      }
    }
  }
}

void hLine(img.Image im, int x1, int x2, int y, img.Color c) {
  for (int x = x1; x <= x2; x++) px(im, x, y, c);
}

void vLine(img.Image im, int x, int y1, int y2, img.Color c) {
  for (int y = y1; y <= y2; y++) px(im, x, y, c);
}

/// 한 프레임을 시트에 복사
void blit(img.Image sheet, img.Image frame, int destX, int destY) {
  for (int y = 0; y < frame.height; y++) {
    for (int x = 0; x < frame.width; x++) {
      final p = frame.getPixel(x, y);
      if (p.a > 0) {
        sheet.setPixel(destX + x, destY + y, p);
      }
    }
  }
}

// ══════════════════════════════════════════
//  플레이어 캐릭터 (32x32, 4프레임 idle + 4프레임 walk)
// ══════════════════════════════════════════

img.Image makePlayerFrame(int frame, bool walking, {
  img.Color? hanbokColor,
  img.Color? beltColor,
  img.Color? hatColor,
  int weaponStyle = 0, // 0=부적, 1=검, 2=지팡이
}) {
  final im = img.Image(width: 32, height: 32);
  im.clear(C.transparent);

  hanbokColor ??= C.hanbok;
  beltColor ??= C.navy;
  hatColor ??= C.gat;

  final bobY = walking ? (frame % 2 == 0 ? -1 : 1) : (frame == 1 || frame == 3 ? -1 : 0);
  final legFrame = walking ? frame : 0;

  // 그림자
  for (int x = 11; x <= 21; x++) {
    px(im, x, 30, img.ColorRgba8(0, 0, 0, 40));
    px(im, x, 31, img.ColorRgba8(0, 0, 0, 25));
  }

  // 다리/발 (walking animation)
  if (walking) {
    if (legFrame == 0 || legFrame == 2) {
      rect(im, 13, 26 + bobY, 14, 29 + bobY, C.navy);
      rect(im, 18, 26 + bobY, 19, 29 + bobY, C.navy);
    } else if (legFrame == 1) {
      rect(im, 12, 26 + bobY, 13, 29 + bobY, C.navy);
      rect(im, 19, 26 + bobY, 20, 28 + bobY, C.navy);
    } else {
      rect(im, 12, 26 + bobY, 13, 28 + bobY, C.navy);
      rect(im, 19, 26 + bobY, 20, 29 + bobY, C.navy);
    }
  } else {
    rect(im, 13, 26, 14, 29, C.navy);
    rect(im, 18, 26, 19, 29, C.navy);
  }

  // 도포 (한복 상의)
  rect(im, 10, 15 + bobY, 22, 26 + bobY, hanbokColor);
  // 도포 그림자
  rect(im, 10, 15 + bobY, 11, 26 + bobY, C.hanbokShade);
  // 도포 외곽선
  vLine(im, 9, 15 + bobY, 26 + bobY, C.outline);
  vLine(im, 23, 15 + bobY, 26 + bobY, C.outline);
  hLine(im, 10, 22, 27 + bobY, C.outline);

  // 소매 (양팔)
  rect(im, 7, 16 + bobY, 10, 22 + bobY, hanbokColor);
  rect(im, 22, 16 + bobY, 25, 22 + bobY, hanbokColor);
  // 소매 외곽
  hLine(im, 7, 10, 15 + bobY, C.outline);
  hLine(im, 22, 25, 15 + bobY, C.outline);
  vLine(im, 6, 16 + bobY, 22 + bobY, C.outline);
  vLine(im, 26, 16 + bobY, 22 + bobY, C.outline);
  hLine(im, 7, 9, 23 + bobY, C.outline);
  hLine(im, 23, 25, 23 + bobY, C.outline);

  // 띠 (허리)
  rect(im, 10, 20 + bobY, 22, 21 + bobY, beltColor);

  // 머리
  rect(im, 11, 5 + bobY, 21, 14 + bobY, C.skin);
  // 머리 외곽
  hLine(im, 11, 21, 4 + bobY, C.outline);
  hLine(im, 11, 21, 15 + bobY, C.outline);
  vLine(im, 10, 5 + bobY, 14 + bobY, C.outline);
  vLine(im, 22, 5 + bobY, 14 + bobY, C.outline);

  // 눈
  px(im, 13, 10 + bobY, C.black);
  px(im, 14, 10 + bobY, C.black);
  px(im, 18, 10 + bobY, C.black);
  px(im, 19, 10 + bobY, C.black);
  // 눈 하이라이트
  px(im, 13, 9 + bobY, C.white);
  px(im, 18, 9 + bobY, C.white);

  // 입
  px(im, 15, 12 + bobY, C.skinDark);
  px(im, 16, 12 + bobY, C.skinDark);
  px(im, 17, 12 + bobY, C.skinDark);

  // 갓 (모자)
  rect(im, 8, 2 + bobY, 24, 3 + bobY, hatColor);
  hLine(im, 8, 24, 1 + bobY, C.outline);
  hLine(im, 8, 24, 4 + bobY, C.outline);
  // 갓 윗부분
  rect(im, 12, 0 + bobY, 20, 2 + bobY, hatColor);
  hLine(im, 13, 19, 0 + bobY, C.outline);

  // 무기 (오른쪽 손)
  if (weaponStyle == 0) {
    // 부적
    rect(im, 26, 17 + bobY, 29, 22 + bobY, C.fireBright);
    vLine(im, 27, 18 + bobY, 21 + bobY, C.fire);
    hLine(im, 27, 28, 19 + bobY, C.fire);
  } else if (weaponStyle == 1) {
    // 검
    vLine(im, 27, 12 + bobY, 22 + bobY, C.metal);
    px(im, 27, 11 + bobY, C.metalDark);
    hLine(im, 26, 28, 22 + bobY, C.earthDark);
  } else {
    // 지팡이
    vLine(im, 27, 10 + bobY, 24 + bobY, C.earthDark);
    circle(im, 27, 9 + bobY, 2, C.waterLight);
  }

  return im;
}

img.Image makePlayerSheet(String name, {
  img.Color? hanbokColor,
  img.Color? beltColor,
  img.Color? hatColor,
  int weaponStyle = 0,
}) {
  // 8프레임: 4 idle + 4 walk (32x32 each) → 256x32
  final sheet = img.Image(width: 256, height: 32);
  sheet.clear(C.transparent);

  for (int i = 0; i < 4; i++) {
    blit(sheet, makePlayerFrame(i, false,
        hanbokColor: hanbokColor, beltColor: beltColor,
        hatColor: hatColor, weaponStyle: weaponStyle), i * 32, 0);
  }
  for (int i = 0; i < 4; i++) {
    blit(sheet, makePlayerFrame(i, true,
        hanbokColor: hanbokColor, beltColor: beltColor,
        hatColor: hatColor, weaponStyle: weaponStyle), (i + 4) * 32, 0);
  }

  return sheet;
}

// ══════════════════════════════════════════
//  적 스프라이트 (32x32, 4프레임)
// ══════════════════════════════════════════

img.Image makeJabgwiFrame(int frame) {
  final im = img.Image(width: 32, height: 32);
  im.clear(C.transparent);
  final bob = frame % 2 == 0 ? 0 : 1;

  // 유령 몸통 (반투명)
  final bodyColor = img.ColorRgba8(180, 180, 210, 160);
  for (int y = 6; y <= 24; y++) {
    final waveOff = (y > 20) ? ((frame + y) % 3 - 1) : 0;
    final w = (y < 10) ? (y - 5) * 2 : (y > 20 ? 24 - (y - 20) * 3 + waveOff : 14);
    final cx = 16;
    for (int x = cx - w ~/ 2; x <= cx + w ~/ 2; x++) {
      px(im, x, y + bob, bodyColor);
    }
  }

  // 눈 (빨간 빛)
  px(im, 12, 12 + bob, C.eyeRed);
  px(im, 13, 12 + bob, C.eyeRed);
  px(im, 19, 12 + bob, C.eyeRed);
  px(im, 20, 12 + bob, C.eyeRed);
  // 눈 발광
  px(im, 12, 11 + bob, img.ColorRgba8(255, 100, 100, 100));
  px(im, 20, 11 + bob, img.ColorRgba8(255, 100, 100, 100));

  return im;
}

img.Image makeDokkaebiFrame(int frame) {
  final im = img.Image(width: 32, height: 32);
  im.clear(C.transparent);
  final bob = frame % 2 == 0 ? 0 : 1;

  // 그림자
  hLine(im, 11, 21, 30, img.ColorRgba8(0, 0, 0, 40));

  // 몸통 (초록 요괴)
  rect(im, 10, 12 + bob, 22, 26 + bob, C.wood);
  rect(im, 11, 12 + bob, 21, 25 + bob, C.woodDark);
  // 외곽
  vLine(im, 9, 12 + bob, 26 + bob, C.outline);
  vLine(im, 23, 12 + bob, 26 + bob, C.outline);
  hLine(im, 10, 22, 11 + bob, C.outline);
  hLine(im, 10, 22, 27 + bob, C.outline);

  // 얼굴
  rect(im, 11, 8 + bob, 21, 14 + bob, C.wood);
  // 뿔 (2개)
  vLine(im, 12, 3 + bob, 8 + bob, C.hornBrown);
  vLine(im, 20, 3 + bob, 8 + bob, C.hornBrown);
  px(im, 12, 2 + bob, C.fireBright);
  px(im, 20, 2 + bob, C.fireBright);

  // 눈
  px(im, 13, 10 + bob, C.eyeYellow);
  px(im, 14, 10 + bob, C.eyeYellow);
  px(im, 18, 10 + bob, C.eyeYellow);
  px(im, 19, 10 + bob, C.eyeYellow);

  // 입 (큰 입)
  hLine(im, 13, 19, 13 + bob, C.fire);

  // 방망이 (오른손)
  rect(im, 24, 14 + bob, 26, 24 + bob, C.earthDark);
  rect(im, 23, 12 + bob, 27, 14 + bob, C.earth);

  // 다리
  rect(im, 12, 27 + bob, 14, 29 + bob, C.woodDark);
  rect(im, 18, 27 + bob, 20, 29 + bob, C.woodDark);

  return im;
}

img.Image makeCheonyeoFrame(int frame) {
  final im = img.Image(width: 32, height: 32);
  im.clear(C.transparent);
  final float = frame < 2 ? 0 : 1;

  // 긴 머리카락 (양쪽으로 흘러내림)
  final hairColor = img.ColorRgba8(25, 20, 40, 255);
  for (int i = -1; i <= 1; i++) {
    vLine(im, 12 + i * 3, 4 + float, 28 + float, hairColor);
    vLine(im, 20 + i * 3, 4 + float, 28 + float, hairColor);
  }
  vLine(im, 16, 3 + float, 7 + float, hairColor);

  // 한복 (흰색)
  final bodyColor = img.ColorRgba8(230, 230, 240, 200);
  rect(im, 11, 12 + float, 21, 28 + float, bodyColor);
  // 치마 하단 물결
  for (int x = 10; x <= 22; x++) {
    final wave = (x + frame) % 3 == 0 ? 1 : 0;
    px(im, x, 29 + float + wave, bodyColor);
  }

  // 얼굴 (창백)
  final faceColor = img.ColorRgba8(230, 230, 240, 255);
  rect(im, 12, 5 + float, 20, 12 + float, faceColor);

  // 눈 (검은 빈 눈)
  rect(im, 13, 8 + float, 14, 9 + float, C.black);
  rect(im, 18, 8 + float, 19, 9 + float, C.black);

  // 입 (빨간 한)
  px(im, 15, 11 + float, C.fire);
  px(im, 16, 11 + float, C.fire);
  px(im, 17, 11 + float, C.fire);

  // 귀신불 발광
  circle(im, 16, 16 + float, 14, img.ColorRgba8(100, 120, 200, 20));

  return im;
}

img.Image makeGenericEnemyFrame(int frame, img.Color bodyColor, img.Color eyeColor, {
  int horns = 0, bool armored = false, int size = 32,
}) {
  final im = img.Image(width: size, height: size);
  im.clear(C.transparent);
  final bob = frame % 2 == 0 ? 0 : 1;
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  final r = size ~/ 3;

  // 그림자
  hLine(im, cx - r, cx + r, size - 2, img.ColorRgba8(0, 0, 0, 40));

  // 몸통
  circle(im, cx, cy + bob, r, bodyColor);

  // 갑옷
  if (armored) {
    for (int a = -r + 2; a <= r - 2; a++) {
      for (int b = -r ~/ 2; b <= r ~/ 2; b++) {
        if ((a + b) % 3 == 0) {
          px(im, cx + a, cy + b + bob, C.metalDark);
        }
      }
    }
  }

  // 외곽선
  for (double angle = 0; angle < 6.28; angle += 0.1) {
    final ox = (cx + r * _cos(angle)).round();
    final oy = (cy + bob + r * _sin(angle)).round();
    px(im, ox, oy, C.outline);
  }

  // 뿔
  if (horns >= 1) {
    vLine(im, cx, cy - r + bob, cy - r - 4 + bob, C.hornBrown);
    px(im, cx, cy - r - 5 + bob, C.fireBright);
  }
  if (horns >= 2) {
    vLine(im, cx - 5, cy - r + 2 + bob, cy - r - 3 + bob, C.hornBrown);
    vLine(im, cx + 5, cy - r + 2 + bob, cy - r - 3 + bob, C.hornBrown);
  }

  // 눈
  px(im, cx - 3, cy - 2 + bob, eyeColor);
  px(im, cx - 2, cy - 2 + bob, eyeColor);
  px(im, cx + 2, cy - 2 + bob, eyeColor);
  px(im, cx + 3, cy - 2 + bob, eyeColor);

  return im;
}

double _cos(double a) => a < 1.57 ? 1 - a * a / 2 : (a < 3.14 ? -(1 - (3.14 - a) * (3.14 - a) / 2) : (a < 4.71 ? -(1 - (a - 3.14) * (a - 3.14) / 2) : (1 - (6.28 - a) * (6.28 - a) / 2)));
double _sin(double a) => _cos(a - 1.57);

img.Image makeEnemySheet(String type) {
  final sheet = img.Image(width: 128, height: 32);
  sheet.clear(C.transparent);

  for (int i = 0; i < 4; i++) {
    img.Image frame;
    switch (type) {
      case 'jabgwi':
        frame = makeJabgwiFrame(i);
      case 'dokkaebi_jol':
        frame = makeDokkaebiFrame(i);
      case 'cheonyeo_gwisin':
        frame = makeCheonyeoFrame(i);
      case 'haetae':
        frame = makeGenericEnemyFrame(i, C.earth, C.eyeYellow, horns: 1, armored: true, size: 32);
      case 'bulyeou':
        frame = makeGenericEnemyFrame(i, C.fire, C.eyeYellow, horns: 0, size: 32);
      case 'gapot_gwisin':
        frame = makeGenericEnemyFrame(i, C.metalDark, C.eyeRed, armored: true, horns: 0, size: 32);
      case 'yacha':
        frame = makeGenericEnemyFrame(i, C.fire, C.eyeRed, horns: 2, size: 32);
      case 'gureongi':
        frame = makeGenericEnemyFrame(i, C.water, C.eyeYellow, horns: 0, size: 32);
      case 'nalssaen':
        frame = makeGenericEnemyFrame(i, C.wood, C.eyeRed, horns: 0, size: 32);
      case 'gangsi':
        frame = makeGenericEnemyFrame(i, C.earthDark, C.eyeRed, horns: 0, armored: true, size: 32);
      default:
        frame = makeGenericEnemyFrame(i, C.metal, C.eyeRed, size: 32);
    }
    blit(sheet, frame, i * 32, 0);
  }
  return sheet;
}

// ══════════════════════════════════════════
//  보스 (64x64, 4프레임)
// ══════════════════════════════════════════

img.Image makeBossFrame(int frame, String type) {
  final im = img.Image(width: 64, height: 64);
  im.clear(C.transparent);
  final bob = frame % 2 == 0 ? 0 : 1;

  switch (type) {
    case 'dokkaebi': // 도깨비 대장
      // 큰 몸통
      rect(im, 16, 20 + bob, 48, 54 + bob, C.wood);
      rect(im, 17, 21 + bob, 47, 53 + bob, C.woodDark);
      // 외곽
      vLine(im, 15, 20 + bob, 54 + bob, C.outline);
      vLine(im, 49, 20 + bob, 54 + bob, C.outline);
      hLine(im, 16, 48, 19 + bob, C.outline);
      hLine(im, 16, 48, 55 + bob, C.outline);
      // 얼굴
      rect(im, 18, 10 + bob, 46, 22 + bob, C.wood);
      // 큰 뿔 2개
      rect(im, 20, 1 + bob, 23, 10 + bob, C.hornBrown);
      rect(im, 41, 1 + bob, 44, 10 + bob, C.hornBrown);
      px(im, 21, 0 + bob, C.fireBright);
      px(im, 22, 0 + bob, C.fireBright);
      px(im, 42, 0 + bob, C.fireBright);
      px(im, 43, 0 + bob, C.fireBright);
      // 큰 눈
      rect(im, 22, 13 + bob, 26, 16 + bob, C.eyeYellow);
      rect(im, 38, 13 + bob, 42, 16 + bob, C.eyeYellow);
      // 동공
      rect(im, 24, 14 + bob, 25, 15 + bob, C.black);
      rect(im, 40, 14 + bob, 41, 15 + bob, C.black);
      // 큰 입
      hLine(im, 24, 40, 19 + bob, C.fire);
      hLine(im, 25, 39, 20 + bob, C.fire);
      // 이빨
      for (int x = 26; x <= 38; x += 3) {
        px(im, x, 19 + bob, C.white);
      }
      // 거대 방망이
      rect(im, 50, 16 + bob, 54, 50 + bob, C.earthDark);
      rect(im, 48, 10 + bob, 56, 16 + bob, C.earth);
      // 다리
      rect(im, 22, 55 + bob, 28, 62 + bob, C.woodDark);
      rect(im, 36, 55 + bob, 42, 62 + bob, C.woodDark);

    case 'gumiho': // 구미호
      // 여우 몸통
      rect(im, 20, 26 + bob, 44, 48 + bob, C.fireLight);
      rect(im, 21, 27 + bob, 43, 47 + bob, img.ColorRgba8(255, 220, 180, 255));
      // 외곽
      vLine(im, 19, 26 + bob, 48 + bob, C.outline);
      vLine(im, 45, 26 + bob, 48 + bob, C.outline);
      // 머리
      rect(im, 22, 14 + bob, 42, 26 + bob, C.fireLight);
      // 여우 귀
      rect(im, 20, 6 + bob, 25, 14 + bob, C.fireLight);
      rect(im, 39, 6 + bob, 44, 14 + bob, C.fireLight);
      rect(im, 22, 8 + bob, 23, 12 + bob, img.ColorRgba8(255, 200, 200, 255));
      rect(im, 41, 8 + bob, 42, 12 + bob, img.ColorRgba8(255, 200, 200, 255));
      // 눈 (매혹적)
      rect(im, 25, 18 + bob, 29, 20 + bob, C.eyeYellow);
      rect(im, 35, 18 + bob, 39, 20 + bob, C.eyeYellow);
      px(im, 27, 19 + bob, C.black);
      px(im, 37, 19 + bob, C.black);
      // 입
      px(im, 31, 23 + bob, C.fire);
      px(im, 32, 23 + bob, C.fire);
      px(im, 33, 23 + bob, C.fire);
      // 꼬리 9개 (뒤에 부채형)
      for (int t = -4; t <= 4; t++) {
        final tx = 16 + t * 2;
        for (int ty = 50; ty <= 60; ty++) {
          px(im, tx, ty + bob, C.fireLight);
          if (ty == 60) px(im, tx, ty + bob, C.white);
        }
      }
      // 다리
      rect(im, 24, 49 + bob, 28, 56 + bob, C.fireLight);
      rect(im, 36, 49 + bob, 40, 56 + bob, C.fireLight);

    case 'jangsan': // 장산범
      // 호랑이 몸통
      rect(im, 16, 24 + bob, 48, 50 + bob, C.fireBright);
      // 줄무늬
      for (int sy = 26; sy <= 48; sy += 4) {
        for (int sx = 18; sx <= 46; sx += 6) {
          rect(im, sx, sy + bob, sx + 2, sy + 1 + bob, C.black);
        }
      }
      // 머리
      rect(im, 20, 10 + bob, 44, 24 + bob, C.fireBright);
      // 눈 (사나운)
      rect(im, 24, 15 + bob, 28, 17 + bob, C.eyeRed);
      rect(im, 36, 15 + bob, 40, 17 + bob, C.eyeRed);
      // 코
      rect(im, 30, 19 + bob, 34, 20 + bob, img.ColorRgba8(200, 100, 80, 255));
      // 이빨
      px(im, 27, 22 + bob, C.white);
      px(im, 29, 22 + bob, C.white);
      px(im, 35, 22 + bob, C.white);
      px(im, 37, 22 + bob, C.white);
      // 귀
      rect(im, 20, 5 + bob, 26, 10 + bob, C.fireBright);
      rect(im, 38, 5 + bob, 44, 10 + bob, C.fireBright);
      // 다리 (4개)
      rect(im, 18, 50 + bob, 24, 60 + bob, C.fireBright);
      rect(im, 28, 50 + bob, 34, 60 + bob, C.fireBright);
      rect(im, 30, 50 + bob, 36, 60 + bob, C.fireBright);
      rect(im, 40, 50 + bob, 46, 60 + bob, C.fireBright);

    case 'bulgasari': // 불가사리
      // 금속 몸통
      circle(im, 32, 32 + bob, 22, C.metalDark);
      circle(im, 32, 32 + bob, 20, C.metal);
      // 눈 패턴
      rect(im, 26, 26 + bob, 30, 30 + bob, C.eyeRed);
      rect(im, 34, 26 + bob, 38, 30 + bob, C.eyeRed);
      // 입 (금속 갈라진 틈)
      hLine(im, 28, 36, 36 + bob, C.black);
      // 가시 (8방향)
      for (int d = 0; d < 8; d++) {
        final angle = d * 0.785;
        for (int dist = 22; dist <= 28; dist++) {
          final sx = (32 + dist * _cos(angle)).round();
          final sy = (32 + bob + dist * _sin(angle)).round();
          px(im, sx, sy, C.metalDark);
        }
      }

    case 'yongwang': // 용왕
      // 용 몸통
      rect(im, 18, 20 + bob, 46, 52 + bob, C.water);
      rect(im, 19, 21 + bob, 45, 51 + bob, C.waterLight);
      // 비늘 패턴
      for (int sy = 22; sy <= 50; sy += 3) {
        for (int sx = 20; sx <= 44; sx += 3) {
          px(im, sx, sy + bob, C.water);
        }
      }
      // 머리
      rect(im, 20, 8 + bob, 44, 22 + bob, C.water);
      // 뿔 (용뿔)
      rect(im, 22, 1 + bob, 25, 8 + bob, C.bossGold);
      rect(im, 39, 1 + bob, 42, 8 + bob, C.bossGold);
      // 눈 (위엄)
      rect(im, 24, 12 + bob, 29, 15 + bob, C.bossGold);
      rect(im, 35, 12 + bob, 40, 15 + bob, C.bossGold);
      px(im, 26, 13 + bob, C.black);
      px(im, 27, 13 + bob, C.black);
      px(im, 37, 13 + bob, C.black);
      px(im, 38, 13 + bob, C.black);
      // 수염
      for (int w = 0; w < 4; w++) {
        hLine(im, 14 - w, 20, 18 + w + bob, C.waterLight);
        hLine(im, 44, 50 + w, 18 + w + bob, C.waterLight);
      }
      // 여의주 (머리 위)
      circle(im, 32, 4 + bob, 3, C.bossGold);
      circle(im, 32, 4 + bob, 1, C.fireBright);
  }

  return im;
}

img.Image makeBossSheet(String type) {
  final sheet = img.Image(width: 256, height: 64);
  sheet.clear(C.transparent);
  for (int i = 0; i < 4; i++) {
    blit(sheet, makeBossFrame(i, type), i * 64, 0);
  }
  return sheet;
}

// ══════════════════════════════════════════
//  투사체 (16x16, 4프레임)
// ══════════════════════════════════════════

img.Image makeProjectileSheet(String type) {
  final sheet = img.Image(width: 64, height: 16);
  sheet.clear(C.transparent);

  for (int f = 0; f < 4; f++) {
    final im = img.Image(width: 16, height: 16);
    im.clear(C.transparent);
    final anim = f % 2;

    switch (type) {
      case 'bujeok': // 부적
        rect(im, 5, 2, 11, 13, C.fireBright);
        vLine(im, 8, 3, 12, C.fire);
        hLine(im, 6, 10, 6, C.fire);
        hLine(im, 6, 10, 9, C.fire);
        // 발광
        if (anim == 0) {
          rect(im, 4, 1, 12, 14, img.ColorRgba8(255, 200, 50, 30));
        }

      case 'binyeo': // 비녀검
        hLine(im, 2, 13, 7, C.metal);
        hLine(im, 2, 13, 8, C.metal);
        circle(im, 3, 7, 2, C.fire);
        px(im, 13, 7, C.white);

      case 'bangul': // 방울 (원형)
        circle(im, 8, 8, 4, C.waterLight);
        circle(im, 8, 8, 3, C.water);
        circle(im, 8, 8, 5 + anim, img.ColorRgba8(100, 150, 200, 50));

      case 'geumgangeo': // 금강저 (직선)
        rect(im, 2, 6, 14, 9, C.earth);
        rect(im, 3, 7, 13, 8, C.bossGold);
        if (anim == 1) {
          rect(im, 1, 5, 15, 10, img.ColorRgba8(200, 180, 50, 30));
        }

      case 'hwasal': // 화살
        hLine(im, 3, 13, 8, C.earthDark);
        px(im, 14, 7, C.metal);
        px(im, 14, 8, C.metal);
        px(im, 14, 9, C.metal);
        // 깃털
        px(im, 2, 6, C.fire);
        px(im, 2, 10, C.fire);

      case 'dokkaebi_bul': // 도깨비불
        circle(im, 8, 7, 3, C.fireLight);
        circle(im, 8, 7, 2, C.fireBright);
        // 꼬리
        vLine(im, 8, 10, 14, img.ColorRgba8(255, 140, 66, 100 + anim * 50));

      case 'dolpalmae': // 돌팔매
        circle(im, 8, 8, 4, C.earthDark);
        circle(im, 8, 8, 3, C.earth);
        px(im, 6, 6, C.white);

      case 'explosion': // 폭발
        final r = 3 + f * 2;
        circle(im, 8, 8, r, img.ColorRgba8(255, 100 + f * 30, 50, 200 - f * 40));
        circle(im, 8, 8, r - 1, img.ColorRgba8(255, 200, 100, 200 - f * 40));

      default:
        circle(im, 8, 8, 3, C.white);
    }

    blit(sheet, im, f * 16, 0);
  }
  return sheet;
}

// ══════════════════════════════════════════
//  아이템 (16x16)
// ══════════════════════════════════════════

img.Image makeExpGemSheet() {
  // 3등급 x 4프레임 → 192x16
  final sheet = img.Image(width: 192, height: 16);
  sheet.clear(C.transparent);

  final colors = [
    [C.wood, C.woodDark],           // tier 0: 소형 (초록)
    [C.expGreen, C.wood],           // tier 1: 중형 (밝은 초록)
    [C.expBlue, C.water],           // tier 2: 대형 (파랑)
  ];

  for (int tier = 0; tier < 3; tier++) {
    for (int f = 0; f < 4; f++) {
      final im = img.Image(width: 16, height: 16);
      im.clear(C.transparent);
      final glow = f < 2 ? 0 : 1;
      final size = 3 + tier;

      // 다이아몬드 모양
      for (int d = 0; d <= size; d++) {
        hLine(im, 8 - d, 8 + d, 8 - size + d, colors[tier][0]);
        hLine(im, 8 - d, 8 + d, 8 + size - d, colors[tier][0]);
      }
      // 하이라이트
      px(im, 7, 8 - size + 1, C.white);
      px(im, 8, 8 - size + 1, C.white);

      // 발광
      if (glow == 1) {
        circle(im, 8, 8, size + 2, img.ColorRgba8(colors[tier][0].r.toInt(), colors[tier][0].g.toInt(), colors[tier][0].b.toInt(), 30));
      }

      blit(sheet, im, (tier * 4 + f) * 16, 0);
    }
  }
  return sheet;
}

img.Image makeChestSheet() {
  // 4등급 x 1프레임 → 128x32
  final sheet = img.Image(width: 128, height: 32);
  sheet.clear(C.transparent);

  final chestColors = [
    [C.earthDark, C.earth],     // 철
    [C.goldDark, C.gold],       // 금
    [C.wood, C.expGreen],       // 옥
    [C.bossRed, C.fire],        // 용
  ];

  for (int grade = 0; grade < 4; grade++) {
    final im = img.Image(width: 32, height: 32);
    im.clear(C.transparent);

    // 본체
    rect(im, 6, 14, 26, 26, chestColors[grade][0]);
    rect(im, 7, 15, 25, 25, chestColors[grade][1]);
    // 뚜껑
    rect(im, 4, 8, 28, 14, chestColors[grade][0]);
    rect(im, 5, 9, 27, 13, chestColors[grade][1]);
    // 외곽
    vLine(im, 3, 8, 14, C.outline);
    vLine(im, 29, 8, 14, C.outline);
    hLine(im, 4, 28, 7, C.outline);
    vLine(im, 5, 14, 26, C.outline);
    vLine(im, 27, 14, 26, C.outline);
    hLine(im, 6, 26, 27, C.outline);
    // 잠금장치
    circle(im, 16, 18, 3, C.bossGold);
    circle(im, 16, 18, 1, C.black);
    // 빛줄기
    px(im, 16, 5, img.ColorRgba8(255, 255, 200, 80));
    px(im, 16, 6, img.ColorRgba8(255, 255, 200, 60));

    blit(sheet, im, grade * 32, 0);
  }
  return sheet;
}

// ══════════════════════════════════════════
//  배경 타일 (64x64)
// ══════════════════════════════════════════

img.Image makeTileSheet() {
  // 4종 타일 → 256x64
  final sheet = img.Image(width: 256, height: 64);
  sheet.clear(C.transparent);

  // 타일 1: 풀밭 (기본)
  final grass = img.Image(width: 64, height: 64);
  grass.clear(C.bgGrass);
  for (int i = 0; i < 30; i++) {
    final gx = (i * 37 + 13) % 64;
    final gy = (i * 53 + 7) % 64;
    px(grass, gx, gy, C.bgGrassLight);
    px(grass, (gx + 1) % 64, gy, C.bgGrassLight);
  }
  // 풀 포인트
  for (int i = 0; i < 10; i++) {
    final gx = (i * 29 + 5) % 62 + 1;
    final gy = (i * 41 + 3) % 62 + 1;
    vLine(grass, gx, gy - 2, gy, img.ColorRgba8(45, 80, 45, 255));
  }
  blit(sheet, grass, 0, 0);

  // 타일 2: 흙길
  final dirt = img.Image(width: 64, height: 64);
  dirt.clear(C.bgDirt);
  for (int i = 0; i < 20; i++) {
    final dx = (i * 31 + 11) % 64;
    final dy = (i * 47 + 9) % 64;
    px(dirt, dx, dy, C.bgDirtLight);
    px(dirt, (dx + 1) % 64, dy, C.bgDirtLight);
  }
  blit(sheet, dirt, 64, 0);

  // 타일 3: 돌바닥
  final stone = img.Image(width: 64, height: 64);
  stone.clear(C.bgStone);
  for (int i = 0; i < 8; i++) {
    final sx = (i * 23 + 3) % 58 + 3;
    final sy = (i * 31 + 7) % 58 + 3;
    rect(stone, sx, sy, sx + 5, sy + 3, img.ColorRgba8(70, 70, 75, 255));
  }
  blit(sheet, stone, 128, 0);

  // 타일 4: 기와 (궁궐)
  final tile = img.Image(width: 64, height: 64);
  tile.clear(img.ColorRgba8(45, 35, 30, 255));
  for (int y = 0; y < 64; y += 8) {
    final offset = (y ~/ 8) % 2 == 0 ? 0 : 16;
    for (int x = offset; x < 64; x += 32) {
      rect(tile, x, y, x + 30, y + 6, img.ColorRgba8(55, 45, 38, 255));
      hLine(tile, x, x + 30, y, img.ColorRgba8(65, 52, 42, 255));
    }
  }
  blit(sheet, tile, 192, 0);

  return sheet;
}

// ══════════════════════════════════════════
//  UI 에셋 (버튼, 프레임)
// ══════════════════════════════════════════

img.Image makeUIFrame(int w, int h, img.Color borderColor, img.Color bgColor) {
  final im = img.Image(width: w, height: h);
  im.clear(C.transparent);

  // 배경
  rect(im, 2, 2, w - 3, h - 3, bgColor);
  // 테두리
  hLine(im, 2, w - 3, 0, borderColor);
  hLine(im, 2, w - 3, h - 1, borderColor);
  vLine(im, 0, 2, h - 3, borderColor);
  vLine(im, w - 1, 2, h - 3, borderColor);
  hLine(im, 1, w - 2, 1, borderColor);
  hLine(im, 1, w - 2, h - 2, borderColor);
  vLine(im, 1, 1, h - 2, borderColor);
  vLine(im, w - 2, 1, h - 2, borderColor);
  // 코너
  px(im, 1, 1, borderColor);
  px(im, w - 2, 1, borderColor);
  px(im, 1, h - 2, borderColor);
  px(im, w - 2, h - 2, borderColor);
  // 내부 하이라이트
  hLine(im, 3, w - 4, 2, img.ColorRgba8(255, 255, 255, 20));

  return im;
}

img.Image makeUIElements() {
  // 160x64: 버튼(64x24), 작은프레임(32x32), 슬롯(32x32), HP바(32x8)
  final sheet = img.Image(width: 160, height: 64);
  sheet.clear(C.transparent);

  // 버튼 (64x24)
  final btn = makeUIFrame(64, 24, C.gold, img.ColorRgba8(29, 53, 87, 220));
  blit(sheet, btn, 0, 0);

  // 아이콘 슬롯 (32x32)
  final slot = makeUIFrame(32, 32, C.metalDark, img.ColorRgba8(20, 30, 50, 200));
  blit(sheet, slot, 0, 32);

  // HP바 배경 (64x8)
  final hpBg = img.Image(width: 64, height: 8);
  hpBg.clear(C.transparent);
  rect(hpBg, 0, 0, 63, 7, img.ColorRgba8(40, 40, 40, 200));
  hLine(hpBg, 0, 63, 0, C.outline);
  hLine(hpBg, 0, 63, 7, C.outline);
  blit(sheet, hpBg, 64, 0);

  // HP바 채움 (64x8)
  final hpFill = img.Image(width: 64, height: 6);
  hpFill.clear(C.transparent);
  for (int x = 0; x < 64; x++) {
    final r = 230 - x;
    final g = 57 + x * 2;
    rect(hpFill, x, 0, x, 5, img.ColorRgba8(r.clamp(0, 255), g.clamp(0, 255), 70, 255));
  }
  blit(sheet, hpFill, 64, 10);

  // EXP바 채움 (64x6)
  final expFill = img.Image(width: 64, height: 6);
  expFill.clear(C.transparent);
  for (int x = 0; x < 64; x++) {
    rect(expFill, x, 0, x, 5, img.ColorRgba8(62, 137 + x, 72, 255));
  }
  blit(sheet, expFill, 64, 18);

  return sheet;
}

// ══════════════════════════════════════════
//  메인 — 전체 생성
// ══════════════════════════════════════════

void main() async {
  final outDir = Directory('assets/images');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final sprites = <String, img.Image>{};

  // ── 플레이어 캐릭터 8종 (characters.dart 기준) ──
  print('Generating player sprites...');
  sprites['player_lee_taeyang'] = makePlayerSheet('이태양',
      hanbokColor: C.hanbok, beltColor: C.navy, hatColor: C.gat, weaponStyle: 0);
  sprites['player_wolhui'] = makePlayerSheet('월희',
      hanbokColor: img.ColorRgba8(180, 50, 50, 255), beltColor: C.fire, hatColor: img.ColorRgba8(60, 50, 70, 255), weaponStyle: 2);
  sprites['player_cheolwoong'] = makePlayerSheet('철웅',
      hanbokColor: img.ColorRgba8(200, 200, 210, 255), beltColor: C.metal, hatColor: C.metalDark, weaponStyle: 1);
  sprites['player_soyeon'] = makePlayerSheet('소연',
      hanbokColor: img.ColorRgba8(40, 40, 50, 255), beltColor: img.ColorRgba8(80, 60, 80, 255), hatColor: C.hair, weaponStyle: 1);
  sprites['player_beopwoon'] = makePlayerSheet('법운',
      hanbokColor: img.ColorRgba8(160, 160, 150, 255), beltColor: C.earth, hatColor: C.earthDark, weaponStyle: 2);
  sprites['player_danbi'] = makePlayerSheet('단비',
      hanbokColor: img.ColorRgba8(220, 80, 80, 255), beltColor: img.ColorRgba8(80, 150, 200, 255), hatColor: C.white, weaponStyle: 0);
  sprites['player_gwison'] = makePlayerSheet('귀손',
      hanbokColor: img.ColorRgba8(100, 70, 100, 255), beltColor: img.ColorRgba8(150, 50, 50, 255), hatColor: C.hair, weaponStyle: 1);
  sprites['player_cheonmoo'] = makePlayerSheet('천무',
      hanbokColor: img.ColorRgba8(50, 80, 140, 255), beltColor: C.water, hatColor: C.navy, weaponStyle: 2);

  // ── 적 10종 ──
  print('Generating enemy sprites...');
  for (final type in ['jabgwi', 'dokkaebi_jol', 'cheonyeo_gwisin', 'haetae',
      'bulyeou', 'gapot_gwisin', 'yacha', 'gureongi', 'nalssaen', 'gangsi']) {
    sprites['enemy_$type'] = makeEnemySheet(type);
  }

  // ── 보스 5종 ──
  print('Generating boss sprites...');
  for (final type in ['dokkaebi', 'gumiho', 'jangsan', 'bulgasari', 'yongwang']) {
    sprites['boss_$type'] = makeBossSheet(type);
  }

  // ── 투사체 8종 ──
  print('Generating projectile sprites...');
  for (final type in ['bujeok', 'binyeo', 'bangul', 'geumgangeo', 'hwasal',
      'dokkaebi_bul', 'dolpalmae', 'explosion']) {
    sprites['proj_$type'] = makeProjectileSheet(type);
  }

  // ── 아이템 ──
  print('Generating item sprites...');
  sprites['exp_gems'] = makeExpGemSheet();
  sprites['chests'] = makeChestSheet();

  // ── 배경 타일 ──
  print('Generating tile sprites...');
  sprites['tiles'] = makeTileSheet();

  // ── UI ──
  print('Generating UI sprites...');
  sprites['ui_elements'] = makeUIElements();

  // ── 저장 ──
  print('Saving ${sprites.length} sprite sheets...');
  for (final entry in sprites.entries) {
    final path = '${outDir.path}/${entry.key}.png';
    final bytes = img.encodePng(entry.value);
    File(path).writeAsBytesSync(bytes);
    print('  ✓ $path (${entry.value.width}x${entry.value.height})');
  }

  print('\n✅ Done! Generated ${sprites.length} sprite sheets in assets/images/');
}
