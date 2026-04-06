import 'package:flutter/material.dart';
import '../../data/characters.dart';
import '../../data/cosmetics.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';
import '../shared/page_transition.dart';
import 'stage_select_screen.dart';
import 'skill_tree_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  int _selectedIndex = 0;
  final _characters = characterTable.values.toList();
  final _save = SaveService.instance;

  bool _isUnlocked(int index) {
    if (index == 0) return true; // 첫 캐릭터는 항상 해금
    return _save.isCharacterUnlocked(_characters[index].id);
  }

  @override
  Widget build(BuildContext context) {
    final char = _characters[_selectedIndex];

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
                  const Text('퇴마사 선택', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // 캐릭터 리스트 (가로 스크롤)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _characters.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (ctx, i) {
                  final c = _characters[i];
                  final selected = i == _selectedIndex;
                  final unlocked = _isUnlocked(i);
                  return GestureDetector(
                    onTap: unlocked ? () => setState(() => _selectedIndex = i) : null,
                    child: Container(
                      width: 64, height: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: !unlocked
                            ? const Color(0xFF111111)
                            : selected
                                ? const Color(0xFF457B9D)
                                : const Color(0xFF1D3557),
                        borderRadius: BorderRadius.circular(8),
                        border: selected ? Border.all(color: const Color(0xFFFFD166), width: 2) : null,
                      ),
                      child: Center(
                        child: unlocked
                            ? Text(c.name[0], style: const TextStyle(color: Colors.white, fontSize: 24))
                            : const Icon(Icons.lock, color: Colors.white24, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 상세 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(char.name, style: const TextStyle(color: Color(0xFFFFD166), fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(char.job, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('고유: ${char.passiveDesc}', style: const TextStyle(color: Color(0xFFA8DADC), fontSize: 13)),
                    const SizedBox(height: 12),
                    _statRow('HP', char.baseHp.toInt().toString()),
                    _statRow('공격력', '${(char.baseMight * 100).toInt()}%'),
                    _statRow('이동속도', '${(char.baseSpeed * 100).toInt()}%'),
                    _statRow('쿨다운', '${(char.baseCooldown * 100).toInt()}%'),
                    const Spacer(),
                    if (_isUnlocked(_selectedIndex))
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            GamePageRoute(page: SkillTreeScreen(characterId: char.id)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E8948),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('스킬 트리', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // 스킨 피커
                    if (_isUnlocked(_selectedIndex)) _buildSkinPicker(char.id),
                    const SizedBox(height: 8),
                    Text('해금: ${char.unlockCondition}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ),
            // 시작 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _isUnlocked(_selectedIndex)
                    ? () {
                        Navigator.of(context).push(
                          GamePageRoute(page: StageSelectScreen(characterId: _characters[_selectedIndex].id)),
                        );
                      }
                    : null,
                child: Container(
                  width: 200, padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946), borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('출진!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSkinUnlocked(SkinData skin) {
    if (skin.unlockType == SkinUnlockType.defaultSkin) return true;
    return _save.isSkinUnlocked(skin.id);
  }

  Widget _buildSkinPicker(String characterId) {
    final skins = getSkinsForCharacter(characterId);
    if (skins.length <= 1) return const SizedBox.shrink();
    final selected = _save.getSelectedSkin(characterId);
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const Text('스킨: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: skins.length,
              itemBuilder: (ctx, i) {
                final skin = skins[i];
                final unlocked = _isSkinUnlocked(skin);
                final isSelected = skin.id == selected;
                return GestureDetector(
                  onTap: unlocked ? () {
                    _save.setSelectedSkin(characterId, skin.id);
                    setState(() {});
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: !unlocked
                          ? const Color(0xFF222222)
                          : isSelected
                              ? skin.tint.withValues(alpha: 0.8)
                              : const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected ? Border.all(color: const Color(0xFFFFD166), width: 1.5) : null,
                    ),
                    child: Text(
                      unlocked ? skin.name : '🔒',
                      style: TextStyle(
                        color: unlocked ? Colors.white : Colors.white24,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12))),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
