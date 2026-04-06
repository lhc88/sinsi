import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/cosmetics.dart';

void main() {
  group('코스메틱 데이터', () {
    test('모든 스킨이 유효한 캐릭터 ID 참조', () {
      const validCharacters = [
        'lee_taeyang', 'wolhui', 'cheolwoong', 'soyeon',
        'beopwoon', 'danbi', 'gwison', 'cheonmoo',
      ];
      for (final skin in skinTable.values) {
        expect(validCharacters.contains(skin.characterId), true,
            reason: '${skin.id}의 characterId ${skin.characterId} 유효하지 않음');
      }
    });

    test('기본 스킨 존재', () {
      final defaults = skinTable.values
          .where((s) => s.unlockType == SkinUnlockType.defaultSkin)
          .toList();
      expect(defaults.length, greaterThanOrEqualTo(3),
          reason: '기본 스킨 3개 이상 필요');
    });

    test('getSkinsForCharacter 필터링', () {
      final skins = getSkinsForCharacter('lee_taeyang');
      expect(skins.isNotEmpty, true);
      for (final skin in skins) {
        expect(skin.characterId, 'lee_taeyang');
      }
    });

    test('해금 조건 파라미터 유효', () {
      for (final skin in skinTable.values) {
        switch (skin.unlockType) {
          case SkinUnlockType.killCount:
          case SkinUnlockType.prestige:
            expect(int.tryParse(skin.unlockParam ?? ''), isNotNull,
                reason: '${skin.id} unlockParam이 정수가 아님');
          case SkinUnlockType.stageComplete:
          case SkinUnlockType.achievement:
            expect(skin.unlockParam, isNotNull,
                reason: '${skin.id} unlockParam이 null');
          case SkinUnlockType.defaultSkin:
            break;
        }
      }
    });
  });
}
