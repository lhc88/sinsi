import 'package:flutter/material.dart';
import '../../data/characters.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';

class SkillTreeScreen extends StatefulWidget {
  final String characterId;

  const SkillTreeScreen({super.key, required this.characterId});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  final _save = SaveService.instance;

  CharacterData get _char => characterTable[widget.characterId]!;

  @override
  Widget build(BuildContext context) {
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
                  Text('${_char.name} 스킬 트리',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.auto_awesome, color: Color(0xFF7EC850), size: 18),
                  const SizedBox(width: 4),
                  Text(_save.doryeok.toString(), style: const TextStyle(color: Color(0xFF7EC850), fontSize: 16)),
                ],
              ),
            ),
            // 스킬 패스 3개
            Expanded(
              child: Row(
                children: List.generate(_char.skillTree.length, (pathIdx) {
                  final path = _char.skillTree[pathIdx];
                  final currentLevel = _save.getSkillLevel(widget.characterId, pathIdx);
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D3557),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(path.name,
                              style: const TextStyle(color: Color(0xFFFFD166), fontSize: 13, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ...List.generate(path.nodes.length, (nodeIdx) {
                            final node = path.nodes[nodeIdx];
                            final unlocked = currentLevel > nodeIdx;
                            final canUnlock = currentLevel == nodeIdx && _save.doryeok >= node.doryeokCost;
                            final isNext = currentLevel == nodeIdx;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: canUnlock ? () => _unlock(pathIdx, nodeIdx, node.doryeokCost) : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: unlocked
                                        ? const Color(0xFF3E8948)
                                        : isNext
                                            ? const Color(0xFF2A4A6B)
                                            : const Color(0xFF111827),
                                    borderRadius: BorderRadius.circular(8),
                                    border: canUnlock
                                        ? Border.all(color: const Color(0xFF7EC850), width: 2)
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        node.description,
                                        style: TextStyle(
                                          color: unlocked ? Colors.white : Colors.white70,
                                          fontSize: 11,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        unlocked ? '활성화됨' : '도력 ${node.doryeokCost}',
                                        style: TextStyle(
                                          color: unlocked
                                              ? const Color(0xFF7EC850)
                                              : canUnlock
                                                  ? const Color(0xFFFFD166)
                                                  : Colors.white38,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          // 연결선
                          if (currentLevel < path.nodes.length)
                            Text(
                              'Lv.$currentLevel/${path.nodes.length}',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unlock(int pathIdx, int nodeIdx, int cost) {
    _save.doryeok = _save.doryeok - cost;
    _save.setSkillLevel(widget.characterId, pathIdx, nodeIdx + 1);
    setState(() {});
  }
}
