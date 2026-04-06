import 'enemies.dart';

class WaveEntry {
  final double startTime; // 초
  final double endTime;
  final List<EnemyType> enemies;
  final double spawnRate; // 초당
  final String? event;

  const WaveEntry({
    required this.startTime,
    required this.endTime,
    required this.enemies,
    required this.spawnRate,
    this.event,
  });
}

class BossEntry {
  final double time; // 초
  final String bossId;

  const BossEntry({required this.time, required this.bossId});
}

class StageData {
  final String id;
  final String name;
  final double duration; // 초
  final List<WaveEntry> waves;
  final List<BossEntry> bosses;
  final String bgm; // 스테이지 BGM 파일명
  final String bossBgm; // 보스 BGM 파일명

  const StageData({
    required this.id,
    required this.name,
    required this.duration,
    required this.waves,
    required this.bosses,
    this.bgm = 'stage_1',
    this.bossBgm = 'stage_boss',
  });
}

const allStages = [stage1, stage2, stage3, stage4, stage5, bonusStage1, bonusStage2];

const Map<String, StageData> stageTable = {
  'stage1': stage1,
  'stage2': stage2,
  'stage3': stage3,
  'stage4': stage4,
  'stage5': stage5,
  'bonus1': bonusStage1,
  'bonus2': bonusStage2,
};

// 스테이지 1: 대나무 숲 (30분 타임라인)
const stage1 = StageData(
  id: 'bamboo_forest',
  name: '대나무 숲',
  duration: 1800,
  waves: [
    // 0~1분: 잡귀만
    WaveEntry(startTime: 0, endTime: 60, enemies: [EnemyType.jabgwi], spawnRate: 0.5),
    // 1~3분: 잡귀+도깨비졸
    WaveEntry(startTime: 60, endTime: 180, enemies: [EnemyType.jabgwi, EnemyType.dokkaebiJol], spawnRate: 1.0),
    // 3~5분: +처녀귀신
    WaveEntry(startTime: 180, endTime: 300, enemies: [EnemyType.jabgwi, EnemyType.dokkaebiJol, EnemyType.cheonyeoGwisin], spawnRate: 1.5),
    // 5~8분: 혼합+해태석상
    WaveEntry(startTime: 300, endTime: 480, enemies: [EnemyType.jabgwi, EnemyType.dokkaebiJol, EnemyType.cheonyeoGwisin, EnemyType.haetaeSeoksang], spawnRate: 2.5),
    // 8~10분: +불여우
    WaveEntry(startTime: 480, endTime: 600, enemies: [EnemyType.jabgwi, EnemyType.dokkaebiJol, EnemyType.bulyeou, EnemyType.haetaeSeoksang], spawnRate: 3.5),
    // 10~15분: 4종 혼합
    WaveEntry(startTime: 600, endTime: 900, enemies: [EnemyType.dokkaebiJol, EnemyType.cheonyeoGwisin, EnemyType.bulyeou, EnemyType.haetaeSeoksang, EnemyType.gapotGwisin], spawnRate: 5.0),
    // 15~20분: 6종 혼합
    WaveEntry(startTime: 900, endTime: 1200, enemies: [EnemyType.dokkaebiJol, EnemyType.bulyeou, EnemyType.gapotGwisin, EnemyType.yacha, EnemyType.gureongi, EnemyType.nalssaenDoli], spawnRate: 6.0),
    // 20~25분: 엘리트 혼합
    WaveEntry(startTime: 1200, endTime: 1500, enemies: [EnemyType.gapotGwisin, EnemyType.yacha, EnemyType.gureongi, EnemyType.gangsi, EnemyType.nalssaenDoli], spawnRate: 8.0),
    // 25~30분: 전 종류 대량
    WaveEntry(startTime: 1500, endTime: 1800, enemies: EnemyType.values, spawnRate: 10.0),
  ],
  bosses: [
    BossEntry(time: 300, bossId: 'dokkaebi_daejang'),
    BossEntry(time: 600, bossId: 'gumiho'),
    BossEntry(time: 900, bossId: 'jangsanbeom'),
    BossEntry(time: 1200, bossId: 'bulgasari_boss'),
    BossEntry(time: 1500, bossId: 'yongwang'),
  ],
);

// 스테이지 2: 한옥 마을
const stage2 = StageData(
  id: 'hanok_village', name: '한옥 마을', duration: 1800, bgm: 'stage_2', bossBgm: 'stage_boss',
  waves: [
    WaveEntry(startTime: 0, endTime: 60, enemies: [EnemyType.jabgwi, EnemyType.dokkaebiJol], spawnRate: 0.8),
    WaveEntry(startTime: 60, endTime: 180, enemies: [EnemyType.dokkaebiJol, EnemyType.bulyeou], spawnRate: 1.5),
    WaveEntry(startTime: 180, endTime: 300, enemies: [EnemyType.bulyeou, EnemyType.yacha, EnemyType.gapotGwisin], spawnRate: 2.5),
    WaveEntry(startTime: 300, endTime: 600, enemies: [EnemyType.yacha, EnemyType.gapotGwisin, EnemyType.nalssaenDoli], spawnRate: 4.0),
    WaveEntry(startTime: 600, endTime: 1200, enemies: [EnemyType.gapotGwisin, EnemyType.yacha, EnemyType.gangsi], spawnRate: 6.0),
    WaveEntry(startTime: 1200, endTime: 1800, enemies: EnemyType.values, spawnRate: 8.0),
  ],
  bosses: [
    BossEntry(time: 300, bossId: 'dokkaebi_daejang'),
    BossEntry(time: 600, bossId: 'gumiho'),
    BossEntry(time: 900, bossId: 'jangsanbeom'),
    BossEntry(time: 1200, bossId: 'bulgasari_boss'),
    BossEntry(time: 1500, bossId: 'yongwang'),
  ],
);

