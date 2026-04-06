import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../game/toemalok_game.dart';
import '../../utils/tuning_params.dart';

class DebugPanel extends StatefulWidget {
  final ToemalokGame game;

  const DebugPanel({super.key, required this.game});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black87,
                child: Text(
                  _expanded ? '▼ Debug' : '▶ Debug',
                  style: const TextStyle(color: Colors.yellow, fontSize: 12),
                ),
              ),
            ),
            if (_expanded) _buildPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      width: 260,
      height: 300,
      color: Colors.black87,
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          _info('적: ${widget.game.enemyManager.activeEnemies.length}'),
          _info('투사체: ${widget.game.projectileManager.activeProjectiles.length}'),
          _info('기운: ${widget.game.expGemManager.activeGems.length}'),
          const Divider(color: Colors.white24),
          _slider('Shake', TuningParams.shakeIntensity, 0, 20,
              (v) => TuningParams.shakeIntensity = v),
          _slider('Knockback', TuningParams.knockbackForce, 0, 400,
              (v) => TuningParams.knockbackForce = v),
          _slider('Magnet Speed', TuningParams.magnetSpeed, 100, 800,
              (v) => TuningParams.magnetSpeed = v),
          _slider('Camera Lag', TuningParams.cameraLag, 0, 1,
              (v) => TuningParams.cameraLag = v),
          _slider('Deadzone', TuningParams.joystickDeadZone, 0, 0.5,
              (v) => TuningParams.joystickDeadZone = v),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => TuningParams.resetDefaults()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.red.shade900,
              child: const Center(
                child: Text('Reset Defaults', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11));
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white, fontSize: 10)),
        SizedBox(
          height: 20,
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: (v) => setState(() => onChanged(v)),
          ),
        ),
      ],
    );
  }
}
