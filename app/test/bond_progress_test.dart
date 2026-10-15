import 'package:flutter_test/flutter_test.dart';
import 'package:lummings_app/models/heartlight_state.dart';

void main() {
  test('bond XP curve grows gently', () {
    expect(BondProgress.xpForLevel(1), greaterThan(0));
    expect(BondProgress.xpForLevel(5), greaterThan(BondProgress.xpForLevel(2)));
  });
}
