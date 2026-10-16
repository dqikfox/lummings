import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lummings_app/models/charm.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Charm equip', () {
    test('cannot equip unowned charm', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);
      final msg = await hl.equipCharm('questlight_charm');
      expect(msg.toLowerCase(), contains('unlock'));
      expect(hl.active.equippedCharmId, isNull);
    });

    test('purchase auto-path: equip after own', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);
      await hl.rewardAdventure(bondXp: 5, shards: 10);
      final buy = await hl.purchaseCharm('questlight_charm');
      expect(buy.ok, isTrue);
      final msg = await hl.equipCharm('questlight_charm');
      expect(msg.toLowerCase(), contains('equipped'));
      expect(hl.active.equippedCharmId, 'questlight_charm');

      final clear = await hl.equipCharm(null);
      expect(clear.toLowerCase(), contains('tucked'));
      expect(hl.active.equippedCharmId, isNull);
    });

    test('equip persists across load', () async {
      SharedPreferences.setMockInitialValues({});
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lila);
      await hl.rewardAdventure(bondXp: 5, shards: 10);
      await hl.purchaseCharm('dreamlight_charm');
      await hl.equipCharm('dreamlight_charm');
      expect(hl.active.equippedCharmId, 'dreamlight_charm');

      final hl2 = HeartlightController();
      await hl2.load();
      expect(hl2.activeId, LummingId.lila);
      expect(hl2.active.equippedCharmId, 'dreamlight_charm');
    });
  });

  group('Catalog quality', () {
    test('10 charms including nest pillow and crown', () {
      expect(Charm.catalog.length, greaterThanOrEqualTo(10));
      expect(Charm.byId('nest_pillow'), isNotNull);
      expect(Charm.byId('heartlight_crown')!.rarity, 'legendary');
    });
  });

  group('Soft bedtime pref', () {
    test('defaults on and toggles', () async {
      final hl = HeartlightController();
      await hl.load();
      expect(hl.softBedtimeReminder, isTrue);
      await hl.setSoftBedtimeReminder(false);
      expect(hl.softBedtimeReminder, isFalse);

      final hl2 = HeartlightController();
      await hl2.load();
      expect(hl2.softBedtimeReminder, isFalse);
    });
  });

  group('Memories journal feed', () {
    test('care / talk / adventure / charm write memories', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.moki);
      await hl.rewardTalk(
        bondXp: 8,
        shards: 1,
        memory: 'Talked with Moki: hug',
      );
      await hl.rewardAdventure(
        bondXp: 20,
        shards: 3,
        memories: ['Spark Mix-Up complete'],
      );
      await hl.rewardAdventure(bondXp: 5, shards: 10);
      await hl.purchaseCharm('sparklight_charm');

      expect(hl.active.memoryHighlights, isNotEmpty);
      expect(
        hl.active.memoryHighlights.any((m) => m.contains('Talked with Moki')),
        isTrue,
      );
      expect(
        hl.active.memoryHighlights.any((m) => m.contains('Sparklight')),
        isTrue,
      );
    });
  });
}
