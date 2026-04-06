import 'dart:ui';

/// 코스메틱 스킨 데이터
class SkinData {
  final String id;
  final String name;
  final String characterId;
  final String description;
  final Color tint; // 색상 변형
  final String unlockCondition; // 해금 조건 설명
  final SkinUnlockType unlockType;
  final String? unlockParam; // 업적 ID 등

  const SkinData({
    required this.id,
    required this.name,
    required this.characterId,
    required this.description,
    required this.tint,
    required this.unlockCondition,
    this.unlockType = SkinUnlockType.achievement,
    this.unlockParam,
  });
}

enum SkinUnlockType {
  defaultSkin,   // 기본
  achievement,   // 업적 해금
  killCount,     // 총 처치 수
  stageComplete, // 스테이지 클리어
  prestige,      // 환생
}

const Map<String, SkinData> skinTable = {
  // 이태양 스킨
  'lee_taeyang_default': SkinData(
    id: 'lee_taeyang_default', name: '기본', characterId: 'lee_taeyang',
    description: '기본 퇴마사 복장', tint: Color(0xFFFFFFFF),
    unlockCondition: '기본', unlockType: SkinUnlockType.defaultSkin,
  ),
  'lee_taeyang_crimson': SkinData(
    id: 'lee_taeyang_crimson', name: '적화', characterId: 'lee_taeyang',
    description: '처치 1000 달성', tint: Color(0xFFFF4444),
    unlockCondition: '총 처치 1000', unlockType: SkinUnlockType.killCount, unlockParam: '1000',
  ),
  'lee_taeyang_golden': SkinData(
    id: 'lee_taeyang_golden', name: '금빛 퇴마사', characterId: 'lee_taeyang',
    description: '5스테이지 클리어', tint: Color(0xFFFFD700),
    unlockCondition: '황천길 클리어', unlockType: SkinUnlockType.stageComplete, unlockParam: 'stage5',
  ),
  // 월희 스킨
  'wolhui_default': SkinData(
    id: 'wolhui_default', name: '기본', characterId: 'wolhui',
    description: '기본 무녀 복장', tint: Color(0xFFFFFFFF),
    unlockCondition: '기본', unlockType: SkinUnlockType.defaultSkin,
  ),
  'wolhui_ice': SkinData(
    id: 'wolhui_ice', name: '빙결', characterId: 'wolhui',
    description: '20분 생존 업적', tint: Color(0xFF88CCFF),
    unlockCondition: '20분 생존 업적', unlockType: SkinUnlockType.achievement, unlockParam: 'survivor_20',
  ),
  // 철웅 스킨
  'cheolwoong_default': SkinData(
    id: 'cheolwoong_default', name: '기본', characterId: 'cheolwoong',
    description: '기본 장수 갑옷', tint: Color(0xFFFFFFFF),
    unlockCondition: '기본', unlockType: SkinUnlockType.defaultSkin,
  ),
  'cheolwoong_dark': SkinData(
    id: 'cheolwoong_dark', name: '암흑 장수', characterId: 'cheolwoong',
    description: '환생 1회', tint: Color(0xFF442266),
    unlockCondition: '환생 1회', unlockType: SkinUnlockType.prestige, unlockParam: '1',
  ),
};

/// 캐릭터별 스킨 목록 조회
List<SkinData> getSkinsForCharacter(String characterId) {
  return skinTable.values
      .where((s) => s.characterId == characterId)
      .toList();
}
