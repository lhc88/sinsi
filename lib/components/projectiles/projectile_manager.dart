import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'projectile_instance.dart';
import '../../data/enemies.dart';
import '../../utils/object_pool.dart';
import '../../utils/sprite_painter.dart';
import '../../utils/sprite_loader.dart';

class ProjectileManager extends Component {
  late final ObjectPool<ProjectileInstance> pool;
  double _time = 0;

  ProjectileManager() {
    pool = ObjectPool<ProjectileInstance>(
      create: () => ProjectileInstance(),
      reset: (p) => p.reset(),
      initialSize: 100,
    );
  }

  /// 최대 활성 투사체 수
  static const int maxActiveProjectiles = 150;

  List<ProjectileInstance> get activeProjectiles => pool.active;

  ProjectileInstance spawn({
    required String weaponId,
    required Vector2 position,
    required Vector2 velocity,
    required double damage,
    double maxLifetime = 3,
    double area = 24,
    int pierce = 0,
    double size = 12,
    Element element = Element.none,
    bool homing = false,
  }) {
    // 상한 도달 시 가장 오래된 투사체 제거
    if (pool.active.length >= maxActiveProjectiles) {
      final oldest = pool.active.first;
      oldest.isActive = false;
      pool.release(oldest);
    }
    final proj = pool.acquire();
    proj.init(
      weapon: weaponId,
      pos: position,
      vel: velocity,
      dmg: damage,
      maxLife: maxLifetime,
      hitArea: area,
      pierceCount: pierce,
      sz: size,
      elem: element,
    );
    proj.homing = homing;
    return proj;
  }

  /// 외부에서 적 목록을 주입 (매 프레임 toemalok_game에서 호출)
  List<dynamic>? _enemiesRef;
  void setEnemiesRef(List<dynamic> enemies) => _enemiesRef = enemies;

  @override
  void update(double dt) {
    _time += dt;
    for (final proj in pool.active.toList()) {
      if (!proj.isActive) continue;

      proj.lifetime += dt;
      if (proj.isExpired) {
        pool.release(proj);
        continue;
      }

      // 호밍: 가장 가까운 적 방향으로 유도
      if (proj.homing && _enemiesRef != null) {
        _applyHoming(proj, dt);
      }

      proj.position += proj.velocity * dt;
    }
  }

  void _applyHoming(ProjectileInstance proj, double dt) {
    const double turnSpeed = 4.0; // 초당 회전 라디안
    double bestDist = double.infinity;
    Vector2? bestPos;

    for (final enemy in _enemiesRef!) {
      if (!(enemy.isActive as bool)) continue;
      final dist = (enemy.position as Vector2).distanceTo(proj.position);
      if (dist < bestDist && dist < 400) {
        bestDist = dist;
        bestPos = enemy.position as Vector2;
      }
    }
    if (bestPos == null) return;

    final desired = (bestPos - proj.position).normalized();
    final currentSpeed = proj.velocity.length;
    if (currentSpeed < 1) return;

    final current = proj.velocity.normalized();
    // lerp 방향
    final newDir = (current + desired * turnSpeed * dt).normalized();
    proj.velocity = newDir * currentSpeed;
  }

  void killProjectile(ProjectileInstance proj) {
    proj.isActive = false;
    pool.release(proj);
  }

  void clearAll() {
    pool.releaseAll();
  }

  int _frameIndex = 0;
  double _frameTimer = 0;
  double _camX = 0, _camY = 0;

  void updateCamera(double camX, double camY) {
    _camX = camX;
    _camY = camY;
  }

  @override
  void render(Canvas canvas) {
    _frameTimer += 0.016;
    if (_frameTimer >= 0.1) {
      _frameTimer = 0;
      _frameIndex = (_frameIndex + 1) % 4;
    }

    final loader = SpriteLoader.instance;

    for (final proj in pool.active) {
      if (!proj.isActive) continue;

      final cx = proj.position.x;
      final cy = proj.position.y;

      // 화면 밖 컬링
      if ((cx - _camX).abs() > 480 || (cy - _camY).abs() > 320) continue;

      final s = proj.size;

      final imgName = SpriteLoader.projectileImageName(proj.weaponId);
      final hasSprite = loader.getImage(imgName) != null;

      if (hasSprite) {
        final destSize = s * 2.5;
        loader.drawFrame(canvas, imgName, _frameIndex,
            frameW: 16, frameH: 16,
            destX: cx - destSize / 2, destY: cy - destSize / 2,
            destW: destSize, destH: destSize);
      } else {
        final angle = atan2(proj.velocity.y, proj.velocity.x);
        switch (proj.weaponId) {
          case 'binyeo_geom' || 'yongcheon_geom':
            SpritePainter.drawBinyeoGeom(canvas, cx, cy, s, angle, _time);
          case 'dokkaebi_bul' || 'sammae_jinhwa':
            SpritePainter.drawWillOWisp(canvas, cx, cy, s, _time);
          case 'cheondung':
            SpritePainter.drawShockwave(canvas, cx, cy, s, _time);
          case 'punggyeong':
            SpritePainter.drawSoundWave(canvas, cx, cy, s, _time);
          case 'cheongryongdo' || 'cheongryong_eonwoldo':
            SpritePainter.drawCheongryongdo(canvas, cx, cy, s, _time);
          case 'geumgangeo' || 'hangma_geumgangeo':
            SpritePainter.drawGeumgangeo(canvas, cx, cy, s, angle, _time);
          case 'sinseong_bangul' || 'cheonji_bangul':
            SpritePainter.drawBangul(canvas, cx, cy, s, _time);
          case 'pungmul_buk' || 'samulnori':
            SpritePainter.drawPungmulBuk(canvas, cx, cy, s, _time);
          case 'yogi_baltop' || 'gumiho_baltop':
            SpritePainter.drawYogiBaltop(canvas, cx, cy, s, angle, _time);
          case 'palgwaejin' || 'taegeukjin':
            SpritePainter.drawPalgwaejin(canvas, cx, cy, s, _time);
          case 'hwasal' || 'singung':
            SpritePainter.drawHwasal(canvas, cx, cy, s, angle, _time);
          case 'dokangae' || 'hwangcheon_dokmu':
            SpritePainter.drawDokangae(canvas, cx, cy, s, _time);
          case 'dolpalmae' || 'bulgasari':
            SpritePainter.drawDolpalmae(canvas, cx, cy, s, _time);
          default:
            SpritePainter.drawBujeokProjectile(canvas, cx, cy, s, _time);
        }
      }
    }
  }
}
