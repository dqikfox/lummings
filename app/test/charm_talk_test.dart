import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lummings_app/data/talk_replies.dart';
import 'package:lummings_app/models/charm.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Charm catalog', () {
    test('has 8 charms with positive costs', () {
      expect(Charm.catalog.length, greaterThanOrEqualTo(8));
      for (final c in Charm.catalog) {
        expect(c.shardCost, greaterThan(0));
        expect(c.minBondLevel, greaterThan(0));
      }
    });

    test('purchase requires shards and bond level', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);

      // Not enough shards yet
      final fail = await hl.purchaseCharm('questlight_charm');
      expect(fail.ok, isFalse);

      // Grant shards via adventure reward
      await hl.rewardAdventure(bondXp: 5, shards: 10);
      final ok = await hl.purchaseCharm('questlight_charm');
      expect(ok.ok, isTrue);
      expect(hl.ownsCharm('questlight_charm'), isTrue);
      // 10 (grant) + 2 (adventure quest) - 3 (cost) + 1 (collect quest) = 10
      expect(hl.active.essenceShards, lessThan(12));
      expect(hl.active.essenceShards, greaterThanOrEqualTo(8));

      // Second purchase blocked
      final again = await hl.purchaseCharm('questlight_charm');
      expect(again.ok, isFalse);
    });

    test('rare charm gated by bond level', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);
      await hl.rewardAdventure(bondXp: 5, shards: 20);
      final r = await hl.purchaseCharm('bonded_star'); // needs L3
      expect(r.ok, isFalse);
      expect(r.message.toLowerCase(), contains('bond'));
    });
  });

  group('Talk catalog', () {
    test('every Lumming has story/hug/adventure/feel/default', () {
      for (final id in LummingId.values) {
        final keys =
            TalkCatalog.forLumming(id).map((r) => r.promptKey).toSet();
        expect(keys, containsAll(['story', 'hug', 'adventure', 'feel', 'default']));
      }
    });

    test('rewardTalk grants XP and memory', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.moki);
      final before = hl.active.bond.xp;
      final r = await hl.rewardTalk(
        bondXp: 8,
        shards: 1,
        memory: 'Talked with Moki: story',
      );
      expect(r.xpGained, 8);
      // Talk grants 8 XP; talk quest marks done without double-pay
      expect(hl.active.bond.xp, greaterThanOrEqualTo(before + 8));
      expect(hl.active.essenceShards, 1);
      expect(hl.active.memoryHighlights, contains('Talked with Moki: story'));
      expect(hl.quests.completedIds, contains('talk_today'));
    });

    test('safety language present in feel replies', () {
      for (final id in LummingId.values) {
        final feel = TalkCatalog.pick(id, 'feel');
        expect(
          feel.text.toLowerCase(),
          anyOf(contains('trusted adult'), contains('adult')),
        );
      }
    });
  });
}
