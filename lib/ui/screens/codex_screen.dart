import 'package:flutter/material.dart';
import '../../data/achievements.dart';
import '../../data/enemies.dart';
import '../../data/weapons.dart';
import '../../data/bosses.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Set<String> _discovered;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _discovered = SaveService.instance.discoveredEntries;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { AudioService.uiBack(); Navigator.pop(context); },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text('도감', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(
                    '발견 ${_discovered.length}/${enemyTable.length + weaponTable.length + bossTable.length}'
                    ' | 업적 ${SaveService.instance.completedAchievements.length}/${achievementTable.length}',
                    style: const TextStyle(color: Color(0xFF7EC850), fontSize: 12),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFFD166),
              labelColor: const Color(0xFFFFD166),
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: '요괴'),
                Tab(text: '무기'),
                Tab(text: '보스'),
                Tab(text: '업적'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEnemyList(),
                  _buildWeaponList(),
                  _buildBossList(),
                  _buildAchievementList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnemyList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: enemyTable.entries.map((e) {
        final found = _discovered.contains(e.key.name);
        return _codexTile(
          name: found ? e.value.name : '???',
          subtitle: found ? '${e.value.element.name} | HP: ${e.value.baseHp}' : '미발견',
          color: found ? e.value.color : const Color(0xFF333333),
          found: found,
        );
      }).toList(),
    );
  }

  Widget _buildWeaponList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: weaponTable.entries.map((e) {
        final found = _discovered.contains(e.key);
        return _codexTile(
          name: found ? e.value.name : '???',
          subtitle: found ? e.value.description : '미발견',
          color: found ? const Color(0xFFE63946) : const Color(0xFF333333),
          found: found,
        );
      }).toList(),
    );
  }

  Widget _buildBossList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: bossTable.entries.map((e) {
        final found = _discovered.contains(e.key);
        return _codexTile(
          name: found ? e.value.name : '???',
          subtitle: found ? 'HP: ${e.value.hp.toInt()} | ${e.value.element.name}' : '미발견',
          color: found ? e.value.color : const Color(0xFF333333),
          found: found,
        );
      }).toList(),
    );
  }

  Widget _buildAchievementList() {
    final completed = SaveService.instance.completedAchievements.toSet();
    final entries = achievementTable.values.toList();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: entries.map((ach) {
        final done = completed.contains(ach.id);
        final rewards = <String>[];
        if (ach.rewardCoins > 0) rewards.add('${ach.rewardCoins} 엽전');
        if (ach.rewardSoulStones > 0) rewards.add('${ach.rewardSoulStones} 귀혼석');
        if (ach.rewardDoryeok > 0) rewards.add('${ach.rewardDoryeok} 도력');
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: done ? const Color(0xFF1D3557) : const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: done ? const Color(0xFFFFD166) : const Color(0xFF333333),
              width: done ? 1 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.emoji_events : Icons.lock_outline,
                color: done ? const Color(0xFFFFD166) : Colors.white24,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ach.name,
                      style: TextStyle(
                        color: done ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ach.description,
                      style: TextStyle(color: done ? Colors.white70 : Colors.white30, fontSize: 11),
                    ),
                    if (rewards.isNotEmpty)
                      Text(
                        rewards.join(' / '),
                        style: TextStyle(
                          color: done ? const Color(0xFF7EC850) : Colors.white24,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              if (done)
                const Icon(Icons.check_circle, color: Color(0xFF7EC850), size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _codexTile({required String name, required String subtitle, required Color color, required bool found}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3557),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                found ? name[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(color: found ? Colors.white : Colors.white38, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: found ? Colors.white70 : Colors.white24, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
