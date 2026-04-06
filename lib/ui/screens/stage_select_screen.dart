import 'package:flutter/material.dart';
import '../../data/stages.dart';
import '../../data/game_modes.dart';
import '../../services/save_service.dart';
import '../../main.dart';
import '../../services/audio_service.dart';
import '../shared/page_transition.dart';

class StageSelectScreen extends StatefulWidget {
  final String characterId;

  const StageSelectScreen({super.key, required this.characterId});

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  int _selectedStage = 0;
  int _selectedMode = 0;
  final _save = SaveService.instance;

  static const _stageKeys = ['stage1', 'stage2', 'stage3', 'stage4', 'stage5', 'bonus1', 'bonus2'];
  static const _modeKeys = ['normal', 'gwangran', 'muhan', 'gwimun', 'yeokhaeng'];

  bool _isStageUnlocked(int index) {
    if (index == 0) return true;
    final key = _stageKeys[index];
    return _save.isStageUnlocked(key);
  }

  bool _isModeUnlocked(int index) {
    return SaveService.instance.isModeUnlocked(_modeKeys[index]);
  }

  @override
  Widget build(BuildContext context) {
    final stage = stageTable[_stageKeys[_selectedStage]]!;
    final mode = gameModeTable[_modeKeys[_selectedMode]]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { AudioService.uiBack(); Navigator.pop(context); },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text('스테이지 선택',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // 스테이지 리스트
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('스테이지', style: TextStyle(color: Color(0xFFFFD166), fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allStages.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (ctx, i) {
                  final s = allStages[i];
                  final unlocked = _isStageUnlocked(i);
                  final selected = i == _selectedStage;
                  return GestureDetector(
                    onTap: unlocked ? () => setState(() => _selectedStage = i) : null,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF457B9D) : const Color(0xFF1D3557),
                        borderRadius: BorderRadius.circular(8),
                        border: selected ? Border.all(color: const Color(0xFFFFD166), width: 2) : null,
                      ),
                      child: Center(
                        child: Text(
                          unlocked ? s.name : '???',
                          style: TextStyle(
                            color: unlocked ? Colors.white : Colors.white38,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 스테이지 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(stage.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Text('${(stage.duration / 60).toInt()}분', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(width: 12),
                  Text('보스 ${stage.bosses.length}', style: const TextStyle(color: Color(0xFFE63946), fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 게임 모드
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('게임 모드', style: TextStyle(color: Color(0xFFFFD166), fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _modeKeys.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (ctx, i) {
                  final m = gameModeTable[_modeKeys[i]]!;
                  final unlocked = _isModeUnlocked(i);
                  final selected = i == _selectedMode;
                  return GestureDetector(
                    onTap: unlocked ? () => setState(() => _selectedMode = i) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF3E8948) : const Color(0xFF1D3557),
                        borderRadius: BorderRadius.circular(8),
                        border: selected ? Border.all(color: const Color(0xFFFFD166), width: 2) : null,
                      ),
                      child: Center(
                        child: Text(
                          unlocked ? m.name : '???',
                          style: TextStyle(
                            color: unlocked ? Colors.white : Colors.white38,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(mode.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ),

            const Spacer(),

            // 출발 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    GamePageRoute(page: GamePage(
                      characterId: widget.characterId,
                      stageId: _stageKeys[_selectedStage],
                      modeId: _modeKeys[_selectedMode],
                    )),
                  );
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFE63946).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(
                    child: Text('출발!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