// 스테이지 3: 지하 궁궐
const stage3 = StageData(
  id: 'underground_palace', name: '지하 궁궐', duration: 1800, bgm: 'stage_3', bossBgm: 'stage_boss_2',
  waves: [
    WaveEntry(startTime: 0, endTime: 120, enemies: [EnemyType.jabgwi, EnemyType.haetaeSeoksang], spawnRate: 1.0),
    WaveEntry(startTime: 120, endTime: 300, enemies: [EnemyType.haetaeSeoksang, EnemyType.cheonyeoGwisin, EnemyType.gureongi], spawnRate: 2.0),
    WaveEntry(startTime: 300, endTime: 600, enemies: [EnemyType.gureongi, EnemyType.gangsi, EnemyType.gapotGwisin], spawnRate: 4.0),
    WaveEntry(startTime: 600, endTime: 1200, enemies: [EnemyType.gangsi, EnemyType.gapotGwisin, EnemyType.yacha], spawnRate: 6.0),
    WaveEntry(startTime: 1200, endTime: 1800, enemies: EnemyType.values, spawnRate: 8.0),
  ],
  bosses: [
    BossEntry(time: 300, bossId: 'dokkaebi_daejang'),
    BossEntry(time: 600, bossId: 'gumiho'),
    BossEntry(time: 900, bossId: 'jangsanbeom'),
    BossEntry(time: 1200, bossId: 'bulgasari_boss'),
    BossEntry(time: 1500, bossId: 'yongwang'),
  ],
);

// 스테이지 4: 귀문관
const stage4 = StageData(
  id: 'gwimungwan', name: '귀문관', duration: 1500, bgm: 'stage_4', bossBgm: 'stage_boss_2',
  waves: [
    WaveEntry(startTime: 0, endTime: 120, enemies: [EnemyType.dokkaebiJol, EnemyType.bulyeou], spawnRate: 1.5),
    WaveEntry(startTime: 120, endTime: 300, enemies: [EnemyType.bulyeou, EnemyType.yacha, EnemyType.nalssaenDoli], spawnRate: 3.0),
    WaveEntry(startTime: 300, endTime: 600, enemies: [EnemyType.yacha, EnemyType.gapotGwisin, EnemyType.gangsi], spawnRate: 6.0),
    WaveEntry(startTime: 600, endTime: 1200, enemies: [EnemyType.gangsi, EnemyType.gapotGwisin, EnemyType.yacha, EnemyType.nalssaenDoli], spawnRate: 7.0),
    WaveEntry(startTime: 1200, endTime: 1500, enemies: EnemyType.values, spawnRate: 9.0),
  ],
  bosses: [
    BossEntry(time: 300, bossId: 'gumiho'),
    BossEntry(time: 600, bossId: 'jangsanbeom'),
    BossEntry(time: 900, bossId: 'bulgasari_boss'),
    BossEntry(time: 1200, bossId: 'yongwang'),
  ],
);

// 스테이지 5: 황천길
const stage5 = StageData(
  id: 'hwangcheon', name: '황천길', duration: 1500, bgm: 'stage_5', bossBgm: 'stage_boss_final',
  waves: [
    WaveEntry(startTime: 0, endTime: 120, enemies: [EnemyType.cheonyeoGwisin, EnemyType.gureongi], spawnRate: 2.0),
    WaveEntry(startTime: 120, endTime: 300, enemies: [EnemyType.gureongi, EnemyType.gangsi, EnemyType.cheonyeoGwisin], spawnRate: 4.0),
    WaveEntry(startTime: 300, endTime: 600, enemies: [EnemyType.gangsi, EnemyType.yacha, EnemyType.gapotGwisin], spawnRate: 7.0),
    WaveEntry(startTime: 600, endTime: 1200, enemies: EnemyType.values, spawnRate: 8.0),
    WaveEntry(startTime: 1200, endTime: 1500, enemies: EnemyType.values, spawnRate: 10.0),
  ],
  bosses: [
    BossEntry(time: 300, bossId: 'jangsanbeom'),
    BossEntry(time: 600, bossId: 'bulgasari_boss'),
    BossEntry(time: 900, bossId: 'yongwang'),
    BossEntry(time: 1200, bossId: 'yongwang'),
  ],
);

// 보너스 1: 도깨비 시장
const bonusStage1 = StageData(
  id: 'dokkaebi_market', name: '도깨비 시장', duration: 900,
  waves: [
    WaveEntry(startTime: 0, endTime: 300, enemies: [EnemyType.dokkaebiJol, EnemyType.nalssaenDoli], spawnRate: 3.0),
    WaveEntry(startTime: 300, endTime: 600, enemies: [EnemyType.dokkaebiJol, EnemyType.bulyeou, EnemyType.yacha], spawnRate: 6.0),
    WaveEntry(startTime: 600, endTime: 900, enemies: EnemyType.values, spawnRate: 10.0),
  ],
  bosses: [BossEntry(time: 450, bossId: 'dokkaebi_daejang')],
);

// 보너스 2: 무한의 탑
const bonusStage2 = StageData(
  id: 'infinite_tower', name: '무한의 탑', duration: 999999,
  waves: [
    WaveEntry(startTime: 0, endTime: 999999, enemies: EnemyType.values, spawnRate: 5.0),
  ],
  bosses: [],
);
