import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/passives.dart';
import '../../data/weapons.dart';
import '../../game/toemalok_game.dart';
import '../../services/audio_service.dart';
import '../../systems/evolution_system.dart';

class PauseOverlay extends StatelessWidget {
  final ToemalokGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final hints = game.evolutionSystem.getEvolutionHints(
      game.weaponManager, game.levelUpSystem,
    );

    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '일시정지',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            // 진화 힌트
            if (hints.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D3557),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('진화 가능 무기', style: TextStyle(color: Color(0xFFFFD166), fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...hints.take(4).map((h) => _hintRow(h)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _button('계속하기', const Color(0xFF3E8948), () => game.resumeGame()),
            const SizedBox(height: 12),
            _button('다시 하기', const Color(0xFFE63946), () => game.restartGame()),
            const SizedBox(height: 12),
            _button('메뉴로', const Color(0xFF457B9D), () {
              game.resumeGame();
              Navigator.of(context).pop();
            }),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              _button('디버그 패널', const Color(0xFF666666), () {
                if (game.overlays.isActive('debug')) {
                  game.overlays.remove('debug');
                } else {
                  game.overlays.add('debug');
                }
                game.resumeGame();
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hintRow(EvolutionHint h) {
    final weaponName = weaponTable[h.sourceWeapon]?.name ?? h.sourceWeapon;
    final passiveName = passiveTable[h.requiredPassive]?.name ?? h.requiredPassive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            h.isReady ? Icons.check_circle : Icons.radio_button_unchecked,
            color: h.isReady ? const Color(0xFF7EC850) : Colors.white38,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${h.evolutionName}: $weaponName Lv.${h.weaponLevel}/8 + $passiveName ${h.hasPassive ? "✓" : "✗"}',
              style: TextStyle(
                color: h.isReady ? const Color(0xFF7EC850) : Colors.white60,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { AudioService.uiClick(); onTap(); },
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
