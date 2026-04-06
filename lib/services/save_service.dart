import 'package:hive/hive.dart';
import '../data/achievements.dart';
import '../data/evolutions.dart';
import '../data/characters.dart';

class SaveService {
  static final SaveService instance = SaveService._();
  SaveService._();

  static const _boxName = 'toemalok_save';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // 엽전
  int get coins => _box.get('coins', defaultValue: 0);
  set coins(int v) => _box.put('coins', v);

  // 귀혼석
  int get soulStones => _box.get('soulStones', defaultValue: 0);
  set soulStones(int v) => _box.put('soulStones', v);

  // 귀혼석 아이템 보유량
  int getSoulStoneItemCount(String id) => _box.get('ssi_$id', defaultValue: 0);
  void addSoulStoneItem(String id, int count) =>
      _box.put('ssi_$id', getSoulStoneItemCount(id) + count);
  void useSoulStoneItem(String id) {
    final cur = getSoulStoneItemCount(id);
    if (cur > 0) _box.put('ssi_$id', cur - 1);
  }

  // 도력 (스킬 트리 화폐)
  int get doryeok => _box.get('doryeok', defaultValue: 0);
  set doryeok(int v) => _box.put('doryeok', v);

  // 스킬 트리 노드 활성화
  int getSkillLevel(String charId, int pathIndex) =>
      _box.get('skill_${charId}_$pathIndex', defaultValue: 0);
  void setSkillLevel(String charId, int pathIndex, int level) =>
      _box.put('skill_${charId}_$pathIndex', level);

  // 영구 강화 레벨
  int getPowerUpLevel(String id) => _box.get('pu_$id', defaultValue: 0);
  void setPowerUpLevel(String id, int level) => _box.put('pu_$id', level);

  // 캐릭터 해금
  bool isCharacterUnlocked(String id) => _box.get('char_$id', defaultValue: false);
  void unlockCharacter(String id) => _box.put('char_$id', true);

  // 스테이지 해금
  bool isStageUnlocked(String id) => _box.get('stage_$id', defaultValue: false);
  void unlockStage(String id) => _box.put('stage_$id', true);

  // 게임 모드 해금
  bool isModeUnlocked(String id) => id == 'normal' || _box.get('mode_$id', defaultValue: false);
  void unlockMode(String id) => _box.put('mode_$id', true);

  // 도전과제
  bool isAchievementDone(String id) => _box.get('ach_$id', defaultValue: false);
  void completeAchievement(String id) => _box.put('ach_$id', true);

  // 통계
  int get totalKills => _box.get('totalKills', defaultValue: 0);
  set totalKills(int v) => _box.put('totalKills', v);

  int get totalRuns => _box.get('totalRuns', defaultValue: 0);
  set totalRuns(int v) => _box.put('totalRuns', v);

  double get bestTime => _box.get('bestTime', defaultValue: 0.0);
  set bestTime(double v) => _box.put('bestTime', v);

  int get bestKills => _box.get('bestKills', defaultValue: 0);
  set bestKills(int v) => _box.put('bestKills', v);

  // 상자 카운트
  int get chestCount => _box.get('chestCount', defaultValue: 0);
  set chestCount(int v) => _box.put('chestCount', v);
  void addChestCount() => chestCount = chestCount + 1;

  // 설정
  double get sfxVolume => _box.get('sfxVol', defaultValue: 1.0);
  set sfxVolume(double v) => _box.put('sfxVol', v);

  double get bgmVolume => _box.get('bgmVol', defaultValue: 0.7);
  set bgmVolume(double v) => _box.put('bgmVol', v);

  bool get tutorialDone => _box.get('tutDone', defaultValue: false);
  set tutorialDone(bool v) => _box.put('tutDone', v);

  int get shakeIntensitySetting => _box.get('shakeInt', defaultValue: 100);
  set shakeIntensitySetting(int v) => _box.put('shakeInt', v);

  bool get colorBlindMode => _box.get('colorBlind', defaultValue: false);
  set colorBlindMode(bool v) => _box.put('colorBlind', v);

