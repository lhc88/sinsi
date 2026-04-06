/// 일일 도전 데이터
class DailyChallengeData {
  final String id;
  final String name;
  final String description;
  final DailyChallengeRule rule;
  final int rewardCoins;
  final int rewardSoulStones;

  const DailyChallengeData({
    required this.id,
    required this.name,
    required this.description,
    required this.rule,
    this.rewardCoins = 200,
    this.rewardSoulStones = 0,
  });
}

enum DailyChallengeRule {
  onlyFire,       // 화 원소 무기만 사용
  onlyWater,      // 수 원소 무기만 사용
  noPassive,      // 패시브 선택 불가
  speedRun,       // 15분 내 보스 1체 처치
  survivalHard,   // 적 이속 1.5배에서 10분 생존
  noHeal,         // 회복 불가
  critOnly,       // 치명타만 데미지 (일반 0.5배)
  eliteHunter,    // 엘리트 10마리 처치
  bossRush,       // 보스 3체 연속 등장
  lowHp,          // 최대 HP 50%로 시작
}

/// 날짜 기반 도전 생성 (시드로 결정론적)
DailyChallengeData getDailyChallenge(DateTime date) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  final index = seed % _challengePool.length;
  return _challengePool[index];
}

const _challengePool = [
  DailyChallengeData(
    id: 'dc_fire_only', name: '화염의 길',
    description: '화 원소 무기만 사용하여 10분 생존',
    rule: DailyChallengeRule.onlyFire, rewardCoins: 200,
  ),
  DailyChallengeData(
    id: 'dc_water_only', name: '수류의 길',
    description: '수 원소 무기만 사용하여 10분 생존',
    rule: DailyChallengeRule.onlyWater, rewardCoins: 200,
  ),
  DailyChallengeData(
    id: 'dc_no_passive', name: '순수 무공',
    description: '패시브 없이 10분 생존',
    rule: DailyChallengeRule.noPassive, rewardCoins: 300,
  ),
  DailyChallengeData(
    id: 'dc_speed_run', name: '속전속결',
    description: '15분 내 보스 1체 처치',
    rule: DailyChallengeRule.speedRun, rewardCoins: 250, rewardSoulStones: 1,
  ),
  DailyChallengeData(
    id: 'dc_survival_hard', name: '극한 생존',
    description: '적 이속 1.5배에서 10분 생존',
    rule: DailyChallengeRule.survivalHard, rewardCoins: 350,
  ),
  DailyChallengeData(
    id: 'dc_no_heal', name: '무치유',
    description: '회복 없이 10분 생존',
    rule: DailyChallengeRule.noHeal, rewardCoins: 300, rewardSoulStones: 1,
  ),
  DailyChallengeData(
    id: 'dc_crit_only', name: '급소 타격',
    description: '치명타 데미지만 정상 (일반 0.5배)',
    rule: DailyChallengeRule.critOnly, rewardCoins: 250,
  ),
  DailyChallengeData(
    id: 'dc_elite_hunter', name: '엘리트 사냥꾼',
    description: '엘리트 적 10마리 처치',
    rule: DailyChallengeRule.eliteHunter, rewardCoins: 400, rewardSoulStones: 2,
  ),
  DailyChallengeData(
    id: 'dc_boss_rush', name: '보스 러시',
    description: '보스 3체 연속 등장, 모두 처치',
    rule: DailyChallengeRule.bossRush, rewardCoins: 500, rewardSoulStones: 3,
  ),
  DailyChallengeData(
    id: 'dc_low_hp', name: '사선 위의 퇴마',
    description: 'HP 50%로 시작, 10분 생존',
    rule: DailyChallengeRule.lowHp, rewardCoins: 300,
  ),
];
