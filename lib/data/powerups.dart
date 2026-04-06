class PowerUpData {
  final String id;
  final String name;
  final String description;
  final int maxLevel;
  final int Function(int level) costFormula;

  const PowerUpData({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.costFormula,
  });
}

int _cost100(int level) => 100 * (level + 1);
int _cost200(int level) => 200 * (level + 1);
int _cost300(int level) => 300 * (level + 1);
int _cost500(int level) => 500 * (level + 1);

final List<PowerUpData> powerUpTable = [
  PowerUpData(id: 'pu_might', name: '힘 강화', description: '공격력 +5%', maxLevel: 5, costFormula: _cost100),
  PowerUpData(id: 'pu_hp', name: '체력 강화', description: 'HP +10', maxLevel: 5, costFormula: _cost100),
  PowerUpData(id: 'pu_speed', name: '이동 강화', description: '이속 +5%', maxLevel: 5, costFormula: _cost100),
  PowerUpData(id: 'pu_pickup', name: '수집 강화', description: '수집 범위 +10%', maxLevel: 5, costFormula: _cost100),
  PowerUpData(id: 'pu_cooldown', name: '쿨다운 강화', description: '쿨 -5%', maxLevel: 5, costFormula: _cost200),
  PowerUpData(id: 'pu_exp', name: '경험치 강화', description: '기운 +5%', maxLevel: 5, costFormula: _cost200),
  PowerUpData(id: 'pu_luck', name: '행운 강화', description: '행운 +5%', maxLevel: 5, costFormula: _cost200),
  PowerUpData(id: 'pu_revive', name: '부활', description: '부활 +1', maxLevel: 3, costFormula: _cost500),
  PowerUpData(id: 'pu_gold', name: '엽전 보너스', description: '엽전 +10%', maxLevel: 5, costFormula: _cost300),
  PowerUpData(id: 'pu_area', name: '범위 강화', description: '범위 +5%', maxLevel: 5, costFormula: _cost200),
];
