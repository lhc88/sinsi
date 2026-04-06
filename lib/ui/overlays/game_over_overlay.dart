import 'package:flutter/material.dart';
import '../../game/toemalok_game.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';

class GameOverOverlay extends StatefulWidget {
  final ToemalokGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnim;
  late List<Animation<double>> _statAnims;
  late Animation<double> _buttonAnim;

  // 카운팅 애니메이션용
  late AnimationController _countController;
  bool _adUsed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _titleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
    );

    // 8개 스탯 순차 등장
    _statAnims = List.generate(8, (i) {
      final start = 0.15 + i * 0.1;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, (start + 0.15).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _buttonAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _countController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.game.player.stats;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        color: Color.lerp(Colors.transparent, Colors.black87, _titleAnim.value),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀
              Transform.scale(
                scale: _titleAnim.value,
                child: const Text(
                  '퇴마 실패',
                  style: TextStyle(
                    color: Color(0xFFE63946),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 12, color: Color(0xFFE63946))],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 스탯 순차 표시
              _animatedStat('생존 시간', widget.game.gameTimeString, 0, isRecord: widget.game.isNewBestTime),
              _animatedStat('처치 수', '${stats.killCount}', 1, isRecord: widget.game.isNewBestKills),
              _animatedStat('도달 레벨', 'Lv.${stats.level}', 2),
              _animatedStat('무기', '${widget.game.weaponManager.weapons.length}종', 3),
              _animatedStat('총 데미지', _formatNumber(stats.totalDamageDealt), 4),
              _animatedStat('최대 연쇄', '${stats.bestKillStreak}', 5),
              _countingStat('획득 엽전', widget.game.lastCoinsEarned, 6),
              _countingStat('획득 도력', widget.game.lastDoryeokEarned, 7),
              const SizedBox(height: 16),
              // 광고 버튼
              if (AdService.instance.isRewardedAdReady && !_adUsed)
                FadeTransition(
                  opacity: _buttonAnim,
                  child: Column(
                    children: [
                      _adButton('광고 시청: 엽전 2배', Icons.play_circle, const Color(0xFF9B59B6), () {
                        AdService.instance.showRewardedAd(onReward: (type, amount) {
                          SaveService.instance.coins = SaveService.instance.coins + widget.game.lastCoinsEarned;
                          widget.game.lastCoinsEarned *= 2;
                          setState(() { _adUsed = true; });
                        });
                      }),
                      const SizedBox(height: 8),
                      _adButton('광고 시청: 귀혼석 +1', Icons.diamond, const Color(0xFFBB86FC), () {
                        AdService.instance.showRewardedAd(onReward: (type, amount) {
                          SaveService.instance.soulStones = SaveService.instance.soulStones + 1;
                          setState(() { _adUsed = true; });
                        });
                      }),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              // 버튼
              FadeTransition(
                opacity: _buttonAnim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(_buttonAnim),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _button('다시 하기', const Color(0xFFE63946), () {
                        widget.game.restartGame();
                      }),
                      const SizedBox(width: 16),
                      _button('메뉴로', const Color(0xFF457B9D), () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedStat(String label, String value, int index, {bool isRecord = false}) {
    final anim = _statAnims[index];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(-0.3, 0), end: Offset.zero).animate(anim),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _stat(label, value),
            if (isRecord) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('NEW!', style: TextStyle(color: Color(0xFF1D3557), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _countingStat(String label, int targetValue, int index) {
    final anim = _statAnims[index];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(-0.3, 0), end: Offset.zero).animate(anim),
        child: AnimatedBuilder(
          animation: _countController,
          builder: (context, _) {
            final current = (targetValue * _countController.value).round();
            return _stat(label, '+$current');
          },
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16))),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }

  Widget _adButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService.playSfx('ui_click');
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService.playSfx('ui_click');
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
