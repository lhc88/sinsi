class GameModeData {
  final String id;
  final String name;
  final String description;
  final double speedMultiplier;
  final double enemySpeedMultiplier;
  final double projSpeedMultiplier;
  final double goldMultiplier;
  final double counterMultiplier; // 상극 배율
  final bool hasReaper; // 저승사자 등장 여부
  final bool reverseTimer; // 시간 역행
  final String unlockCondition;

  const GameModeData({
    required this.id,
    required this.name,
    required this.description,
    this.speedMultiplier = 1.0,
    this.enemySpeedMultiplier = 1.0,
    this.projSpeedMultiplier = 1.0,
    this.goldMultiplier = 1.0,
    this.counterMultiplier = 1.5,
    this.hasReaper = true,
    this.reverseTimer = false,
    required this.unlockCondition,
  });
}

const Map<String, GameModeData> gameModeTable = {
  'normal': GameModeData(
    id: 'normal', name: '일반', description: '기본 모드',
    unlockCondition: '기본',
  ),
  'gwangran': GameModeData(
    id: 'gwangran', name: '백귀광란', description: '적/플레이어 이속 +65%, 투사체 +25%, 엽전 +50%',
    speedMultiplier: 1.65, enemySpeedMultiplier: 1.65, projSpeedMultiplier: 1.25, goldMultiplier: 1.5,
    unlockCondition: '스테이지 클리어',
  ),
  'muhan': GameModeData(
    id: 'muhan', name: '끝없는 밤', description: '시간 무제한, 저승사자 미등장, 난이도 무한 상승',
    hasReaper: false,
    unlockCondition: '광란 클리어',
  ),
  'gwimun': GameModeData(
    id: 'gwimun', name: '역귀문', description: '적 원소 강화, 상극 DMG x2.0',
    counterMultiplier: 2.0,
    unlockCondition: '무한 20분 생존',
  ),
  'yeokhaeng': GameModeData(
    id: 'yeokhaeng', name: '시간역행', description: '30분→0분 카운트다운, 시간 줄수록 약해짐',
    reverseTimer: true,
    unlockCondition: '전 스테이지 귀문 클리어',
  ),
};
