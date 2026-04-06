import 'package:flutter/material.dart';
import '../../data/powerups.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  final _save = SaveService.instance;
  int get _coins => _save.coins;
  int get _soulStones => _save.soulStones;
  int _getLevel(String id) => _save.getPowerUpLevel(id);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  const Text('상점', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD166), size: 16),
                  const SizedBox(width: 2),
                  Text('$_coins', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 14)),
                  const SizedBox(width: 12),
                  const Icon(Icons.diamond, color: Color(0xFFBB86FC), size: 16),
                  const SizedBox(width: 2),
                  Text('$_soulStones', style: const TextStyle(color: Color(0xFFBB86FC), fontSize: 14)),
                ],
              ),
            ),
            // 탭
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFFD166),
              labelColor: const Color(0xFFFFD166),
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: '강화 (엽전)'),
                Tab(text: '귀혼석 상점'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCoinShop(),
                  _buildSoulStoneShop(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinShop() {
    return Column(
      children: [
        // 환생(프레스티지) 섹션
        _buildPrestigeSection(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: powerUpTable.length,
            itemBuilder: (ctx, i) {
                  final pu = powerUpTable[i];
                  final level = _getLevel(pu.id);
                  final maxed = level >= pu.maxLevel;
                  final cost = maxed ? 0 : pu.costFormula(level);
                  final canBuy = !maxed && _coins >= cost;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D3557),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pu.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              Text(pu.description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              // 레벨 바
                              Row(
                                children: List.generate(pu.maxLevel, (j) => Container(
                                  width: 16, height: 6,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: BoxDecoration(
                                    color: j < level ? const Color(0xFF7EC850) : const Color(0xFF333333),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: canBuy ? () => _buy(pu, level) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: maxed
                                  ? const Color(0xFF333333)
                                  : canBuy
                                      ? const Color(0xFFE63946)
                                      : const Color(0xFF555555),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              maxed ? 'MAX' : '$cost',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }

  // ──────── 귀혼석 상점 ────────
  static const List<_SoulStoneItem> _soulStoneItems = [
    _SoulStoneItem(id: 'ss_revive', name: '부활 토큰', desc: '사망 시 자동 부활 1회 (인게임)', cost: 3, icon: Icons.favorite),
    _SoulStoneItem(id: 'ss_double_coins', name: '엽전 2배 (1회)', desc: '다음 판 획득 엽전 2배', cost: 2, icon: Icons.monetization_on),
    _SoulStoneItem(id: 'ss_extra_choice', name: '레벨업 선택+1 (영구)', desc: '레벨업 시 선택지 +1 (최대 2회)', cost: 10, maxOwn: 2, icon: Icons.add_circle),
    _SoulStoneItem(id: 'ss_reroll', name: '리롤 토큰 x3', desc: '레벨업 선택지 새로고침', cost: 2, icon: Icons.refresh),
    _SoulStoneItem(id: 'ss_skin_unlock', name: '랜덤 스킨 해금', desc: '미보유 스킨 1개 랜덤 해금', cost: 8, icon: Icons.brush),
    _SoulStoneItem(id: 'ss_gold_pack', name: '엽전 보따리', desc: '엽전 5000 획득', cost: 5, icon: Icons.card_giftcard),
  ];

  Widget _buildSoulStoneShop() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _soulStoneItems.length,
      itemBuilder: (ctx, i) {
        final item = _soulStoneItems[i];
        final owned = _save.getSoulStoneItemCount(item.id);
        final maxed = item.maxOwn > 0 && owned >= item.maxOwn;
        final canBuy = !maxed && _soulStones >= item.cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2A44),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x44BB86FC)),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: const Color(0xFFBB86FC), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(item.desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    if (item.maxOwn > 0) Text('보유: $owned / ${item.maxOwn}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: canBuy ? () => _buySoulStone(item) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: maxed ? const Color(0xFF333333) : canBuy ? const Color(0xFF9B59B6) : const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(maxed ? 'MAX' : '${item.cost}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _buySoulStone(_SoulStoneItem item) {
    AudioService.uiClick();
    _save.soulStones = _soulStones - item.cost;

    switch (item.id) {
      case 'ss_revive':
        _save.addSoulStoneItem(item.id, 1);
      case 'ss_double_coins':
        _save.addSoulStoneItem(item.id, 1);
      case 'ss_extra_choice':
        _save.addSoulStoneItem(item.id, 1);
      case 'ss_reroll':
        _save.addSoulStoneItem(item.id, 3);
      case 'ss_skin_unlock':
        // TODO: 랜덤 미보유 스킨 해금
        _save.addSoulStoneItem(item.id, 1);
      case 'ss_gold_pack':
        _save.coins = _save.coins + 5000;
    }
    setState(() {});
  }

  Widget _buildPrestigeSection() {
    final level = _save.prestigeLevel;
    final dmg = (_save.prestigeDamageBonus * 100).toStringAsFixed(0);
    final hp = _save.prestigeHpBonus.toStringAsFixed(0);
    final exp = (_save.prestigeExpBonus * 100).toStringAsFixed(0);
    // 환생 조건: 총 런 횟수 10 이상, 엽전 1000 이상
    final canPrestige = _save.totalRuns >= 10 && _save.coins >= 1000;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A4E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9B59B6), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('환생 Lv.$level', style: const TextStyle(color: Color(0xFFDDA0DD), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('공격력 +$dmg%  HP +$hp  경험치 +$exp%',
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                if (level == 0)
                  const Text('엽전 1000 + 10런 이상 시 가능', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          GestureDetector(
            onTap: canPrestige ? _prestige : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: canPrestige ? const Color(0xFF9B59B6) : const Color(0xFF333333),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('환생', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _prestige() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D3557),
        title: const Text('환생', style: TextStyle(color: Color(0xFFDDA0DD))),
        content: const Text('엽전과 도력이 초기화되지만 영구 보너스가 증가합니다.\n정말 환생하시겠습니까?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              _save.prestige();
              AudioService.prestige();
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('환생', style: TextStyle(color: Color(0xFFDDA0DD))),
          ),
        ],
      ),
    );
  }

  void _buy(PowerUpData pu, int currentLevel) {
    AudioService.uiClick();
    final cost = pu.costFormula(currentLevel);
    _save.coins = _coins - cost;
    _save.setPowerUpLevel(pu.id, currentLevel + 1);
    setState(() {});
  }
}

class _SoulStoneItem {
  final String id;
  final String name;
  final String desc;
  final int cost;
  final int maxOwn; // 0 = 무제한
  final IconData icon;

  const _SoulStoneItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.cost,
    this.maxOwn = 0,
    required this.icon,
  });
}
