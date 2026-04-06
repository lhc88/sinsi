import 'package:flutter/material.dart';
import '../../game/toemalok_game.dart';
import '../../main.dart';
import '../../services/audio_service.dart';
import '../shared/page_transition.dart';

class VictoryOverlay extends StatefulWidget {
  final ToemalokGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with TickerProviderStateMixin {
  static const _stageOrder = ['stage1', 'stage2', 'stage3', 'stage4', 'stage5'];

  String? get _nextStageId {
    final idx = _stageOrder.indexOf(widget.game.stageId);
    if (idx >= 0 && idx < _stageOrder.length - 1) return _stageOrder[idx + 1];
    return null;
  }

  late AnimationController _controller;
  late Animation<double> _titleAnim;
  late Animation<double> _subtitleAnim;
  late List<Animation<double>> _statAnims;
  late Animation<double> _buttonAnim;
  late AnimationController _countController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _titleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
    );

    _subtitleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.25, curve: Curves.easeOut),
    );

    _statAnims = List.generate(8, (i) {
      final start = 0.2 + i * 0.08;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, (start + 0.12).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });

    _buttonAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _countController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _countController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.game.player.stats;
    final nextStage = _nextStageId;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        color: Color.lerp(Colors.transparent, Colors.black87, _titleAnim.value),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀 (금빛 쉬머)
              Transform.scale(
                scale: _titleAnim.value,
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: const [
                          Color(0xFFFFD166),
                          Color(0xFFFFFFFF),
                          Color(0xFFFFD166),
                        ],
                        stops: [
                          (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                          _shimmerController.value,
                          (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        '퇴마 성공!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _subtitleAnim,
                child: const Text('요괴를 모두 물리쳤습니다',
                    style: TextStyle(color: Color(0xFFA8DADC), fontSize: 14)),
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
              const SizedBox(height: 32),
              // 버튼
              FadeTransition(
                opacity: _buttonAnim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(_buttonAnim),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (nextStage != null)
                        _button('다음 스테이지', const Color(0xFF3E8948), () {
                          Navigator.of(context).pushReplacement(
                            GamePageRoute(page: GamePage(
                              characterId: widget.game.characterId,
                              stageId: nextStage,
                              modeId: widget.game.modeId,
                            )),
                          );
                        }),
                      if (nextStage != null) const SizedBox(width: 16),
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
