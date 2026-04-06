import 'package:flutter/material.dart' hide Element;
import '../../data/daily_challenge.dart';
import '../../data/enemies.dart';
import '../../data/weapons.dart';
import '../../game/toemalok_game.dart';
import '../../services/audio_service.dart';
import '../../systems/level_up_system.dart';

class LevelUpOverlay extends StatefulWidget {
  final ToemalokGame game;

  const LevelUpOverlay({super.key, required this.game});

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late List<LevelUpChoice> choices;
  late AnimationController _enterController;
  late AnimationController _pulseController;
  late Animation<double> _titleScale;
  final List<Animation<double>> _cardAnimations = [];

  @override
  void initState() {
    super.initState();
    // 일일 도전 원소/패시브 제한
    final dc = widget.game.dailyChallenge;
    final onlyElem = dc != null
        ? switch (dc.rule) {
            DailyChallengeRule.onlyFire => Element.fire,
            DailyChallengeRule.onlyWater => Element.water,
            _ => null,
          }
        : null;
    final noPas = dc?.rule == DailyChallengeRule.noPassive;
    choices = widget.game.levelUpSystem.generateChoices(
      widget.game.weaponManager,
      extraChoices: widget.game.player.stats.skillExtraChoices,
      onlyElement: onlyElem,
      noPassive: noPas,
    );

    // 입장 애니메이션
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 타이틀 바운스
    _titleScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));

    // 카드 순차 등장 (stagger)
    for (int i = 0; i < choices.length; i++) {
      final start = 0.2 + i * 0.15;
      final end = (start + 0.4).clamp(0.0, 1.0);
      _cardAnimations.add(
        CurvedAnimation(
          parent: _enterController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    }

    // 펄스 (선택 유도)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _elementColor(String weaponId) {
    final data = weaponTable[weaponId];
    if (data == null) return const Color(0xFFE63946);
    return switch (data.element) {
      Element.wood => const Color(0xFF3E8948),
      Element.fire => const Color(0xFFE63946),
      Element.earth => const Color(0xFFC89B3C),
      Element.metal => const Color(0xFFA8DADC),
      Element.water => const Color(0xFF457B9D),
      Element.none => const Color(0xFFE63946),
    };
  }

  String _elementIcon(String weaponId) {
    final data = weaponTable[weaponId];
    if (data == null) return '⚔';
    return switch (data.element) {
      Element.wood => '🌿',
      Element.fire => '🔥',
      Element.earth => '⛰',
      Element.metal => '⚔',
      Element.water => '💧',
      Element.none => '⚔',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enterController,
      builder: (context, _) => Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀
              ScaleTransition(
                scale: _titleScale,
                child: Column(
                  children: [
                    const Text(
                      '레벨 업!',
                      style: TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 8, color: Color(0xFFFFD166))],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lv.${widget.game.player.stats.level}',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 카드들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < choices.length; i++)
                    _buildAnimatedCard(choices[i], i),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(LevelUpChoice choice, int index) {
    final anim = index < _cardAnimations.length
        ? _cardAnimations[index]
        : _enterController;

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final value = anim.value;
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: _buildCard(choice),
          ),
        );
      },
    );
  }

  Widget _buildCard(LevelUpChoice choice) {
    final borderColor = choice.isNew
        ? const Color(0xFFFFD166)
        : choice.isWeapon
            ? _elementColor(choice.id)
            : const Color(0xFF7EC850);

    final iconBgColor = choice.isWeapon
        ? _elementColor(choice.id)
        : const Color(0xFF3E8948);

    return GestureDetector(
      onTap: () => _onChoose(choice),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _pulseController.value * 0.15;
          return Container(
            width: 150,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1D3557),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.3 + pulse),
                  blurRadius: 12 + pulse * 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 신규/레벨 뱃지
                if (choice.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '신규',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Lv.${choice.currentLevel + 1} → ${choice.currentLevel + 2}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ),
                const SizedBox(height: 6),
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: iconBgColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      choice.isWeapon ? _elementIcon(choice.id) : '✦',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  choice.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  choice.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onChoose(LevelUpChoice choice) {
    AudioService.uiClick();
    widget.game.levelUpSystem.applyChoice(
      choice,
      widget.game.weaponManager,
      widget.game.player.stats,
    );
    widget.game.onLevelUpChoiceMade();
  }
}
