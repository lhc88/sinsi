import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/achievements.dart';
import '../../data/enemies.dart' as game_data;
import '../../game/toemalok_game.dart';
import '../../utils/constants.dart';

class HudOverlay extends StatefulWidget {
  final ToemalokGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  String? _achievementText;
  double _achievementTimer = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final stats = widget.game.player.stats;

        // 업적 알림 처리
        if (widget.game.achievementQueue.isNotEmpty && _achievementText == null) {
          _achievementText = widget.game.achievementQueue.removeAt(0);
          _achievementTimer = 3.0;
        }
        if (_achievementTimer > 0) {
          _achievementTimer -= 0.016; // ~60fps
          if (_achievementTimer <= 0) _achievementText = null;
        }

        return IgnorePointer(
          child: Stack(
            children: [
              // 화면 필 이펙트 (전체 화면)
              if (widget.game.screenFlashColor != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: widget.game.screenFlashColor!.withValues(
                        alpha: widget.game.screenFlashAlpha * 0.5,
                      ),
                    ),
                  ),
                ),
              // 이벤트 활성 표시
              if (widget.game.eventSystem.activeEvent != null)
                Positioned(
                  top: 60, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xCC1D3557),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD166), width: 1),
                      ),
                      child: Text(
                        '${widget.game.eventSystem.eventName(widget.game.eventSystem.activeEvent!)} ${widget.game.eventSystem.eventTimer.ceil()}s',
                        style: const TextStyle(color: Color(0xFFFFD166), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              // HUD 본체
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _topBar(stats),
                      if (_achievementText != null) _achievementBanner(),
                      if (widget.game.dailyChallengeProgress != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xCC1D3557),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA8DADC), width: 0.5),
                          ),
                          child: Text(
                            widget.game.dailyChallengeProgress!,
                            style: const TextStyle(color: Color(0xFFA8DADC), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (widget.game.stageNotification != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xCCE63946),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.game.stageNotification!,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      // 보스 HP바
                      if (widget.game.activeBosses.any((b) => !b.isDead))
                        _bossHpBar(),
                      // 시너지 활성 표시
                      if (widget.game.activeSynergyNames.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            children: widget.game.activeSynergyNames.map((name) =>
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0x661D3557),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0x66A8DADC)),
                                ),
                                child: Text(name, style: const TextStyle(color: Color(0xFFA8DADC), fontSize: 9)),
                              ),
                            ).toList(),
                          ),
                        ),
                      const Spacer(),
                      // 미니맵 (우하단)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _minimap(),
                      ),
                      const SizedBox(height: 4),
                      _weaponBar(),
                      const SizedBox(height: 4),
                      _expBar(stats),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(dynamic stats) {
    return Row(
      children: [
        // HP바
        Expanded(flex: 3, child: _hpBar(stats.hpPercent as double)),
        const SizedBox(width: 12),
        // 타이머
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              widget.game.gameTimeString,
              style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 킬 카운트 + 시너지
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.dangerous, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.killCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              if (stats.synergyDamageBonus > 0)
                Text(
                  '시너지 +${(stats.synergyDamageBonus * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFFFFD166), fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hpBar(double percent) {
    final stats = widget.game.player.stats;
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1D3557),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFC0C0C0)),
          ),
          child: const Center(
            child: Text('退', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        percent < 0.3 ? const Color(0xFFFF0000) : const Color(0xFFE63946),
                        const Color(0xFFFF8C42),
                      ]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${stats.currentHp.toInt()} / ${stats.maxHp.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _weaponBar() {
    final weapons = widget.game.weaponManager.weapons;
    if (weapons.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: weapons.map((w) {
        final info = w.info;
        final elemColor = _elementColor(info.element);
        return Container(
          width: 32, height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1D3557),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: elemColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              info.name.isNotEmpty ? info.name[0] : '?',
              style: TextStyle(color: elemColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _elementColor(game_data.Element elem) {
    return switch (elem) {
      game_data.Element.fire => const Color(0xFFE63946),
      game_data.Element.water => const Color(0xFF457B9D),
      game_data.Element.wood => const Color(0xFF3E8948),
      game_data.Element.metal => const Color(0xFFC0C0C0),
      game_data.Element.earth => const Color(0xFFD4A574),
      game_data.Element.none => const Color(0xFF888888),
    };
  }

  Widget _minimap() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0x881D3557),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x44FFFFFF), width: 0.5),
      ),
      child: CustomPaint(
        painter: _MinimapPainter(game: widget.game),
      ),
    );
  }

  Widget _achievementBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC1D3557),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD166), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFFFD166), size: 16),
          const SizedBox(width: 6),
          Text(
            '업적 달성: ${achievementTable[_achievementText]?.name ?? _achievementText}',
            style: const TextStyle(color: Color(0xFFFFD166), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _bossHpBar() {
    final boss = widget.game.activeBosses.where((b) => !b.isDead).firstOrNull;
    if (boss == null) return const SizedBox.shrink();
    final hpRatio = (boss.hp / boss.maxHp).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            boss.data.name,
            style: const TextStyle(color: Color(0xFFE63946), fontSize: 13, fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
          ),
          const SizedBox(height: 2),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0x66E63946)),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: hpRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        hpRatio < 0.3 ? const Color(0xFFFF0000) : const Color(0xFFE63946),
                        const Color(0xFFFF4444),
                      ]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${boss.hp.toInt()} / ${boss.maxHp.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expBar(dynamic stats) {
    return Container(
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (stats.expPercent as double).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3E8948), Color(0xFF7EC850)]),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Center(
            child: Text(
              'Lv.${stats.level}',
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  final ToemalokGame game;
  _MinimapPainter({required this.game});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / worldWidth;
    final scaleY = size.height / worldHeight;

    // 적 (작은 회색 점, 최대 50개만 표시하여 성능 보호)
    final enemyPaint = Paint()..color = const Color(0x66FFFFFF);
    final enemies = game.enemyManager.activeEnemies;
    final step = math.max(1, enemies.length ~/ 50);
    for (int i = 0; i < enemies.length; i += step) {
      final e = enemies[i];
      if (!e.isActive) continue;
      canvas.drawCircle(
        Offset(e.position.x * scaleX, e.position.y * scaleY),
        0.8,
        enemyPaint,
      );
    }

    // 보물상자 (금색)
    final chestPaint = Paint()..color = const Color(0xFFFFD166);
    for (final chest in game.activeChests) {
      if (chest.isOpened) continue;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(chest.position.x * scaleX, chest.position.y * scaleY),
          width: 3, height: 3,
        ),
        chestPaint,
      );
    }

    // 보스 (빨간 삼각형 크게)
    final bossPaint = Paint()..color = const Color(0xFFE63946);
    for (final boss in game.activeBosses) {
      if (boss.isDead) continue;
      final bx = boss.position.x * scaleX;
      final by = boss.position.y * scaleY;
      canvas.drawCircle(Offset(bx, by), 3, bossPaint);
    }

    // 플레이어 (중앙 하얀 점)
    final playerPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(
      Offset(game.player.position.x * scaleX, game.player.position.y * scaleY),
      2.5,
      playerPaint,
    );

    // 저승사자 (큰 보라 점)
    if (game.isReaperActive) {
      final rx = game.reaperPosition.x * scaleX;
      final ry = game.reaperPosition.y * scaleY;
      final reaperPaint = Paint()
        ..color = const Color(0xFF8800FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(rx, ry), 4, reaperPaint);
    }

    // 엘리트 적 (큰 주황 점)
    final elitePaint = Paint()..color = const Color(0xFFFF8800);
    for (int i = 0; i < enemies.length; i++) {
      final e = enemies[i];
      if (!e.isActive || !e.isElite) continue;
      canvas.drawCircle(
        Offset(e.position.x * scaleX, e.position.y * scaleY),
        1.5,
        elitePaint,
      );
    }

    // 카메라 뷰 범위 표시 (사각형)
    final viewPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final px = game.player.position.x * scaleX;
    final py = game.player.position.y * scaleY;
    final viewW = 800 * scaleX / 2;
    final viewH = 480 * scaleY / 2;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(px, py), width: viewW * 2, height: viewH * 2),
      viewPaint,
    );

    // 화면 밖 보스/상자 방향 화살표 (미니맵 테두리에)
    for (final boss in game.activeBosses) {
      if (boss.isDead) continue;
      _drawEdgeArrow(canvas, size, px, py, viewW, viewH,
          boss.position.x * scaleX, boss.position.y * scaleY, bossPaint);
    }
    for (final chest in game.activeChests) {
      if (chest.isOpened) continue;
      _drawEdgeArrow(canvas, size, px, py, viewW, viewH,
          chest.position.x * scaleX, chest.position.y * scaleY, chestPaint);
    }
  }

  void _drawEdgeArrow(Canvas canvas, Size size, double px, double py,
      double vw, double vh, double tx, double ty, Paint paint) {
    // 미니맵 범위 내이면 스킵
    if ((tx - px).abs() < vw && (ty - py).abs() < vh) return;

    // 방향 벡터
    final dx = tx - px;
    final dy = ty - py;
    final angle = math.atan2(dy, dx);
    final edgeX = (size.width / 2 + math.cos(angle) * (size.width / 2 - 4)).clamp(2.0, size.width - 2);
    final edgeY = (size.height / 2 + math.sin(angle) * (size.height / 2 - 4)).clamp(2.0, size.height - 2);

    // 작은 삼각형 화살표
    final path = Path()
      ..moveTo(edgeX + math.cos(angle) * 4, edgeY + math.sin(angle) * 4)
      ..lineTo(edgeX + math.cos(angle + 2.5) * 3, edgeY + math.sin(angle + 2.5) * 3)
      ..lineTo(edgeX + math.cos(angle - 2.5) * 3, edgeY + math.sin(angle - 2.5) * 3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
