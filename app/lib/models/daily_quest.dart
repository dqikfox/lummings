/// Gentle daily quests — soft hooks, never punishment.
/// Incomplete quests simply wait until tomorrow (no streak burn).
enum QuestKind { care, talk, adventure, collect }

class DailyQuest {
  final QuestKind kind;
  final String id;
  final String title;
  final String blurb;
  final String emoji;
  final int shardReward;
  final int bondXpReward;

  const DailyQuest({
    required this.kind,
    required this.id,
    required this.title,
    required this.blurb,
    required this.emoji,
    this.shardReward = 1,
    this.bondXpReward = 5,
  });

  static const roster = <DailyQuest>[
    DailyQuest(
      kind: QuestKind.care,
      id: 'care_today',
      title: 'Heartlight Care',
      blurb: 'Hug, talk, or story once today — keep the glow kind.',
      emoji: '💗',
      shardReward: 0, // care action already grants XP + shard
      bondXpReward: 0,
    ),
    DailyQuest(
      kind: QuestKind.talk,
      id: 'talk_today',
      title: 'Share a Spark',
      blurb: 'Use a Talk chip — story, hug, adventure, or a feeling.',
      emoji: '💬',
      shardReward: 0, // talk action already grants XP/shards
      bondXpReward: 0,
    ),
    DailyQuest(
      kind: QuestKind.adventure,
      id: 'adventure_today',
      title: 'One Path',
      blurb: 'Finish any Growing Together adventure ending.',
      emoji: '🗺️',
      shardReward: 2,
      bondXpReward: 5,
    ),
    DailyQuest(
      kind: QuestKind.collect,
      id: 'collect_today',
      title: 'Charm Sparkle',
      blurb: 'Unlock one Charm (or open Collection if set is full).',
      emoji: '✨',
      shardReward: 1,
      bondXpReward: 3,
    ),
  ];
}

class DailyQuestProgress {
  final String dayKey; // yyyy-mm-dd
  final Set<String> completedIds;
  final bool bonusClaimed;

  const DailyQuestProgress({
    required this.dayKey,
    required this.completedIds,
    this.bonusClaimed = false,
  });

  int get doneCount => completedIds.length;
  int get total => DailyQuest.roster.length;
  double get fraction => total == 0 ? 0 : doneCount / total;
  bool get allDone => doneCount >= total;

  DailyQuestProgress copyWith({
    Set<String>? completedIds,
    bool? bonusClaimed,
  }) =>
      DailyQuestProgress(
        dayKey: dayKey,
        completedIds: completedIds ?? this.completedIds,
        bonusClaimed: bonusClaimed ?? this.bonusClaimed,
      );

  static String todayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static DailyQuestProgress emptyToday() => DailyQuestProgress(
        dayKey: todayKey(),
        completedIds: {},
      );
}
