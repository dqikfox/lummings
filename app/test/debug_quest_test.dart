import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lummings_app/models/daily_quest.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/state/heartlight_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('debug quest def values + completeQuest alone', () async {
    for (final q in DailyQuest.roster) {
      print('quest ${q.id} kind=${q.kind} xp=${q.bondXpReward} shards=${q.shardReward}');
    }
    SharedPreferences.setMockInitialValues({});
    final hl = HeartlightController();
    await hl.load();
    await hl.completeOnboarding(LummingId.moki);
    // Manually grant base state then completeQuest only
    await hl.rewardAdventure(bondXp: 0, shards: 5);
    print('after adventure shards=${hl.active.essenceShards} quests=${hl.quests.completedIds}');
    // Note rewardAdventure also completes adventure quest
    final note = await hl.completeQuest(QuestKind.talk);
    print('talk note=$note shards=${hl.active.essenceShards} xp=${hl.active.bond.xp} quests=${hl.quests.completedIds}');
    final note2 = await hl.completeQuest(QuestKind.care);
    print('care note=$note2 shards=${hl.active.essenceShards} xp=${hl.active.bond.xp}');
  });
}
