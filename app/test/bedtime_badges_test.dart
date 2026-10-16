import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lummings_app/models/nest_badge.dart';
import 'package:lummings_app/state/heartlight_controller.dart';
import 'package:lummings_app/models/adventure.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NestBadge catalog has unique ids', () {
    final ids = NestBadge.catalog.map((b) => b.id).toSet();
    expect(ids.length, NestBadge.catalog.length);
    expect(NestBadge.catalog.length, greaterThanOrEqualTo(8));
  });

  test('Bedtime once per day grants XP and unlocks Moon Tucker', () async {
    final hl = HeartlightController();
    await hl.load();
    expect(hl.bedtimeDoneToday, isFalse);

    final r1 = await hl.performBedtime(note: 'test tuck');
    expect(r1.alreadyDone, isFalse);
    expect(r1.xpGained, 12);
    expect(hl.bedtimeDoneToday, isTrue);
    expect(hl.ownedBadges.contains('moon_tucker'), isTrue);

    final r2 = await hl.performBedtime();
    expect(r2.alreadyDone, isTrue);
  });

  test('First care unlocks First Glow badge', () async {
    final hl = HeartlightController();
    await hl.load();
    final r = await hl.performCare(kind: 'hug');
    expect(r.alreadyDone, isFalse);
    await hl.refreshBadges();
    expect(hl.ownedBadges.contains('first_glow'), isTrue);
  });

  test('Star Garden adventure graph is valid', () {
    final file = File('assets/adventures/star_garden_001.json');
    expect(file.existsSync(), isTrue);
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final pack = AdventurePack.fromJson(json);
    expect(pack.id, 'star_garden_001');
    expect(pack.nodes.containsKey(pack.startNodeId), isTrue);
    // all choice targets exist
    for (final n in pack.nodes.values) {
      for (final c in n.choices) {
        expect(pack.nodes.containsKey(c.nextNodeId), isTrue,
            reason: '${n.id} -> ${c.nextNodeId}');
      }
    }
    final endings = pack.nodes.values.where((n) => n.choices.isEmpty).toList();
    expect(endings.length, greaterThanOrEqualTo(2));
  });
}