  // 언어 설정 ('ko', 'en')
  String get language => _box.get('language', defaultValue: 'ko');
  set language(String v) => _box.put('language', v);

  // 도감 발견 기록
  Set<String> get discoveredEntries {
    final list = _box.get('discovered', defaultValue: <String>[]);
    return Set<String>.from(list as List);
  }

  void discover(String id) {
    final set = discoveredEntries;
    if (set.contains(id)) return;
    set.add(id);
    _box.put('discovered', set.toList());
  }

  // 업적
  List<String> get completedAchievements {
    final list = _box.get('achievements', defaultValue: <String>[]);
    return List<String>.from(list as List);
  }

  void _addAchievement(String id) {
    final list = completedAchievements;
    if (list.contains(id)) return;
    list.add(id);
    _box.put('achievements', list);
  }

  // ──────── 코스메틱 ────────

  bool isSkinUnlocked(String skinId) => _box.get('skin_$skinId', defaultValue: false);
  void unlockSkin(String skinId) => _box.put('skin_$skinId', true);

  String getSelectedSkin(String characterId) =>
      _box.get('selectedSkin_$characterId', defaultValue: '${characterId}_default');
  void setSelectedSkin(String characterId, String skinId) =>
      _box.put('selectedSkin_$characterId', skinId);

  // ──────── 환생(프레스티지) ────────

  int get prestigeLevel => _box.get('prestige', defaultValue: 0);
  set prestigeLevel(int v) => _box.put('prestige', v);

  /// 환생 시 영구 보너스
  double get prestigeDamageBonus => prestigeLevel * 0.03; // 레벨당 3%
  double get prestigeHpBonus => prestigeLevel * 5.0; // 레벨당 HP+5
  double get prestigeExpBonus => prestigeLevel * 0.02; // 레벨당 경험치 2%

  void prestige() {
    prestigeLevel = prestigeLevel + 1;
    // 화폐 리셋 (영구 강화 유지)
    coins = 0;
    doryeok = 0;
    // 런 통계는 유지
  }

  // ──────── 일일 도전 ────────

  /// 오늘 일일 도전 완료 여부
  String get lastDailyChallengeDate => _box.get('lastDcDate', defaultValue: '');
  set lastDailyChallengeDate(String v) => _box.put('lastDcDate', v);

  bool isDailyChallengeCompleted(String dateStr) => lastDailyChallengeDate == dateStr;

  void completeDailyChallenge(String dateStr) {
    lastDailyChallengeDate = dateStr;
  }

  // ──────── 주간 랭킹 ────────

  /// 주간 최고 기록 (킬 수)
  int get weeklyBestKills => _box.get('weeklyBestKills', defaultValue: 0);
  set weeklyBestKills(int v) => _box.put('weeklyBestKills', v);

  String get weeklyResetDate => _box.get('weeklyResetDate', defaultValue: '');
  set weeklyResetDate(String v) => _box.put('weeklyResetDate', v);

  // ──────── 일일 보상 ────────

  /// 마지막 출석일 (yyyyMMdd 형식)
  String get lastLoginDate => _box.get('lastLoginDate', defaultValue: '');
  set lastLoginDate(String v) => _box.put('lastLoginDate', v);

  /// 연속 출석 일수
  int get loginStreak => _box.get('loginStreak', defaultValue: 0);
  set loginStreak(int v) => _box.put('loginStreak', v);

  /// 일일 보상 체크 — 오늘 처음이면 보상 지급, 보상 내용 반환 (null = 이미 받음)
  DailyRewardResult? claimDailyReward() {
    final now = DateTime.now();
    final today = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    if (lastLoginDate == today) return null; // 이미 받음

    // 연속 출석 계산
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}${yesterday.month.toString().padLeft(2, '0')}${yesterday.day.toString().padLeft(2, '0')}';
    if (lastLoginDate == yesterdayStr) {
      loginStreak = loginStreak + 1;
    } else {
      loginStreak = 1; // 연속 끊김 → 1일차부터
    }
    lastLoginDate = today;

