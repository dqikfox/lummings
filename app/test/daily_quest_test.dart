import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lummings_app/models/daily_quest.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('roster has four soft quests', () {
    expect(DailyQuest.roster.length, 4);
    expect(
      DailyQuest.roster.map((q) => q.kind).toSet(),
      containsAll([
        QuestKind.care,
        QuestKind.talk,
        QuestKind.adventure,
        QuestKind.collect,
      ]),
    );
  });

  test('completeQuest is idempotent and never punishes', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.lumo);

    final first = await hl.completeQuest(QuestKind.talk);
    expect(first, isNotNull);
    expect(hl.quests.completedIds, contains('talk_today'));

    final second = await hl.completeQuest(QuestKind.talk);
    expect(second, isNull); // already done
    expect(hl.quests.doneCount, 1);
  });

  test('all four quests claim festival bonus once', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.lila);
    await hl.rewardAdventure(bondXp: 5, shards: 20); // shards for collect later

    await hl.completeQuest(QuestKind.care);
    await hl.completeQuest(QuestKind.talk);
    await hl.completeQuest(QuestKind.adventure);
    final last = await hl.completeQuest(QuestKind.collect);
    expect(hl.quests.allDone, isTrue);
    expect(hl.quests.bonusClaimed, isTrue);
    expect(last, contains('All daily sparks'));
  });

  test('care path auto-completes care quest', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.pip);
    await hl.performCare(kind: 'hug');
    expect(hl.quests.completedIds, contains('care_today'));
  });

  test('parent screen time + filters persist', () async {
    final hl = HeartlightController();
    await hl.load();
    await hl.setScreenTimeLimit(60);
    await hl.setContentFilters(false);
    expect(hl.screenTimeLimitMinutes, 60);
    expect(hl.contentFiltersOn, isFalse);

    final hl2 = HeartlightController();
    await hl2.load();
    expect(hl2.screenTimeLimitMinutes, 60);
    expect(hl2.contentFiltersOn, isFalse);
  });
}
