class AchievementData {
  final String id;
  final String name;
  final String description;
  final int rewardCoins;
  final int rewardSoulStones;
  final int rewardDoryeok;

  const AchievementData({
    required this.id,
    required this.name,
    required this.description,
    this.rewardCoins = 0,
    this.rewardSoulStones = 0,
    this.rewardDoryeok = 0,
  });
}

const Map<String, AchievementData> achievementTable = {
  // 처치 관련
  'first_blood': AchievementData(
    id: 'first_blood', name: '첫 퇴마', description: '적 1마리 처치',
    rewardCoins: 50,
  ),
  'slayer_100': AchievementData(
    id: 'slayer_100', name: '퇴마 수련생', description: '적 100마리 처치 (누적)',
    rewardCoins: 200,
  ),
  'slayer_1000': AchievementData(
    id: 'slayer_1000', name: '퇴마 고수', description: '적 1,000마리 처치 (누적)',
    rewardCoins: 500, rewardDoryeok: 3,
  ),
  'slayer_10000': AchievementData(
    id: 'slayer_10000', name: '백귀 사냥꾼', description: '적 10,000마리 처치 (누적)',
    rewardCoins: 2000, rewardSoulStones: 5, rewardDoryeok: 5,
  ),

  // 생존 관련
  'survivor_5': AchievementData(
    id: 'survivor_5', name: '생존자', description: '5분 생존',
    rewardCoins: 100,
  ),
  'survivor_10': AchievementData(
    id: 'survivor_10', name: '강인한 의지', description: '10분 생존',
    rewardCoins: 300, rewardDoryeok: 2,
  ),
  'survivor_20': AchievementData(
    id: 'survivor_20', name: '불굴의 퇴마사', description: '20분 생존',
    rewardCoins: 500, rewardDoryeok: 3,
  ),
  'survivor_30': AchievementData(
    id: 'survivor_30', name: '전설의 퇴마사', description: '30분 클리어',
    rewardCoins: 1000, rewardSoulStones: 3, rewardDoryeok: 5,
  ),

  // 런 횟수
  'veteran_10': AchievementData(
    id: 'veteran_10', name: '단골 퇴마사', description: '10회 플레이',
    rewardCoins: 200,
  ),
  'veteran_50': AchievementData(
    id: 'veteran_50', name: '노련한 사냥꾼', description: '50회 플레이',
    rewardCoins: 500, rewardDoryeok: 3,
  ),

  // 재화 관련
  'rich_1000': AchievementData(
    id: 'rich_1000', name: '엽전 모으기', description: '엽전 1,000개 보유',
    rewardCoins: 200,
  ),
  'rich_10000': AchievementData(
    id: 'rich_10000', name: '부자 퇴마사', description: '엽전 10,000개 보유',
    rewardSoulStones: 3, rewardDoryeok: 3,
  ),

  // 보스 관련
  'boss_dokkaebi': AchievementData(
    id: 'boss_dokkaebi', name: '도깨비 사냥꾼', description: '도깨비 대장 처치',
    rewardCoins: 300, rewardDoryeok: 2,
  ),
  'boss_gumiho': AchievementData(
    id: 'boss_gumiho', name: '구미호 봉인', description: '구미호 처치',
    rewardCoins: 500, rewardDoryeok: 3,
  ),
  'boss_jangsanbeom': AchievementData(
    id: 'boss_jangsanbeom', name: '장산범 퇴치', description: '장산범 처치',
    rewardCoins: 500, rewardDoryeok: 3,
  ),
  'boss_bulgasari': AchievementData(
    id: 'boss_bulgasari', name: '불가사리 격퇴', description: '불가사리 처치',
    rewardCoins: 800, rewardDoryeok: 4,
  ),
  'boss_yongwang': AchievementData(
    id: 'boss_yongwang', name: '용왕 정복', description: '용왕 처치',
    rewardCoins: 1000, rewardSoulStones: 5, rewardDoryeok: 5,
  ),

  // 진화 관련
  'evo_first': AchievementData(
    id: 'evo_first', name: '첫 진화', description: '무기 1종 진화',
    rewardCoins: 300, rewardDoryeok: 2,
  ),
  'evo_5': AchievementData(
    id: 'evo_5', name: '진화의 달인', description: '무기 5종 진화 (누적)',
    rewardCoins: 500, rewardSoulStones: 3, rewardDoryeok: 3,
  ),
  'evo_all': AchievementData(
    id: 'evo_all', name: '완전체', description: '무기 12종 모두 진화',
    rewardCoins: 2000, rewardSoulStones: 10, rewardDoryeok: 10,
  ),

  // 캐릭터 해금
  'char_all': AchievementData(
    id: 'char_all', name: '퇴마 군단', description: '캐릭터 8명 모두 해금',
    rewardCoins: 1000, rewardSoulStones: 5, rewardDoryeok: 5,
  ),

  // 스테이지 클리어
  'stage_all': AchievementData(
    id: 'stage_all', name: '모든 땅의 수호자', description: '5개 스테이지 모두 클리어',
    rewardCoins: 2000, rewardSoulStones: 5, rewardDoryeok: 10,
  ),
};
