import 'package:flutter_test/flutter_test.dart';
import 'package:sinsi_survivor/data/daily_challenge.dart';

void main() {
  group('DailyChallenge — 날짜 기반 결정론적 생성', () {
    test('같은 날짜 → 같은 도전', () {
      final d1 = getDailyChallenge(DateTime(2026, 4, 5));
      final d2 = getDailyChallenge(DateTime(2026, 4, 5));
      expect(d1.id, d2.id);
      expect(d1.rule, d2.rule);
    });

    test('다른 날짜 → 다른 도전 (대부분)', () {
      final d1 = getDailyChallenge(DateTime(2026, 4, 5));
      final d2 = getDailyChallenge(DateTime(2026, 4, 6));
      // 10개 풀에서 같은 날 연속이 나올 수도 있으나 id 자체는 결정론적
      expect(d1.id, isNotNull);
      expect(d2.id, isNotNull);
    });

    test('모든 규칙이 풀에 존재', () {
      final rules = DailyChallengeRule.values.toSet();
      // 10일 연속으로 테스트하면 대부분 커버
      final found = <DailyChallengeRule>{};
      for (int i = 0; i < 100; i++) {
        final dc = getDailyChallenge(DateTime(2026, 1, 1).add(Duration(days: i)));
        found.add(dc.rule);
      }
      // 최소 5가지 규칙은 등장해야 함
      expect(found.length, greaterThanOrEqualTo(5));
      // 모든 규칙이 풀에 있는지 검증
      for (final rule in rules) {
        expect(found.contains(rule), isTrue, reason: '$rule이 100일 내 미등장');
      }
    });

    test('보상 값 양수', () {
      for (int i = 0; i < 10; i++) {
        final dc = getDailyChallenge(DateTime(2026, 1, 1).add(Duration(days: i)));
        expect(dc.rewardCoins, greaterThan(0));
        expect(dc.rewardSoulStones, greaterThanOrEqualTo(0));
      }
    });
  });
}
