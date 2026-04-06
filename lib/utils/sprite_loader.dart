import 'dart:ui' as ui;
import 'package:flame/flame.dart';

/// 스프라이트 시트 로더 + 프레임 관리
class SpriteLoader {
  static final SpriteLoader instance = SpriteLoader._();
  SpriteLoader._();

  final Map<String, ui.Image> _images = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// 게임 시작 시 1회 호출 — 모든 스프라이트 시트 로드
  Future<void> loadAll() async {
    if (_loaded) return;

    final assets = [
      // 플레이어 (8종 — characters.dart 기준)
      'player_lee_taeyang', 'player_wolhui', 'player_cheolwoong',
      'player_soyeon', 'player_beopwoon', 'player_danbi',
      'player_gwison', 'player_cheonmoo',
      // 적
      'enemy_jabgwi', 'enemy_dokkaebi_jol', 'enemy_cheonyeo_gwisin',
      'enemy_haetae', 'enemy_bulyeou', 'enemy_gapot_gwisin',
      'enemy_yacha', 'enemy_gureongi', 'enemy_nalssaen', 'enemy_gangsi',
      // 보스
      'boss_dokkaebi', 'boss_gumiho', 'boss_jangsan', 'boss_bulgasari', 'boss_yongwang',
      // 투사체 (기본 무기)
      'proj_bujeok', 'proj_binyeo', 'proj_bangul', 'proj_geumgangeo',
      'proj_hwasal', 'proj_dokkaebi_bul', 'proj_dolpalmae', 'proj_explosion',
      // 투사체 (진화 무기)
      'proj_cheonloe', 'proj_yongcheon', 'proj_cheongryong_eon',
      'proj_hangma', 'proj_cheonji', 'proj_samulnori',
      'proj_gumiho', 'proj_taegeuk', 'proj_singung',
      'proj_hwangcheon', 'proj_bulgasari', 'proj_sammae',
      // 아이템
      'exp_gems', 'chests',
      // 배경/UI
      'tiles', 'ui_elements',
    ];

    for (final name in assets) {
      try {
        _images[name] = await Flame.images.load('$name.png');
      } catch (_) {
        // 에셋 없으면 무시 — 폴백으로 Canvas 렌더링 사용
      }
    }

    _loaded = true;
  }

  /// 이미지 가져오기 (없으면 null)
  ui.Image? getImage(String name) => _images[name];

  /// 스프라이트 시트에서 특정 프레임 영역 반환
  /// [frameIndex] 프레임 인덱스, [frameW]/[frameH] 프레임 크기
  ui.Rect getFrameRect(int frameIndex, double frameW, double frameH, {int row = 0}) {
    return ui.Rect.fromLTWH(
      frameIndex * frameW,
      row * frameH,
      frameW,
      frameH,
    );
  }

  /// Canvas에 스프라이트 프레임 그리기
  /// [dest] 화면상 목적지 Rect (스케일링 적용)
  void drawFrame(
    ui.Canvas canvas,
    String imageName,
    int frameIndex, {
    required double frameW,
    required double frameH,
    required double destX,
    required double destY,
    required double destW,
    required double destH,
    int row = 0,
    bool flipX = false,
    ui.Paint? paint,
  }) {
    final image = _images[imageName];
    if (image == null) return;

    final src = getFrameRect(frameIndex, frameW, frameH, row: row);
    final dst = ui.Rect.fromLTWH(destX, destY, destW, destH);

    if (flipX) {
      canvas.save();
      canvas.translate(destX + destW, destY);
      canvas.scale(-1, 1);
      canvas.drawImageRect(
        image,
        src,
        ui.Rect.fromLTWH(0, 0, destW, destH),
        paint ?? _defaultPaint,
      );
      canvas.restore();
    } else {
      canvas.drawImageRect(image, src, dst, paint ?? _defaultPaint);
    }
  }

  /// 피격 플래시용 (흰색 틴트)
  void drawFrameFlash(
    ui.Canvas canvas,
    String imageName,
    int frameIndex, {
    required double frameW,
    required double frameH,
    required double destX,
    required double destY,
    required double destW,
    required double destH,
    int row = 0,
    bool flipX = false,
  }) {
    drawFrame(
      canvas, imageName, frameIndex,
      frameW: frameW, frameH: frameH,
      destX: destX, destY: destY, destW: destW, destH: destH,
      row: row, flipX: flipX, paint: _flashPaint,
    );
  }

  static final ui.Paint _defaultPaint = ui.Paint();
  static final ui.Paint _flashPaint = ui.Paint()
    ..colorFilter = const ui.ColorFilter.mode(
      ui.Color(0xFFFFFFFF),
      ui.BlendMode.srcATop,
    );

  /// 캐릭터 ID → 스프라이트 이미지 이름 매핑
  static String playerImageName(String characterId) {
    return 'player_$characterId';
  }

  /// 적 타입 → 스프라이트 이미지 이름 매핑
  static String enemyImageName(String typeName) {
    return switch (typeName) {
      'jabgwi' => 'enemy_jabgwi',
      'dokkaebiJol' => 'enemy_dokkaebi_jol',
      'cheonyeoGwisin' => 'enemy_cheonyeo_gwisin',
      'haetaeSeoksang' => 'enemy_haetae',
      'bulyeou' => 'enemy_bulyeou',
      'gapotGwisin' => 'enemy_gapot_gwisin',
      'yacha' => 'enemy_yacha',
      'gureongi' => 'enemy_gureongi',
      'nalssaenDoli' => 'enemy_nalssaen',
      'gangsi' => 'enemy_gangsi',
      _ => 'enemy_jabgwi',
    };
  }

  /// 무기 ID → 투사체 스프라이트 이름 매핑
  static String projectileImageName(String weaponId) {
    return switch (weaponId) {
      // 기본 무기
      'toema_bujeok' => 'proj_bujeok',
      'binyeo_geom' => 'proj_binyeo',
      'sinseong_bangul' => 'proj_bangul',
      'geumgangeo' => 'proj_geumgangeo',
      'hwasal' => 'proj_hwasal',
      'dokkaebi_bul' => 'proj_dokkaebi_bul',
      'dolpalmae' => 'proj_dolpalmae',
      'pungmul_buk' => 'proj_explosion',
      // 진화 무기
      'cheonloe_bujeok' => 'proj_cheonloe',
      'yongcheon_geom' => 'proj_yongcheon',
      'cheongryong_eonwoldo' => 'proj_cheongryong_eon',
      'hangma_geumgangeo' => 'proj_hangma',
      'cheonji_bangul' => 'proj_cheonji',
      'samulnori' => 'proj_samulnori',
      'gumiho_baltop' => 'proj_gumiho',
      'taegeukjin' => 'proj_taegeuk',
      'singung' => 'proj_singung',
      'hwangcheon_dokmu' => 'proj_hwangcheon',
      'bulgasari' => 'proj_bulgasari',
      'sammae_jinhwa' => 'proj_sammae',
      _ => 'proj_bujeok',
    };
  }
}
