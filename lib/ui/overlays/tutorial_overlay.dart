import 'package:flutter/material.dart';
import '../../game/toemalok_game.dart';
import '../../services/save_service.dart';

enum TutorialStep {
  move,        // 조이스틱 이동
  autoAttack,  // 자동 공격
  collectGi,   // 기운 수집
  levelUp,     // 레벨업 카드
  boss,        // 보스 경고
  chest,       // 상자 개봉
  powerUp,     // 영구 강화
}

class TutorialOverlay extends StatefulWidget {
  final ToemalokGame game;

  const TutorialOverlay({super.key, required this.game});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  TutorialStep _step = TutorialStep.move;

  String get _message => switch (_step) {
    TutorialStep.move => '화면 왼쪽 하단의 조이스틱으로\n캐릭터를 이동하세요',
    TutorialStep.autoAttack => '무기는 자동으로 공격합니다!\n요괴를 물리치세요',
    TutorialStep.collectGi => '적이 떨어뜨린 기운(초록 보석)을\n가까이 가서 수집하세요',
    TutorialStep.levelUp => '레벨업! 카드를 선택하여\n무기나 패시브를 강화하세요',
    TutorialStep.boss => '⚠ 보스가 나타났습니다!\n조심하세요',
    TutorialStep.chest => '보물상자를 가까이 가서\n열어보세요',
    TutorialStep.powerUp => '엽전으로 영구 강화를 구매하면\n다음 세션에서 더 강해집니다',
  };

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD166), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _message,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _nextStep,
                child: const Text(
                  '확인',
                  style: TextStyle(color: Color(0xFFFFD166), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    final nextIndex = _step.index + 1;
    if (nextIndex >= TutorialStep.values.length) {
      widget.game.overlays.remove('tutorial');
      SaveService.instance.tutorialDone = true;
      return;
    }
    setState(() {
      _step = TutorialStep.values[nextIndex];
    });
  }
}
