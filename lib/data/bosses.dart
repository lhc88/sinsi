import 'dart:ui';
import 'enemies.dart';
import '../utils/constants.dart';

enum BossPattern { rotate, summon, enrage, charm, radial8, clone, soundWave, buffAllies, stealth, charge, quake, invincible, waterPillar, whirlpool, tsunami }

class BossPatternData {
  final BossPattern pattern;
  final double cooldown;
  final double damage;
  final String description;

  const BossPatternData({
    required this.pattern,
    required this.cooldown,
    required this.damage,
    required this.description,
  });
}

class BossData {
  final String id;
  final String name;
  final Element element;
  final double hp;
  final double speed;
  final double size;
  final Color color;
  final List<BossPatternData> patterns;
  final String dropChest; // 상자 등급

  const BossData({
    required this.id,
    required this.name,
    required this.element,
    required this.hp,
    this.speed = 40,
    this.size = 96,
    required this.color,
    required this.patterns,
    this.dropChest = 'iron',
  });
}

const Map<String, BossData> bossTable = {
  'dokkaebi_daejang': BossData(
    id: 'dokkaebi_daejang', name: '도깨비 대장',
    element: Element.wood, hp: 500, speed: 50, size: 96,
    color: Palette.wood1,
    dropChest: 'iron',
    patterns: [
      BossPatternData(pattern: BossPattern.rotate, cooldown: 4, damage: 15, description: '방망이 360도 회전'),
      BossPatternData(pattern: BossPattern.summon, cooldown: 8, damage: 0, description: '졸개 4마리 소환'),
      BossPatternData(pattern: BossPattern.enrage, cooldown: 0, damage: 0, description: 'HP30% 광폭화'),
    ],
  ),
  'gumiho': BossData(
    id: 'gumiho', name: '구미호',
    element: Element.fire, hp: 1500, speed: 60, size: 112,
    color: Palette.fire2,
    dropChest: 'gold',
    patterns: [
      BossPatternData(pattern: BossPattern.charm, cooldown: 6, damage: 0, description: '매혹 파동(슬로우)'),
      BossPatternData(pattern: BossPattern.radial8, cooldown: 5, damage: 12, description: '여우불 8방향'),
      BossPatternData(pattern: BossPattern.clone, cooldown: 15, damage: 0, description: '분신 2체 소환'),
    ],
  ),
  'jangsanbeom': BossData(
    id: 'jangsanbeom', name: '장산범',
    element: Element.metal, hp: 3000, speed: 45, size: 120,
    color: Palette.metal2,
    dropChest: 'jade',
    patterns: [
      BossPatternData(pattern: BossPattern.soundWave, cooldown: 4, damage: 20, description: '음파 직선 발사'),
      BossPatternData(pattern: BossPattern.buffAllies, cooldown: 10, damage: 0, description: '주변 적 강화'),
      BossPatternData(pattern: BossPattern.stealth, cooldown: 12, damage: 25, description: '투명화 3초→기습'),
    ],
  ),
  'bulgasari_boss': BossData(
    id: 'bulgasari_boss', name: '불가사리',
    element: Element.earth, hp: 5000, speed: 35, size: 128,
    color: Palette.earth1,
    dropChest: 'jade',
    patterns: [
      BossPatternData(pattern: BossPattern.charge, cooldown: 5, damage: 30, description: '화면 횡단 돌진'),
      BossPatternData(pattern: BossPattern.quake, cooldown: 8, damage: 0, description: '지진(전체 슬로우)'),
      BossPatternData(pattern: BossPattern.invincible, cooldown: 20, damage: 0, description: '5초 무적'),
    ],
  ),
  'yongwang': BossData(
    id: 'yongwang', name: '용왕',
    element: Element.water, hp: 8000, speed: 30, size: 140,
    color: Palette.water1,
    dropChest: 'dragon',
    patterns: [
      BossPatternData(pattern: BossPattern.waterPillar, cooldown: 4, damage: 25, description: '물기둥 3개 순차'),
      BossPatternData(pattern: BossPattern.whirlpool, cooldown: 8, damage: 10, description: '소용돌이(끌어당김)'),
      BossPatternData(pattern: BossPattern.tsunami, cooldown: 15, damage: 40, description: '해일(화면 50%)'),
    ],
  ),
};
