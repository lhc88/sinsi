class CharacterData {
  final String id;
  final String name;
  final String job;
  final String startWeapon;
  final String passiveDesc;
  final double baseHp;
  final double baseMight;
  final double baseSpeed;
  final double baseCooldown;
  final double baseArea;
  final double basePickupRange;
  final String unlockCondition;
  final List<SkillTreePath> skillTree;

  const CharacterData({
    required this.id,
    required this.name,
    required this.job,
    required this.startWeapon,
    required this.passiveDesc,
    this.baseHp = 100,
    this.baseMight = 1.0,
    this.baseSpeed = 1.0,
    this.baseCooldown = 1.0,
    this.baseArea = 1.0,
    this.basePickupRange = 64,
    required this.unlockCondition,
    required this.skillTree,
  });
}

class SkillTreePath {
  final String name;
  final List<SkillNode> nodes;

  const SkillTreePath({required this.name, required this.nodes});
}

class SkillNode {
  final int level; // 1~3
  final String description;
  final int doryeokCost;

  const SkillNode({required this.level, required this.description, required this.doryeokCost});
}

const Map<String, CharacterData> characterTable = {
  'lee_taeyang': CharacterData(
    id: 'lee_taeyang', name: '이태양', job: '퇴마사',
    startWeapon: 'toema_bujeok',
    passiveDesc: '부적 공격력 +10%',
    baseHp: 100, baseMight: 1.1,
    unlockCondition: '기본 해금',
    skillTree: [
      SkillTreePath(name: '퇴마의 불꽃', nodes: [
        SkillNode(level: 1, description: '부적 DMG +15%', doryeokCost: 5),
        SkillNode(level: 2, description: '부적 관통 +1', doryeokCost: 10),
        SkillNode(level: 3, description: '관통 시 분열 (2갈래)', doryeokCost: 20),
      ]),
      SkillTreePath(name: '수호의 결계', nodes: [
        SkillNode(level: 1, description: '피격 시 1초 무적 추가', doryeokCost: 5),
        SkillNode(level: 2, description: 'HP 50% 이하 방어 +30%', doryeokCost: 10),
        SkillNode(level: 3, description: '사망 시 폭발+부활', doryeokCost: 20),
      ]),
      SkillTreePath(name: '기운 순환', nodes: [
        SkillNode(level: 1, description: '기운 수집 10% 확률 2배', doryeokCost: 5),
        SkillNode(level: 2, description: '레벨업 선택지 4→5개', doryeokCost: 10),
        SkillNode(level: 3, description: '30초마다 자석 자동 발동', doryeokCost: 20),
      ]),
    ],
  ),
  'wolhui': CharacterData(
    id: 'wolhui', name: '월희', job: '무녀',
    startWeapon: 'sinseong_bangul',
    passiveDesc: '기운 +15%, 수집 범위 +10%',
    baseHp: 90, basePickupRange: 70,
    unlockCondition: '기본 해금',
    skillTree: [
      SkillTreePath(name: '신내림', nodes: [
        SkillNode(level: 1, description: '방울 범위 +20%', doryeokCost: 5),
        SkillNode(level: 2, description: '방울 슬로우 효과 추가', doryeokCost: 10),
        SkillNode(level: 3, description: '방울 적 관통 무한', doryeokCost: 20),
      ]),
      SkillTreePath(name: '치유의 춤', nodes: [
        SkillNode(level: 1, description: 'HP 회복 +0.3/s', doryeokCost: 5),
        SkillNode(level: 2, description: '레벨업 시 HP 20% 회복', doryeokCost: 10),
        SkillNode(level: 3, description: 'HP 30% 이하 자동 회복 버스트', doryeokCost: 20),
      ]),
      SkillTreePath(name: '기운 폭풍', nodes: [
        SkillNode(level: 1, description: '기운 수집 범위 +20%', doryeokCost: 5),
        SkillNode(level: 2, description: '기운 대량 수집 시 DMG 버프', doryeokCost: 10),
        SkillNode(level: 3, description: '60초마다 화면 전체 기운 수집', doryeokCost: 20),
      ]),
    ],
  ),
  'cheolwoong': CharacterData(
    id: 'cheolwoong', name: '철웅', job: '장군',
    startWeapon: 'cheongryongdo',
    passiveDesc: 'HP +30, 넉백 저항 +20%',
    baseHp: 130, baseSpeed: 0.9,
    unlockCondition: '스테이지 1 클리어',
    skillTree: [
      SkillTreePath(name: '무장의 힘', nodes: [
        SkillNode(level: 1, description: '청룡도 DMG +20%', doryeokCost: 5),
        SkillNode(level: 2, description: '넉백 면역', doryeokCost: 10),
        SkillNode(level: 3, description: '근접 무기 범위 +40%', doryeokCost: 20),
      ]),
      SkillTreePath(name: '철벽', nodes: [
        SkillNode(level: 1, description: '받는 DMG -10%', doryeokCost: 5),
        SkillNode(level: 2, description: 'HP 50% 이하 방어 2배', doryeokCost: 10),
        SkillNode(level: 3, description: '사망 시 HP 1로 버티기 (1회)', doryeokCost: 20),
      ]),
      SkillTreePath(name: '진군', nodes: [
        SkillNode(level: 1, description: '이동속도 +10%', doryeokCost: 5),
        SkillNode(level: 2, description: '이동 중 주변 적 밀어내기', doryeokCost: 10),
        SkillNode(level: 3, description: '돌진 스킬 (5초마다)', doryeokCost: 20),
      ]),
    ],
  ),
  'soyeon': CharacterData(
    id: 'soyeon', name: '소연', job: '궁녀 암살자',
    startWeapon: 'binyeo_geom',
    passiveDesc: '치명타 +8%, 치명타 DMG +20%',
    baseHp: 80, baseMight: 1.0, baseSpeed: 1.1,
    unlockCondition: '적 1000마리 처치',
    skillTree: [
      SkillTreePath(name: '암살', nodes: [
        SkillNode(level: 1, description: '치명타 +10%', doryeokCost: 5),
        SkillNode(level: 2, description: '치명타 DMG +50%', doryeokCost: 10),
        SkillNode(level: 3, description: '치명타 시 2초 은신', doryeokCost: 20),
      ]),
      SkillTreePath(name: '민첩', nodes: [
        SkillNode(level: 1, description: '이속 +15%', doryeokCost: 5),
        SkillNode(level: 2, description: '회피 10% (피격 무효)', doryeokCost: 10),
        SkillNode(level: 3, description: '3초마다 대시 (무적)', doryeokCost: 20),
      ]),
      SkillTreePath(name: '독', nodes: [
        SkillNode(level: 1, description: '피격 적 독 부여', doryeokCost: 5),
        SkillNode(level: 2, description: '독 DMG +30%', doryeokCost: 10),
        SkillNode(level: 3, description: '독 사망 시 폭발 전파', doryeokCost: 20),
      ]),
    ],
  ),
  'beopwoon': CharacterData(
    id: 'beopwoon', name: '법운', job: '승려',
    startWeapon: 'geumgangeo',
    passiveDesc: '부활 +1, HP 회복 +0.3/s',
    baseHp: 110, baseMight: 0.9,
    unlockCondition: '스테이지 2 클리어',
    skillTree: [
      SkillTreePath(name: '금강', nodes: [
        SkillNode(level: 1, description: '금강저 넉백 +50%', doryeokCost: 5),
        SkillNode(level: 2, description: '금강저 3방향', doryeokCost: 10),
        SkillNode(level: 3, description: '금강 결계 (주변 방어막)', doryeokCost: 20),
      ]),
      SkillTreePath(name: '자비', nodes: [
        SkillNode(level: 1, description: '부활 +1', doryeokCost: 5),
        SkillNode(level: 2, description: '부활 시 무적 5초', doryeokCost: 10),
        SkillNode(level: 3, description: '부활 시 화면 전체 공격', doryeokCost: 20),
      ]),
      SkillTreePath(name: '명상', nodes: [
        SkillNode(level: 1, description: 'HP 회복 +0.5/s', doryeokCost: 5),
        SkillNode(level: 2, description: '정지 시 회복 3배', doryeokCost: 10),
        SkillNode(level: 3, description: 'HP 풀 시 DMG +30%', doryeokCost: 20),
      ]),
    ],
  ),
  'danbi': CharacterData(
    id: 'danbi', name: '단비', job: '풍물패',
    startWeapon: 'pungmul_buk',
    passiveDesc: '범위 +25%, 쿨다운 -5%',
    baseHp: 90, baseArea: 1.25, baseCooldown: 0.95,
    unlockCondition: '상자 50개 획득',
    skillTree: [
      SkillTreePath(name: '신명', nodes: [
        SkillNode(level: 1, description: '폭발 범위 +30%', doryeokCost: 5),
        SkillNode(level: 2, description: '연쇄 폭발 확률 20%', doryeokCost: 10),
        SkillNode(level: 3, description: '폭발마다 적 슬로우', doryeokCost: 20),
      ]),
      SkillTreePath(name: '흥', nodes: [
        SkillNode(level: 1, description: '쿨다운 -10%', doryeokCost: 5),
        SkillNode(level: 2, description: '킬 10마리마다 쿨 리셋', doryeokCost: 10),
        SkillNode(level: 3, description: '광폭화 모드 (15초)', doryeokCost: 20),
      ]),
      SkillTreePath(name: '축제', nodes: [
        SkillNode(level: 1, description: '기운 드롭률 +15%', doryeokCost: 5),
        SkillNode(level: 2, description: '엽전 드롭률 +20%', doryeokCost: 10),
        SkillNode(level: 3, description: '보물상자 등급 +1', doryeokCost: 20),
      ]),
    ],
  ),
  'gwison': CharacterData(
    id: 'gwison', name: '귀손', job: '반요',
    startWeapon: 'yogi_baltop',
    passiveDesc: '반격 10 DMG, 흡혈 +3%',
    baseHp: 95, baseMight: 1.05,
    unlockCondition: '도깨비 대장 처치',
    skillTree: [
      SkillTreePath(name: '요기', nodes: [
        SkillNode(level: 1, description: '발톱 공속 +20%', doryeokCost: 5),
        SkillNode(level: 2, description: '흡혈 +5%', doryeokCost: 10),
        SkillNode(level: 3, description: '변신 (30초 전스탯 +30%)', doryeokCost: 20),
      ]),
      SkillTreePath(name: '반격', nodes: [
        SkillNode(level: 1, description: '피격 시 반격 DMG +20', doryeokCost: 5),
        SkillNode(level: 2, description: '반격 넉백 추가', doryeokCost: 10),
        SkillNode(level: 3, description: '반격 범위 화면 50%', doryeokCost: 20),
      ]),
      SkillTreePath(name: '야성', nodes: [
        SkillNode(level: 1, description: 'HP 50% 이하 이속 +20%', doryeokCost: 5),
        SkillNode(level: 2, description: 'HP 30% 이하 DMG +30%', doryeokCost: 10),
        SkillNode(level: 3, description: 'HP 10% 이하 무적 3초 (1회)', doryeokCost: 20),
      ]),
    ],
  ),
  'cheonmoo': CharacterData(
    id: 'cheonmoo', name: '천무', job: '도사',
    startWeapon: 'palgwaejin',
    passiveDesc: '쿨다운 -10%, 지속 +10%',
    baseHp: 85, baseCooldown: 0.9,
    unlockCondition: '무기 5종 진화',
    skillTree: [
      SkillTreePath(name: '도술', nodes: [
        SkillNode(level: 1, description: '팔괘진 투사체 +4', doryeokCost: 5),
        SkillNode(level: 2, description: '투사체 관통 +2', doryeokCost: 10),
        SkillNode(level: 3, description: '투사체 추적 기능', doryeokCost: 20),
      ]),
      SkillTreePath(name: '오행', nodes: [
        SkillNode(level: 1, description: '원소 DMG +10%', doryeokCost: 5),
        SkillNode(level: 2, description: '상극 배율 x1.5→x2.0', doryeokCost: 10),
        SkillNode(level: 3, description: '시너지 보너스 2배', doryeokCost: 20),
      ]),
      SkillTreePath(name: '영적 수련', nodes: [
        SkillNode(level: 1, description: '지속시간 +15%', doryeokCost: 5),
        SkillNode(level: 2, description: '쿨다운 -10%', doryeokCost: 10),
        SkillNode(level: 3, description: '60초마다 무기 전체 1회 추가 발동', doryeokCost: 20),
      ]),
    ],
  ),
};
