import 'enemies.dart';

class WeaponLevelData {
  final double damage;
  final int amount; // 발사 수
  final double cooldown;
  final double area; // 범위/각도
  final int pierce;
  final double speed; // 투사체 속도
  final double duration;
  final String bonus;

  const WeaponLevelData({
    required this.damage,
    this.amount = 1,
    required this.cooldown,
    this.area = 45,
    this.pierce = 0,
    this.speed = 300,
    this.duration = 3,
    this.bonus = '',
  });
}

class WeaponInfo {
  final String id;
  final String name;
  final String description;
  final Element element;
  final String pattern; // fan, homing, spin, straight, radial, aura, random, bounce, chase
  final List<WeaponLevelData> levels;
  final String? evolutionId;
  final String? requiredPassive;

  const WeaponInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.element,
    required this.pattern,
    required this.levels,
    this.evolutionId,
    this.requiredPassive,
  });
}

// ──────── 기본 무기 12종 ────────

const Map<String, WeaponInfo> weaponTable = {
  'toema_bujeok': WeaponInfo(
    id: 'toema_bujeok',
    name: '퇴마부적',
    description: '전방 부채꼴 부적 발사',
    element: Element.fire,
    pattern: 'fan',
    evolutionId: 'cheonloe_bujeok',
    requiredPassive: 'hwatotbul',
    levels: [
      WeaponLevelData(damage: 15, amount: 2, cooldown: 1.2, area: 50, pierce: 0, speed: 320),
      WeaponLevelData(damage: 17, amount: 2, cooldown: 1.1, area: 55, pierce: 0, speed: 320, bonus: 'DMG +13%'),
      WeaponLevelData(damage: 17, amount: 3, cooldown: 1.1, area: 65, pierce: 0, speed: 340, bonus: '발사+1'),
      WeaponLevelData(damage: 20, amount: 3, cooldown: 1.0, area: 65, pierce: 1, speed: 340, bonus: 'DMG+18% 관통+1'),
      WeaponLevelData(damage: 20, amount: 4, cooldown: 1.0, area: 75, pierce: 1, speed: 360, bonus: '발사+1'),
      WeaponLevelData(damage: 23, amount: 4, cooldown: 0.9, area: 80, pierce: 1, speed: 360, bonus: 'DMG+15%'),
      WeaponLevelData(damage: 23, amount: 5, cooldown: 0.9, area: 90, pierce: 2, speed: 380, bonus: '발사+1 관통+1'),
      WeaponLevelData(damage: 26, amount: 5, cooldown: 0.8, area: 90, pierce: 2, speed: 400, bonus: 'DMG+13%'),
    ],
  ),
  'binyeo_geom': WeaponInfo(
    id: 'binyeo_geom',
    name: '비녀검',
    description: '최근접 적에게 투척 후 귀환',
    element: Element.metal,
    pattern: 'homing',
    evolutionId: 'yongcheon_geom',
    requiredPassive: 'buchae',
    levels: [
      WeaponLevelData(damage: 20, amount: 1, cooldown: 1.4, speed: 400, duration: 1.8),
      WeaponLevelData(damage: 23, amount: 1, cooldown: 1.3, speed: 420, duration: 1.8),
      WeaponLevelData(damage: 23, amount: 2, cooldown: 1.3, speed: 420, duration: 2.0),
      WeaponLevelData(damage: 27, amount: 2, cooldown: 1.2, speed: 440, duration: 2.0),
      WeaponLevelData(damage: 27, amount: 3, cooldown: 1.2, speed: 460, duration: 2.2),
      WeaponLevelData(damage: 31, amount: 3, cooldown: 1.1, speed: 480, duration: 2.2),
      WeaponLevelData(damage: 31, amount: 4, cooldown: 1.0, speed: 500, duration: 2.4),
      WeaponLevelData(damage: 36, amount: 4, cooldown: 0.9, speed: 520, duration: 2.6),
    ],
  ),
  'cheongryongdo': WeaponInfo(
    id: 'cheongryongdo',
    name: '청룡도',
    description: '주변 회전 참격',
    element: Element.wood,
    pattern: 'spin',
    evolutionId: 'cheongryong_eonwoldo',
    requiredPassive: 'durumari',
    levels: [
      WeaponLevelData(damage: 18, amount: 1, cooldown: 1.0, area: 100),
      WeaponLevelData(damage: 20, amount: 1, cooldown: 0.95, area: 110),
      WeaponLevelData(damage: 20, amount: 2, cooldown: 0.9, area: 110),
      WeaponLevelData(damage: 23, amount: 2, cooldown: 0.85, area: 120),
      WeaponLevelData(damage: 23, amount: 2, cooldown: 0.8, area: 130, pierce: 1),
      WeaponLevelData(damage: 26, amount: 3, cooldown: 0.75, area: 140, pierce: 1),
      WeaponLevelData(damage: 26, amount: 3, cooldown: 0.7, area: 150, pierce: 1),
      WeaponLevelData(damage: 30, amount: 3, cooldown: 0.6, area: 160, pierce: 2),
    ],
  ),
  'geumgangeo': WeaponInfo(
    id: 'geumgangeo',
    name: '금강저',
    description: '전방 직선 충격파',
    element: Element.earth,
    pattern: 'straight',
    evolutionId: 'hangma_geumgangeo',
    requiredPassive: 'insam',
    levels: [
      WeaponLevelData(damage: 28, amount: 1, cooldown: 1.6, speed: 450, area: 30),
      WeaponLevelData(damage: 32, amount: 1, cooldown: 1.5, speed: 470, area: 32),
      WeaponLevelData(damage: 32, amount: 1, cooldown: 1.4, speed: 490, area: 34, pierce: 1),
      WeaponLevelData(damage: 36, amount: 1, cooldown: 1.3, speed: 510, area: 36, pierce: 1),
      WeaponLevelData(damage: 36, amount: 2, cooldown: 1.2, speed: 530, area: 38, pierce: 2),
      WeaponLevelData(damage: 40, amount: 2, cooldown: 1.1, speed: 550, area: 40, pierce: 2),
      WeaponLevelData(damage: 40, amount: 2, cooldown: 1.0, speed: 570, area: 44, pierce: 3),
      WeaponLevelData(damage: 45, amount: 3, cooldown: 0.9, speed: 600, area: 48, pierce: 3),
    ],
  ),
  'sinseong_bangul': WeaponInfo(
    id: 'sinseong_bangul',
    name: '신성 방울',
    description: '원형 음파 확산',
    element: Element.water,
    pattern: 'radial',
    evolutionId: 'cheonji_bangul',
    requiredPassive: 'hyangro',
    levels: [
      WeaponLevelData(damage: 12, amount: 6, cooldown: 0.9, area: 90, speed: 240),
      WeaponLevelData(damage: 13, amount: 6, cooldown: 0.85, area: 100, speed: 250),
      WeaponLevelData(damage: 13, amount: 8, cooldown: 0.8, area: 110, speed: 260),
      WeaponLevelData(damage: 15, amount: 8, cooldown: 0.75, area: 120, speed: 280),
      WeaponLevelData(damage: 15, amount: 10, cooldown: 0.7, area: 130, speed: 300),
      WeaponLevelData(damage: 17, amount: 10, cooldown: 0.65, area: 140, speed: 320),
      WeaponLevelData(damage: 17, amount: 12, cooldown: 0.6, area: 150, speed: 340),
      WeaponLevelData(damage: 20, amount: 12, cooldown: 0.5, area: 170, speed: 360),
    ],
  ),
  'pungmul_buk': WeaponInfo(
    id: 'pungmul_buk',
    name: '풍물북',
    description: '랜덤 위치 폭발',
    element: Element.fire,
    pattern: 'random',
    evolutionId: 'samulnori',
    requiredPassive: 'janggu',
    levels: [
      WeaponLevelData(damage: 25, amount: 2, cooldown: 1.5, area: 80),
      WeaponLevelData(damage: 28, amount: 2, cooldown: 1.4, area: 88),
      WeaponLevelData(damage: 28, amount: 3, cooldown: 1.3, area: 88),
      WeaponLevelData(damage: 32, amount: 3, cooldown: 1.2, area: 96),
      WeaponLevelData(damage: 32, amount: 4, cooldown: 1.1, area: 104),
      WeaponLevelData(damage: 36, amount: 4, cooldown: 1.0, area: 112),
      WeaponLevelData(damage: 36, amount: 5, cooldown: 0.9, area: 120),
      WeaponLevelData(damage: 40, amount: 5, cooldown: 0.8, area: 128),
    ],
  ),
  'yogi_baltop': WeaponInfo(
    id: 'yogi_baltop',
    name: '요기 발톱',
    description: '근접 연속 할퀴기',
    element: Element.wood,
    pattern: 'melee',
    evolutionId: 'gumiho_baltop',
    requiredPassive: 'yeouguseul',
    levels: [
      WeaponLevelData(damage: 10, amount: 1, cooldown: 0.35, area: 60),
      WeaponLevelData(damage: 12, amount: 1, cooldown: 0.32, area: 64),
      WeaponLevelData(damage: 12, amount: 2, cooldown: 0.3, area: 68),
      WeaponLevelData(damage: 14, amount: 2, cooldown: 0.28, area: 72),
      WeaponLevelData(damage: 14, amount: 3, cooldown: 0.26, area: 76),
      WeaponLevelData(damage: 16, amount: 3, cooldown: 0.24, area: 80),
      WeaponLevelData(damage: 16, amount: 4, cooldown: 0.28, area: 88),
      WeaponLevelData(damage: 20, amount: 4, cooldown: 0.25, area: 96),
    ],
  ),
  'palgwaejin': WeaponInfo(
    id: 'palgwaejin',
    name: '팔괘진',
    description: '8방향 기운 발사',
    element: Element.earth,
    pattern: 'radial8',
    evolutionId: 'taegeukjin',
    requiredPassive: 'nachimban',
    levels: [
      WeaponLevelData(damage: 12, amount: 8, cooldown: 1.4, speed: 280),
      WeaponLevelData(damage: 13, amount: 8, cooldown: 1.3, speed: 290),
      WeaponLevelData(damage: 13, amount: 8, cooldown: 1.2, speed: 300, pierce: 1),
      WeaponLevelData(damage: 15, amount: 8, cooldown: 1.1, speed: 310, pierce: 1),
      WeaponLevelData(damage: 15, amount: 12, cooldown: 1.0, speed: 330, pierce: 1),
      WeaponLevelData(damage: 17, amount: 12, cooldown: 0.9, speed: 350, pierce: 2),
      WeaponLevelData(damage: 17, amount: 16, cooldown: 0.85, speed: 370, pierce: 2),
      WeaponLevelData(damage: 20, amount: 16, cooldown: 0.75, speed: 400, pierce: 3),
    ],
  ),
  'hwasal': WeaponInfo(
    id: 'hwasal',
    name: '화살(활)',
    description: '전방 연속 발사',
    element: Element.metal,
    pattern: 'straight',
    evolutionId: 'singung',
    requiredPassive: 'mae_gitteol',
    levels: [
      WeaponLevelData(damage: 14, amount: 1, cooldown: 0.55, speed: 550, area: 28),
      WeaponLevelData(damage: 16, amount: 1, cooldown: 0.5, speed: 570, area: 30),
      WeaponLevelData(damage: 16, amount: 2, cooldown: 0.48, speed: 590, area: 30),
      WeaponLevelData(damage: 18, amount: 2, cooldown: 0.45, speed: 610, area: 32),
      WeaponLevelData(damage: 18, amount: 2, cooldown: 0.42, speed: 630, area: 32, pierce: 1),
      WeaponLevelData(damage: 20, amount: 3, cooldown: 0.38, speed: 650, area: 34, pierce: 1),
      WeaponLevelData(damage: 20, amount: 3, cooldown: 0.35, speed: 670, area: 36, pierce: 2),
      WeaponLevelData(damage: 24, amount: 4, cooldown: 0.3, speed: 700, area: 40, pierce: 2),
    ],
  ),
  'dokangae': WeaponInfo(
    id: 'dokangae',
    name: '독안개',
    description: '주변 독 안개장',
    element: Element.water,
    pattern: 'aura',
    evolutionId: 'hwangcheon_dokmu',
    requiredPassive: 'doksa_ippal',
    levels: [
      WeaponLevelData(damage: 7, amount: 1, cooldown: 0.30, area: 72),
      WeaponLevelData(damage: 8, amount: 1, cooldown: 0.28, area: 78),
      WeaponLevelData(damage: 8, amount: 1, cooldown: 0.26, area: 84),
      WeaponLevelData(damage: 9, amount: 1, cooldown: 0.24, area: 90),
      WeaponLevelData(damage: 9, amount: 1, cooldown: 0.22, area: 96),
      WeaponLevelData(damage: 10, amount: 1, cooldown: 0.20, area: 104),
      WeaponLevelData(damage: 10, amount: 1, cooldown: 0.18, area: 112),
      WeaponLevelData(damage: 12, amount: 1, cooldown: 0.16, area: 120),
    ],
  ),
  'dolpalmae': WeaponInfo(
    id: 'dolpalmae',
    name: '돌팔매',
    description: '랜덤 바운스 투척',
    element: Element.earth,
    pattern: 'bounce',
    evolutionId: 'bulgasari',
    requiredPassive: 'dukkeobi_seoksang',
    levels: [
      WeaponLevelData(damage: 20, amount: 1, cooldown: 1.1, speed: 400, pierce: 2),
      WeaponLevelData(damage: 22, amount: 1, cooldown: 1.0, speed: 410, pierce: 2),
      WeaponLevelData(damage: 22, amount: 1, cooldown: 0.95, speed: 420, pierce: 3),
      WeaponLevelData(damage: 25, amount: 2, cooldown: 0.9, speed: 430, pierce: 3),
      WeaponLevelData(damage: 25, amount: 2, cooldown: 0.85, speed: 450, pierce: 4),
      WeaponLevelData(damage: 28, amount: 2, cooldown: 0.8, speed: 470, pierce: 4),
      WeaponLevelData(damage: 28, amount: 3, cooldown: 0.75, speed: 490, pierce: 5),
      WeaponLevelData(damage: 32, amount: 3, cooldown: 0.65, speed: 520, pierce: 6),
    ],
  ),
  'cheondung': WeaponInfo(
    id: 'cheondung',
    name: '천둥',
    description: '주변 적에게 충격파 연쇄 타격',
    element: Element.metal,
    pattern: 'radial',
    levels: [
      WeaponLevelData(damage: 22, amount: 3, cooldown: 1.8, area: 120, speed: 200),
      WeaponLevelData(damage: 25, amount: 3, cooldown: 1.7, area: 130, speed: 210),
      WeaponLevelData(damage: 25, amount: 4, cooldown: 1.6, area: 140, speed: 220),
      WeaponLevelData(damage: 28, amount: 4, cooldown: 1.5, area: 150, speed: 240),
      WeaponLevelData(damage: 28, amount: 5, cooldown: 1.4, area: 160, speed: 260),
      WeaponLevelData(damage: 32, amount: 5, cooldown: 1.3, area: 170, speed: 280),
      WeaponLevelData(damage: 32, amount: 6, cooldown: 1.2, area: 180, speed: 300),
      WeaponLevelData(damage: 36, amount: 6, cooldown: 1.0, area: 200, speed: 320),
    ],
  ),
  'punggyeong': WeaponInfo(
    id: 'punggyeong',
    name: '풍경',
    description: '바람 음파로 넓은 범위 슬로우',
    element: Element.wood,
    pattern: 'radial',
    levels: [
      WeaponLevelData(damage: 10, amount: 4, cooldown: 1.6, area: 100, speed: 180),
      WeaponLevelData(damage: 11, amount: 4, cooldown: 1.5, area: 110, speed: 190),
      WeaponLevelData(damage: 11, amount: 5, cooldown: 1.4, area: 120, speed: 200),
      WeaponLevelData(damage: 13, amount: 5, cooldown: 1.3, area: 130, speed: 220),
      WeaponLevelData(damage: 13, amount: 6, cooldown: 1.2, area: 140, speed: 240),
      WeaponLevelData(damage: 15, amount: 6, cooldown: 1.1, area: 150, speed: 260),
      WeaponLevelData(damage: 15, amount: 8, cooldown: 1.0, area: 160, speed: 280),
      WeaponLevelData(damage: 18, amount: 8, cooldown: 0.85, area: 180, speed: 300),
    ],
  ),
  'dokkaebi_bul': WeaponInfo(
    id: 'dokkaebi_bul',
    name: '도깨비불',
    description: '추적형 불꽃 소환',
    element: Element.fire,
    pattern: 'chase',
    evolutionId: 'sammae_jinhwa',
    requiredPassive: 'deungjan',
    levels: [
      WeaponLevelData(damage: 12, amount: 2, cooldown: 2.0, speed: 180, duration: 6),
      WeaponLevelData(damage: 14, amount: 2, cooldown: 1.8, speed: 190, duration: 6.5),
      WeaponLevelData(damage: 14, amount: 3, cooldown: 1.7, speed: 200, duration: 7),
      WeaponLevelData(damage: 16, amount: 3, cooldown: 1.5, speed: 210, duration: 7.5),
      WeaponLevelData(damage: 16, amount: 4, cooldown: 1.4, speed: 230, duration: 8),
      WeaponLevelData(damage: 18, amount: 4, cooldown: 1.2, speed: 250, duration: 8.5),
      WeaponLevelData(damage: 18, amount: 5, cooldown: 1.1, speed: 270, duration: 9),
      WeaponLevelData(damage: 22, amount: 5, cooldown: 0.9, speed: 300, duration: 10),
    ],
  ),

  // ──────── 진화 무기 12종 (Lv.1 고정, 원본 Lv.8 × ~1.5) ────────

  'cheonloe_bujeok': WeaponInfo(
    id: 'cheonloe_bujeok', name: '천뢰부적',
    description: '번개 속성, 관통 시 연쇄 번개(3바운스)',
    element: Element.fire, pattern: 'fan',
    levels: [WeaponLevelData(damage: 40, amount: 7, cooldown: 0.6, area: 120, pierce: 5, speed: 500)],
  ),
  'yongcheon_geom': WeaponInfo(
    id: 'yongcheon_geom', name: '용천검',
    description: '검 3배, 회전 귀환, 복귀 시 추가 DMG',
    element: Element.metal, pattern: 'homing',
    levels: [WeaponLevelData(damage: 55, amount: 6, cooldown: 0.7, speed: 600, duration: 3.5)],
  ),
  'cheongryong_eonwoldo': WeaponInfo(
    id: 'cheongryong_eonwoldo', name: '청룡언월도',
    description: '범위 2배, 통과 시 밀어내기+슬로우',
    element: Element.wood, pattern: 'spin',
    levels: [WeaponLevelData(damage: 45, amount: 4, cooldown: 0.45, area: 240, pierce: 4)],
  ),
  'hangma_geumgangeo': WeaponInfo(
    id: 'hangma_geumgangeo', name: '항마금강저',
    description: '3갈래 분기, 넉백 3배, 5% HP 회복',
    element: Element.earth, pattern: 'straight',
    levels: [WeaponLevelData(damage: 65, amount: 3, cooldown: 0.7, speed: 700, area: 60, pierce: 5)],
  ),
  'cheonji_bangul': WeaponInfo(
    id: 'cheonji_bangul', name: '천지방울',
    description: '범위 화면 50%, 적 이속 -30%',
    element: Element.water, pattern: 'radial',
    levels: [WeaponLevelData(damage: 30, amount: 16, cooldown: 0.4, area: 250, speed: 420)],
  ),
  'samulnori': WeaponInfo(
    id: 'samulnori', name: '사물놀이',
    description: '폭발 8개 동시, 연쇄 반응',
    element: Element.fire, pattern: 'random',
    levels: [WeaponLevelData(damage: 60, amount: 8, cooldown: 0.6, area: 160)],
  ),
  'gumiho_baltop': WeaponInfo(
    id: 'gumiho_baltop', name: '구미호 발톱',
    description: '공속 2배, 흡혈 10%, 치명타 시 분신',
    element: Element.wood, pattern: 'melee',
    levels: [WeaponLevelData(damage: 28, amount: 6, cooldown: 0.15, area: 120)],
  ),
  'taegeukjin': WeaponInfo(
    id: 'taegeukjin', name: '태극진',
    description: '16방향, 관통 후 가속',
    element: Element.earth, pattern: 'radial8',
    levels: [WeaponLevelData(damage: 30, amount: 24, cooldown: 0.55, speed: 500, pierce: 5)],
  ),
  'singung': WeaponInfo(
    id: 'singung', name: '신궁',
    description: '자동 조준(최강적), 치명타 100%, 관통 무한',
    element: Element.metal, pattern: 'straight',
    levels: [WeaponLevelData(damage: 35, amount: 5, cooldown: 0.2, speed: 800, area: 48, pierce: 99)],
  ),
  'hwangcheon_dokmu': WeaponInfo(
    id: 'hwangcheon_dokmu', name: '황천독무',
    description: '독 구름 이동+확산, 폭발 전파',
    element: Element.water, pattern: 'aura',
    levels: [WeaponLevelData(damage: 20, amount: 1, cooldown: 0.1, area: 180)],
  ),
  'bulgasari': WeaponInfo(
    id: 'bulgasari', name: '불가사리',
    description: '거대 철덩이, 무한 바운스, 커짐',
    element: Element.earth, pattern: 'bounce',
    levels: [WeaponLevelData(damage: 50, amount: 4, cooldown: 0.5, speed: 600, pierce: 99)],
  ),
  'sammae_jinhwa': WeaponInfo(
    id: 'sammae_jinhwa', name: '삼매진화',
    description: '추적 불꽃 8개, 사망 시 분열 소환',
    element: Element.fire, pattern: 'chase',
    levels: [WeaponLevelData(damage: 35, amount: 8, cooldown: 0.7, speed: 350, duration: 12)],
  ),

  // ──────── 합체 무기 3종 (특수 패턴) ────────

  'cheonji_gaebyeok': WeaponInfo(
    id: 'cheonji_gaebyeok', name: '천지개벽',
    description: '화면 전체 번개+기운 폭풍',
    element: Element.fire, pattern: 'radial',
    levels: [WeaponLevelData(damage: 80, amount: 24, cooldown: 10.0, area: 500, speed: 200)],
  ),
  'samsin_halmi': WeaponInfo(
    id: 'samsin_halmi', name: '삼신할미의 축복',
    description: '전체 HP 회복 + 대량 넉백',
    element: Element.water, pattern: 'radial',
    levels: [WeaponLevelData(damage: 50, amount: 16, cooldown: 15.0, area: 400, speed: 150)],
  ),
  'gumiho_hyeonsin': WeaponInfo(
    id: 'gumiho_hyeonsin', name: '구미호 현신',
    description: '거대 구미호 분신 소환 (20초간 자동전투)',
    element: Element.wood, pattern: 'chase',
    levels: [WeaponLevelData(damage: 45, amount: 6, cooldown: 20.0, speed: 250, duration: 20)],
  ),
};
