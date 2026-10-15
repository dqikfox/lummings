import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lummings_app/models/adventure.dart';
import 'package:lummings_app/models/heartlight_state.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/adventure_controller.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

AdventurePack loadPackFromDisk() {
  final file = File('assets/adventures/growing_together_001.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return AdventurePack.fromJson(json);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Canon / crew', () {
    test('five Lummings with unique Heartlight essences', () {
      expect(Lumming.crew.length, 5);
      expect(
        Lumming.crew.map((l) => l.name).toSet(),
        containsAll(['Lumo', 'Lila', 'Pip', 'Nori', 'Moki']),
      );
      expect(
        Lumming.crew.map((l) => l.heartlight.name).toSet(),
        containsAll([
          'Questlight',
          'Dreamlight',
          'Traillight',
          'Tidelight',
          'Sparklight',
        ]),
      );
      expect(Lumming.crew.map((l) => l.heartlight.line).toSet().length, 5);
    });

    test('byId covers all ids', () {
      for (final id in LummingId.values) {
        expect(Lumming.byId(id).id, id);
      }
    });
  });

  group('Bond XP', () {
    test('curve increases with level', () {
      expect(BondProgress.xpForLevel(5), greaterThan(BondProgress.xpForLevel(1)));
      expect(BondProgress.xpForLevel(10), greaterThan(BondProgress.xpForLevel(5)));
    });

    test('fraction works', () {
      expect(const BondProgress(level: 1, xp: 25, xpToNext: 100).fraction, 0.25);
    });
  });

  group('Heartlight care + parent PIN', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load defaults', () async {
      final hl = HeartlightController();
      await hl.load();
      expect(hl.onboarded, isFalse);
      expect(hl.activeId, LummingId.lumo);
      expect(hl.active.bond.level, 1);
    });

    test('onboarding + PIN gate', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lila, pin: '4242');
      expect(hl.onboarded, isTrue);
      expect(hl.activeId, LummingId.lila);
      expect(hl.verifyParentPin('4242'), isTrue);
      expect(hl.verifyParentPin('1111'), isFalse);
    });

    test('care awards XP once per day', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);
      final first = await hl.performCare(kind: 'hug');
      expect(first.alreadyDone, isFalse);
      expect(first.xpGained, 20);
      expect(hl.active.caredToday, isTrue);
      expect(hl.active.phase, HeartlightPhase.glowing);
      expect(hl.active.careStreak, 1);
      expect(hl.active.essenceShards, 1);

      final second = await hl.performCare(kind: 'talk');
      expect(second.alreadyDone, isTrue);
    });

    test('story care grants +5 XP over hug', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.pip);
      final r = await hl.performCare(kind: 'story');
      expect(r.xpGained, 25);
    });

    test('setActive switches Lumming', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.setActive(LummingId.moki);
      expect(hl.activeLumming.heartlight.name, 'Sparklight');
    });

    test('adventure reward writes memories and radiant phase', () async {
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.nori);
      await hl.rewardAdventure(
        bondXp: 40,
        shards: 4,
        memories: ['Night Forest memory'],
      );
      expect(hl.active.essenceShards, greaterThanOrEqualTo(4));
      expect(hl.active.memoryHighlights, contains('Night Forest memory'));
      expect(hl.active.phase, HeartlightPhase.radiant);
    });
  });

  group('Soft miss hook', () {
    test('return after multi-day miss: streak=1, +15 bonus, no punishment', () async {
      SharedPreferences.setMockInitialValues({
        'onboarded': true,
        'active_lumming': 'lumo',
        'bond_level_lumo': 2,
        'bond_xp_lumo': 10,
        'streak_lumo': 5,
        'shards_lumo': 2,
        'last_care_lumo': DateTime.now()
            .subtract(const Duration(days: 3))
            .millisecondsSinceEpoch,
      });
      final hl = HeartlightController();
      await hl.load();
      expect(hl.active.phase, HeartlightPhase.dimmed);

      final r = await hl.performCare(kind: 'hug');
      expect(r.streak, 1);
      expect(r.xpGained, 35); // 20 + 15 return
      expect(r.message.toLowerCase(), contains('missed'));
      expect(hl.active.phase, HeartlightPhase.glowing);
      expect(
        hl.active.memoryHighlights.any((m) => m.contains('Came back')),
        isTrue,
      );
    });
  });

  group('Adventure: Night Forest Awakens', () {
    late AdventurePack pack;

    setUpAll(() {
      pack = loadPackFromDisk();
    });

    test('metadata', () {
      expect(pack.id, 'growing_together_001');
      expect(pack.title, contains('Night Forest'));
      expect(pack.crew.length, 5);
      expect(pack.nodes.containsKey(pack.startNodeId), isTrue);
      expect(pack.completionBondXp, greaterThan(0));
    });

    test('every choice target exists; endings have no choices', () {
      for (final node in pack.nodes.values) {
        for (final c in node.choices) {
          expect(
            pack.nodes.containsKey(c.nextNodeId),
            isTrue,
            reason: 'node ${node.id} choice ${c.id} -> missing ${c.nextNodeId}',
          );
        }
        if (node.isEnding) {
          expect(node.choices, isEmpty);
        }
      }
    });

    test('all five speakers appear', () {
      final speakers = pack.nodes.values
          .map((n) => n.speaker)
          .whereType<String>()
          .toSet();
      expect(speakers, containsAll(['lumo', 'lila', 'pip', 'nori', 'moki']));
    });

    test('has safety_check choice and essence teaching beat', () {
      final safety = pack.nodes.values
          .expand((n) => n.choices)
          .where((c) => c.safetyCheck)
          .toList();
      expect(safety, isNotEmpty);
      expect(pack.nodes.containsKey('essence'), isTrue);
      expect(
        pack.nodes['essence']!.body.toLowerCase(),
        anyOf(contains('essence'), contains('soul')),
      );
    });

    test('two endings exist', () {
      final endings = pack.nodes.values.where((n) => n.isEnding).toList();
      expect(endings.length, greaterThanOrEqualTo(2));
    });

    test('walk one full path to ending awards progress fields', () async {
      SharedPreferences.setMockInitialValues({});
      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);

      // Manual walk: wake -> look -> lantern -> essence -> ending_bonded
      var nodeId = pack.startNodeId;
      var xp = 0;
      var shards = 0;
      final memories = <String>[];
      final visited = <String>[];

      while (true) {
        final node = pack.nodes[nodeId]!;
        visited.add(nodeId);
        if (node.isEnding) break;
        final choice = node.choices.first;
        xp += choice.bondXp;
        shards += choice.shards;
        if (choice.memoryNote != null) memories.add(choice.memoryNote!);
        nodeId = choice.nextNodeId;
      }

      expect(visited, contains(pack.startNodeId));
      expect(pack.nodes[nodeId]!.isEnding, isTrue);
      expect(xp, greaterThan(0));

      await hl.rewardAdventure(
        bondXp: xp + pack.completionBondXp,
        shards: shards + pack.completionShards,
        memories: memories,
      );
      expect(hl.active.memoryHighlights, isNotEmpty);
      expect(hl.active.essenceShards, greaterThan(0));
    });

    test('AdventureController loads pack via rootBundle', () async {
      // Register asset for test
      final data = File('assets/adventures/growing_together_001.json')
          .readAsStringSync();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final key = const StringCodec().decodeMessage(message);
        if (key == 'assets/adventures/growing_together_001.json') {
          return const StringCodec().encodeMessage(data);
        }
        return null;
      });

      final adv = AdventureController();
      await adv.loadPack('assets/adventures/growing_together_001.json');
      expect(adv.error, isNull);
      expect(adv.pack, isNotNull);
      expect(adv.node, isNotNull);
      expect(adv.progress!.completed, isFalse);

      final hl = HeartlightController();
      await hl.load();
      await hl.completeOnboarding(LummingId.lumo);

      // Exhaust first path until ending
      var guard = 0;
      while (adv.node != null && !adv.node!.isEnding && guard < 20) {
        final choice = adv.node!.choices.first;
        await adv.choose(choice, hl);
        guard++;
      }
      expect(adv.progress!.completed, isTrue);
      expect(hl.active.phase, HeartlightPhase.radiant);
    });
  });
}