    // 보상 계산 (7일 주기)
    final day = ((loginStreak - 1) % 7) + 1; // 1~7
    final reward = _dailyRewards[day]!;

    // 지급
    coins = coins + reward.coins;
    soulStones = soulStones + reward.soulStones;
    doryeok = doryeok + reward.doryeok;

    return DailyRewardResult(
      day: day,
      streak: loginStreak,
      coins: reward.coins,
      soulStones: reward.soulStones,
      doryeok: reward.doryeok,
    );
  }

  static const _dailyRewards = {
    1: _DailyReward(coins: 50),
    2: _DailyReward(coins: 75),
    3: _DailyReward(coins: 100, doryeok: 1),
    4: _DailyReward(coins: 100),
    5: _DailyReward(coins: 150, soulStones: 1),
    6: _DailyReward(coins: 150, doryeok: 2),
    7: _DailyReward(coins: 300, soulStones: 2, doryeok: 3), // 7일차 대보상
  };

  /// 업적 조건 체크, 해금, 보상 지급
  List<String> checkAchievements() {
    final newlyUnlocked = <String>[];
    final done = completedAchievements;

    void check(String id, bool condition) {
      if (!done.contains(id) && condition) {
        _addAchievement(id);
        newlyUnlocked.add(id);
        // 보상 지급
        final data = achievementTable[id];
        if (data != null) {
          if (data.rewardCoins > 0) coins = coins + data.rewardCoins;
          if (data.rewardSoulStones > 0) soulStones = soulStones + data.rewardSoulStones;
          if (data.rewardDoryeok > 0) doryeok = doryeok + data.rewardDoryeok;
        }
      }
    }

    // 처치
    check('first_blood', totalKills >= 1);
    check('slayer_100', totalKills >= 100);
    check('slayer_1000', totalKills >= 1000);
    check('slayer_10000', totalKills >= 10000);

    // 생존
    check('survivor_5', bestTime >= 300);
    check('survivor_10', bestTime >= 600);
    check('survivor_20', bestTime >= 1200);
    check('survivor_30', bestTime >= 1800);

    // 런 횟수
    check('veteran_10', totalRuns >= 10);
    check('veteran_50', totalRuns >= 50);

    // 재화
    check('rich_1000', coins >= 1000);
    check('rich_10000', coins >= 10000);

    // 보스 처치 (도감에 등록되어 있으면 처치한 것)
    final disc = discoveredEntries;
    check('boss_dokkaebi', disc.contains('dokkaebi_daejang'));
    check('boss_gumiho', disc.contains('gumiho'));
    check('boss_jangsanbeom', disc.contains('jangsanbeom'));
    check('boss_bulgasari', disc.contains('bulgasari_boss'));
    check('boss_yongwang', disc.contains('yongwang'));

    // 진화
    final evoCount = disc.where((id) => evolutionTable.containsKey(id)).length;
    check('evo_first', evoCount >= 1);
    check('evo_5', evoCount >= 5);
    check('evo_all', evoCount >= 12);

    // 캐릭터 전원 해금
    final allCharsUnlocked = characterTable.keys.every(
        (id) => id == 'lee_taeyang' || id == 'wolhui' || isCharacterUnlocked(id));
    check('char_all', allCharsUnlocked);

    // 스테이지 전체 클리어
    final allStagesCleared = ['stage2', 'stage3', 'stage4', 'stage5']
        .every((id) => isStageUnlocked(id));
    check('stage_all', allStagesCleared);

    return newlyUnlocked;
  }
}

class _DailyReward {
  final int coins;
  final int soulStones;
  final int doryeok;
  const _DailyReward({this.coins = 0, this.soulStones = 0, this.doryeok = 0});
}

class DailyRewardResult {
  final int day;
  final int streak;
  final int coins;
  final int soulStones;
  final int doryeok;
  const DailyRewardResult({
    required this.day,
    required this.streak,
    this.coins = 0,
    this.soulStones = 0,
    this.doryeok = 0,
  });
}
