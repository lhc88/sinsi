class PassiveLevelData {
  final String effect;
  final double value;

  const PassiveLevelData({required this.effect, required this.value});
}

class PassiveInfo {
  final String id;
  final String name;
  final String description;
  final List<PassiveLevelData> levels;

  const PassiveInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.levels,
  });
}

const Map<String, PassiveInfo> passiveTable = {
  'hwatotbul': PassiveInfo(
    id: 'hwatotbul', name: '화톳불', description: '공격력 +10%/Lv',
    levels: [
      PassiveLevelData(effect: 'might', value: 0.10),
      PassiveLevelData(effect: 'might', value: 0.10),
      PassiveLevelData(effect: 'might', value: 0.10),
      PassiveLevelData(effect: 'might', value: 0.10),
      PassiveLevelData(effect: 'might', value: 0.10),
    ],
  ),
  'insam': PassiveInfo(
    id: 'insam', name: '인삼', description: 'HP+20, 회복+0.1/s per Lv',
    levels: [
      PassiveLevelData(effect: 'hp_regen', value: 0.1),
      PassiveLevelData(effect: 'hp_regen', value: 0.1),
      PassiveLevelData(effect: 'hp_regen', value: 0.1),
      PassiveLevelData(effect: 'hp_regen', value: 0.1),
      PassiveLevelData(effect: 'hp_regen', value: 0.1),
    ],
  ),
  'buchae': PassiveInfo(
    id: 'buchae', name: '부채', description: '투사체 속도 +15%/Lv',
    levels: [
      PassiveLevelData(effect: 'proj_speed', value: 0.15),
      PassiveLevelData(effect: 'proj_speed', value: 0.15),
      PassiveLevelData(effect: 'proj_speed', value: 0.15),
      PassiveLevelData(effect: 'proj_speed', value: 0.15),
      PassiveLevelData(effect: 'proj_speed', value: 0.15),
    ],
  ),
  'durumari': PassiveInfo(
    id: 'durumari', name: '두루마리', description: '지속 시간 +15%/Lv',
    levels: [
      PassiveLevelData(effect: 'duration', value: 0.15),
      PassiveLevelData(effect: 'duration', value: 0.15),
      PassiveLevelData(effect: 'duration', value: 0.15),
      PassiveLevelData(effect: 'duration', value: 0.15),
      PassiveLevelData(effect: 'duration', value: 0.15),
    ],
  ),
  'hyangro': PassiveInfo(
    id: 'hyangro', name: '향로', description: '공격 범위 +15%/Lv',
    levels: [
      PassiveLevelData(effect: 'area', value: 0.15),
      PassiveLevelData(effect: 'area', value: 0.15),
      PassiveLevelData(effect: 'area', value: 0.15),
      PassiveLevelData(effect: 'area', value: 0.15),
      PassiveLevelData(effect: 'area', value: 0.15),
    ],
  ),
  'janggu': PassiveInfo(
    id: 'janggu', name: '장구', description: '쿨다운 -8%/Lv',
    levels: [
      PassiveLevelData(effect: 'cooldown', value: 0.08),
      PassiveLevelData(effect: 'cooldown', value: 0.08),
      PassiveLevelData(effect: 'cooldown', value: 0.08),
      PassiveLevelData(effect: 'cooldown', value: 0.08),
      PassiveLevelData(effect: 'cooldown', value: 0.08),
    ],
  ),
  'yeouguseul': PassiveInfo(
    id: 'yeouguseul', name: '여우구슬', description: '흡혈 +3%/Lv',
    levels: [
      PassiveLevelData(effect: 'lifesteal', value: 0.03),
      PassiveLevelData(effect: 'lifesteal', value: 0.03),
      PassiveLevelData(effect: 'lifesteal', value: 0.03),
      PassiveLevelData(effect: 'lifesteal', value: 0.03),
      PassiveLevelData(effect: 'lifesteal', value: 0.03),
    ],
  ),
  'nachimban': PassiveInfo(
    id: 'nachimban', name: '나침반', description: '투사체 +1 (2Lv마다)',
    levels: [
      PassiveLevelData(effect: 'amount', value: 0),
      PassiveLevelData(effect: 'amount', value: 1),
      PassiveLevelData(effect: 'amount', value: 0),
      PassiveLevelData(effect: 'amount', value: 1),
      PassiveLevelData(effect: 'amount', value: 0),
    ],
  ),
  'mae_gitteol': PassiveInfo(
    id: 'mae_gitteol', name: '매 깃털', description: '치명타 +5%/Lv',
    levels: [
      PassiveLevelData(effect: 'crit', value: 0.05),
      PassiveLevelData(effect: 'crit', value: 0.05),
      PassiveLevelData(effect: 'crit', value: 0.05),
      PassiveLevelData(effect: 'crit', value: 0.05),
      PassiveLevelData(effect: 'crit', value: 0.05),
    ],
  ),
  'doksa_ippal': PassiveInfo(
    id: 'doksa_ippal', name: '독사 이빨', description: '독 DMG +8%/Lv',
    levels: [
      PassiveLevelData(effect: 'poison', value: 0.08),
      PassiveLevelData(effect: 'poison', value: 0.08),
      PassiveLevelData(effect: 'poison', value: 0.08),
      PassiveLevelData(effect: 'poison', value: 0.08),
      PassiveLevelData(effect: 'poison', value: 0.08),
    ],
  ),
  'dukkeobi_seoksang': PassiveInfo(
    id: 'dukkeobi_seoksang', name: '두꺼비 석상', description: '바운스+관통 +1 (3Lv)',
    levels: [
      PassiveLevelData(effect: 'bounce', value: 0),
      PassiveLevelData(effect: 'bounce', value: 0),
      PassiveLevelData(effect: 'bounce', value: 1),
      PassiveLevelData(effect: 'bounce', value: 0),
      PassiveLevelData(effect: 'bounce', value: 1),
    ],
  ),
  'deungjan': PassiveInfo(
    id: 'deungjan', name: '등잔', description: '소환수 공격력 +12%/Lv',
    levels: [
      PassiveLevelData(effect: 'summon', value: 0.12),
      PassiveLevelData(effect: 'summon', value: 0.12),
      PassiveLevelData(effect: 'summon', value: 0.12),
      PassiveLevelData(effect: 'summon', value: 0.12),
      PassiveLevelData(effect: 'summon', value: 0.12),
    ],
  ),
};
