import 'dart:ui';
import '../utils/constants.dart';

enum EnemyType {
  jabgwi,       // 잡귀
  dokkaebiJol,  // 도깨비졸
  cheonyeoGwisin, // 처녀귀신
  haetaeSeoksang, // 해태 석상
  bulyeou,      // 불여우
  gapotGwisin,  // 갑옷 귀신
  yacha,        // 야차
  gureongi,     // 구렁이
  nalssaenDoli, // 날쌘돌이
  gangsi,       // 강시
}

enum Element { wood, fire, earth, metal, water, none }

class EnemyData {
  final EnemyType type;
  final String name;
  final Element element;
  final double baseHp;
  final double baseDamage;
  final double baseSpeed;
  final double expDrop;
  final Color color;
  final double size;

  const EnemyData({
    required this.type,
    required this.name,
    required this.element,
    required this.baseHp,
    required this.baseDamage,
    required this.baseSpeed,
    this.expDrop = 1,
    required this.color,
    this.size = 36,
  });
}

const Map<EnemyType, EnemyData> enemyTable = {
  EnemyType.jabgwi: EnemyData(
    type: EnemyType.jabgwi,
    name: '잡귀',
    element: Element.none,
    baseHp: 5,
    baseDamage: 2,
    baseSpeed: 60,
    expDrop: 1,
    color: Palette.metal3,
    size: 32,
  ),
  EnemyType.dokkaebiJol: EnemyData(
    type: EnemyType.dokkaebiJol,
    name: '도깨비졸',
    element: Element.wood,
    baseHp: 12,
    baseDamage: 3,
    baseSpeed: 80,
    expDrop: 2,
    color: Palette.wood1,
    size: 36,
  ),
  EnemyType.cheonyeoGwisin: EnemyData(
    type: EnemyType.cheonyeoGwisin,
    name: '처녀귀신',
    element: Element.water,
    baseHp: 18,
    baseDamage: 5,
    baseSpeed: 40,
    expDrop: 3,
    color: Palette.water4,
    size: 34,
  ),
  EnemyType.haetaeSeoksang: EnemyData(
    type: EnemyType.haetaeSeoksang,
    name: '해태 석상',
    element: Element.earth,
    baseHp: 35,
    baseDamage: 4,
    baseSpeed: 30,
    expDrop: 5,
    color: Palette.earth1,
    size: 44,
  ),
  EnemyType.bulyeou: EnemyData(
    type: EnemyType.bulyeou,
    name: '불여우',
    element: Element.fire,
    baseHp: 20,
    baseDamage: 6,
    baseSpeed: 100,
    expDrop: 3,
    color: Palette.fire2,
    size: 34,
  ),
  EnemyType.gapotGwisin: EnemyData(
    type: EnemyType.gapotGwisin,
    name: '갑옷 귀신',
    element: Element.metal,
    baseHp: 50,
    baseDamage: 7,
    baseSpeed: 25,
    expDrop: 8,
    color: Palette.metal2,
    size: 48,
  ),
  EnemyType.yacha: EnemyData(
    type: EnemyType.yacha,
    name: '야차',
    element: Element.fire,
    baseHp: 30,
    baseDamage: 10,
    baseSpeed: 90,
    expDrop: 5,
    color: Palette.fire1,
    size: 40,
  ),
  EnemyType.gureongi: EnemyData(
    type: EnemyType.gureongi,
    name: '구렁이',
    element: Element.water,
    baseHp: 28,
    baseDamage: 4,
    baseSpeed: 50,
    expDrop: 4,
    color: Palette.water1,
    size: 38,
  ),
  EnemyType.nalssaenDoli: EnemyData(
    type: EnemyType.nalssaenDoli,
    name: '날쌘돌이',
    element: Element.wood,
    baseHp: 8,
    baseDamage: 3,
    baseSpeed: 130,
    expDrop: 1,
    color: Palette.wood2,
    size: 28,
  ),
  EnemyType.gangsi: EnemyData(
    type: EnemyType.gangsi,
    name: '강시',
    element: Element.earth,
    baseHp: 60,
    baseDamage: 10,
    baseSpeed: 35,
    expDrop: 10,
    color: Palette.earth3,
    size: 44,
  ),
};
