import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lummings_app/models/festival.dart';
import 'package:lummings_app/models/heartlight_plus.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NestFestival weekKey stable format', () {
    final k = NestFestival.weekKey(DateTime(2026, 10, 16));
    expect(k.contains('W'), isTrue);
    expect(k.startsWith('2026'), isTrue);
  });

  test('Festival claim requires engage; never punishes', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.nori, pin: '1234');

    final blocked = await hl.claimFestivalBonus();
    expect(blocked.contains('Care') || blocked.contains('first'), isTrue);
    expect(hl.festival.claimed, isFalse);

    await hl.markFestivalEngaged();
    final ok = await hl.claimFestivalBonus();
    expect(ok.contains('bond') || ok.contains('shards') || ok.contains('!'), isTrue);
    expect(hl.festival.claimed, isTrue);

    final again = await hl.claimFestivalBonus();
    expect(again.toLowerCase().contains('already') || again.contains('week'), isTrue);
  });

  test('Plus tier mock persists and boosts festival shards path', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.lumo);
    expect(hl.isPlus, isFalse);
    await hl.setPlusTier(HeartlightPlusTier.plus.id);
    expect(hl.isPlus, isTrue);
    expect(hl.plusTierId, HeartlightPlusTier.plus.id);

    await hl.markFestivalEngaged();
    final msg = await hl.claimFestivalBonus();
    expect(msg.contains('Plus') || msg.contains('shards'), isTrue);
  });

  test('Crew assets paths exist for all five', () {
    for (final l in Lumming.crew) {
      expect(l.crewAsset.contains(l.id.name), isTrue);
      expect(l.portraitHappy.contains(l.id.name), isTrue);
    }
  });

  test('Care engages festival soft hook', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.sprout);
    expect(hl.festival.engaged, isFalse);
    await hl.performCare(kind: 'hug');
    expect(hl.festival.engaged, isTrue);
  });
}
