import 'package:flutter/material.dart';
import '../../data/achievements.dart';
import '../../services/save_service.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = SaveService.instance;
    final completed = save.completedAchievements;
    final entries = achievementTable.values.toList();

    // 카테고리별 분류
    final categories = <String, List<AchievementData>>{
      '처치': entries.where((a) => a.id.startsWith('slayer') || a.id == 'first_blood').toList(),
      '생존': entries.where((a) => a.id.startsWith('survivor')).toList(),
      '보스': entries.where((a) => a.id.startsWith('boss')).toList(),
      '진화': entries.where((a) => a.id.startsWith('evo')).toList(),
      '기타': entries.where((a) =>
          !a.id.startsWith('slayer') && a.id != 'first_blood' &&
          !a.id.startsWith('survivor') && !a.id.startsWith('boss') &&
          !a.id.startsWith('evo')).toList(),
    };

    final totalCount = entries.length;
    final doneCount = completed.length;
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D3557),
        title: const Text('도전과제', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 전체 진행률
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1D3557),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('전체 진행률', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('$doneCount / $totalCount', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD166)),
                  ),
                ),
              ],
            ),
          ),
          // 카테고리별 리스트
          Expanded(
            child: ListView(
              children: categories.entries.map((cat) {
                if (cat.value.isEmpty) return const SizedBox.shrink();
                return _categorySection(cat.key, cat.value, completed);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categorySection(String title, List<AchievementData> achievements, List<String> completed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title, style: const TextStyle(color: Color(0xFFA8DADC), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...achievements.map((ach) {
          final isDone = completed.contains(ach.id);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF1D3557) : const Color(0xFF111D2B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDone ? const Color(0xFFFFD166) : const Color(0xFF333333),
                width: isDone ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                // 체크 아이콘
                Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  color: isDone ? const Color(0xFFFFD166) : const Color(0xFF555555),
                  size: 24,
                ),
                const SizedBox(width: 12),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ach.name,
                        style: TextStyle(
                          color: isDone ? Colors.white : Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ach.description,
                        style: TextStyle(
                          color: isDone ? Colors.white54 : Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // 보상
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (ach.rewardCoins > 0)
                      Text('${ach.rewardCoins} 엽전',
                          style: TextStyle(color: isDone ? const Color(0xFFFFD166) : Colors.white30, fontSize: 11)),
                    if (ach.rewardSoulStones > 0)
                      Text('${ach.rewardSoulStones} 귀혼석',
                          style: TextStyle(color: isDone ? const Color(0xFF9B5DE5) : Colors.white30, fontSize: 11)),
                    if (ach.rewardDoryeok > 0)
                      Text('${ach.rewardDoryeok} 도력',
                          style: TextStyle(color: isDone ? const Color(0xFF00BBF9) : Colors.white30, fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
