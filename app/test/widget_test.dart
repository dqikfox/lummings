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

  test('crew has five Lummings with Heartlights', () {
    expect(Lumming.crew.length, 5);
    expect(Lumming.byId(LummingId.lumo).heartlight.name, 'Questlight');
  });

  test('HeartlightController loads and completes onboarding', () async {
    final hl = HeartlightController();
    await hl.load();
    expect(hl.onboarded, isFalse);
    await hl.completeOnboarding(LummingId.lila, pin: '1234');
    expect(hl.onboarded, isTrue);
    expect(hl.activeId, LummingId.lila);
    expect(hl.verifyParentPin('1234'), isTrue);
    expect(hl.verifyParentPin('0000'), isFalse);
  });

  test('performCare awards XP once per day', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.lumo);
    final r1 = await hl.performCare(kind: 'hug');
    expect(r1.alreadyDone, isFalse);
    expect(r1.xpGained, 20);
    expect(hl.active.phase, anyOf(HeartlightPhase.glowing, HeartlightPhase.radiant));
    final r2 = await hl.performCare(kind: 'talk');
    expect(r2.alreadyDone, isTrue);
  });
}
