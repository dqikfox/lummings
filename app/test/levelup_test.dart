import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lummings_app/models/heartlight_state.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('leveledUp true when XP crosses threshold', () async {
    // Start near end of level 1 curve
    final need = BondProgress.xpForLevel(1);
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'active_lumming': 'lumo',
      'bond_level_lumo': 1,
      'bond_xp_lumo': need - 5, // 5 XP from level-up
      'streak_lumo': 1,
      'shards_lumo': 0,
    });
    final hl = HeartlightController();
    await hl.load();
    // hug grants 20 XP → crosses threshold
    final r = await hl.performCare(kind: 'hug');
    expect(r.alreadyDone, isFalse);
    expect(r.leveledUp, isTrue);
    expect(hl.active.bond.level, greaterThanOrEqualTo(2));
    expect(hl.active.phase, HeartlightPhase.radiant);
  });

  test('leveledUp false for normal care under threshold', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.pip);
    final r = await hl.performCare(kind: 'hug');
    expect(r.leveledUp, isFalse);
    expect(hl.active.bond.level, 1);
  });
}
