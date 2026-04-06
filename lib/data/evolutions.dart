import 'enemies.dart';

class EvolutionData {
  final String id;
  final String name;
  final String sourceWeapon;
  final String requiredPassive;
  final String description;
  final Element element;

  const EvolutionData({
    required this.id,
    required this.name,
    required this.sourceWeapon,
    required this.requiredPassive,
    required this.description,
    required this.element,
  });
}

class UnionData {
  final String id;
  final String name;
  final String weapon1;
  final String weapon2;
  final String description;
  final double cooldown;

  const UnionData({
    required this.id,
    required this.name,
    required this.weapon1,
    required this.weapon2,
    required this.description,
    required this.cooldown,
  });
}

const Map<String, EvolutionData> evolutionTable = {
  'cheonloe_bujeok': EvolutionData(
    id: 'cheonloe_bujeok', name: '천뢰부적',
    sourceWeapon: 'toema_bujeok', requiredPassive: 'hwatotbul',
    description: '번개 속성, 관통 시 연쇄 번개(3바운스)',
    element: Element.fire,
  ),
  'yongcheon_geom': EvolutionData(
    id: 'yongcheon_geom', name: '용천검',
    sourceWeapon: 'binyeo_geom', requiredPassive: 'buchae',
    description: '검 3배, 회전 귀환, 복귀 시 추가 DMG',
    element: Element.metal,
  ),
  'cheongryong_eonwoldo': EvolutionData(
    id: 'cheongryong_eonwoldo', name: '청룡언월도',
    sourceWeapon: 'cheongryongdo', requiredPassive: 'durumari',
    description: '범위 2배, 통과 시 밀어내기+슬로우',
    element: Element.wood,
  ),
  'hangma_geumgangeo': EvolutionData(
    id: 'hangma_geumgangeo', name: '항마금강저',
    sourceWeapon: 'geumgangeo', requiredPassive: 'insam',
    description: '3갈래 분기, 넉백 3배, 5% HP 회복',
    element: Element.earth,
  ),
  'cheonji_bangul': EvolutionData(
    id: 'cheonji_bangul', name: '천지방울',
    sourceWeapon: 'sinseong_bangul', requiredPassive: 'hyangro',
    description: '범위 화면 50%, 적 이속 -30%',
    element: Element.water,
  ),
  'samulnori': EvolutionData(
    id: 'samulnori', name: '사물놀이',
    sourceWeapon: 'pungmul_buk', requiredPassive: 'janggu',
    description: '폭발 8개 동시, 연쇄 반응',
    element: Element.fire,
  ),
  'gumiho_baltop': EvolutionData(
    id: 'gumiho_baltop', name: '구미호 발톱',
    sourceWeapon: 'yogi_baltop', requiredPassive: 'yeouguseul',
    description: '공속 2배, 흡혈 10%, 치명타 시 분신',
    element: Element.wood,
  ),
  'taegeukjin': EvolutionData(
    id: 'taegeukjin', name: '태극진',
    sourceWeapon: 'palgwaejin', requiredPassive: 'nachimban',
    description: '16방향, 관통 후 가속',
    element: Element.earth,
  ),
  'singung': EvolutionData(
    id: 'singung', name: '신궁',
    sourceWeapon: 'hwasal', requiredPassive: 'mae_gitteol',
    description: '자동 조준(최강적), 치명타 100%, 관통 무한',
    element: Element.metal,
  ),
  'hwangcheon_dokmu': EvolutionData(
    id: 'hwangcheon_dokmu', name: '황천독무',
    sourceWeapon: 'dokangae', requiredPassive: 'doksa_ippal',
    description: '독 구름 이동+확산, 폭발 전파',
    element: Element.water,
  ),
  'bulgasari': EvolutionData(
    id: 'bulgasari', name: '불가사리',
    sourceWeapon: 'dolpalmae', requiredPassive: 'dukkeobi_seoksang',
    description: '거대 철덩이, 무한 바운스, 커짐',
    element: Element.earth,
  ),
  'sammae_jinhwa': EvolutionData(
    id: 'sammae_jinhwa', name: '삼매진화',
    sourceWeapon: 'dokkaebi_bul', requiredPassive: 'deungjan',
    description: '추적 불꽃 8개, 사망 시 분열 소환',
    element: Element.fire,
  ),
};

const Map<String, UnionData> unionTable = {
  'cheonji_gaebyeok': UnionData(
    id: 'cheonji_gaebyeok', name: '천지개벽',
    weapon1: 'cheonloe_bujeok', weapon2: 'taegeukjin',
    description: '화면 전체 번개+기운 폭풍',
    cooldown: 10,
  ),
  'samsin_halmi': UnionData(
    id: 'samsin_halmi', name: '삼신할미의 축복',
    weapon1: 'sinseong_bangul', weapon2: 'geumgangeo',
    description: '전체 HP 회복 + 대량 넉백',
    cooldown: 15,
  ),
  'gumiho_hyeonsin': UnionData(
    id: 'gumiho_hyeonsin', name: '구미호 현신',
    weapon1: 'yogi_baltop', weapon2: 'dokkaebi_bul',
    description: '거대 구미호 분신 소환 (20초간 자동전투)',
    cooldown: 20,
  ),
};
