/// Weekly soft Festival — gentle FOMO, never punishment.
class NestFestival {
  final String id;
  final String title;
  final String blurb;
  final String emoji;
  final int bonusShards;
  final int bonusXp;

  const NestFestival({
    required this.id,
    required this.title,
    required this.blurb,
    required this.emoji,
    this.bonusShards = 3,
    this.bonusXp = 15,
  });

  static String weekKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final dayOfYear = d.difference(DateTime(d.year, 1, 1)).inDays + 1;
    final week = ((dayOfYear - d.weekday + 10) / 7).floor();
    final y = week < 1 ? d.year - 1 : d.year;
    final w = week < 1 ? 52 : (week > 52 ? 1 : week);
    return '$y-W${w.toString().padLeft(2, '0')}';
  }

  static NestFestival forWeek([DateTime? now]) {
    final key = weekKey(now);
    const themes = [
      NestFestival(
        id: 'glow_gathering',
        title: 'Glow Gathering',
        blurb: 'All five Heartlights shimmer together this weekend.',
        emoji: '🌟',
      ),
      NestFestival(
        id: 'leafy_lanterns',
        title: 'Leafy Lanterns',
        blurb: 'Pip’s trails light the forest path — walk one adventure.',
        emoji: '🏮',
      ),
      NestFestival(
        id: 'quiet_tide',
        title: 'Quiet Tide',
        blurb: 'Nori notices the little things. Share a Talk feeling.',
        emoji: '🌙',
      ),
      NestFestival(
        id: 'spark_parade',
        title: 'Spark Parade',
        blurb: 'Moki’s kind chaos — unlock a charm or Care once.',
        emoji: '🎉',
      ),
    ];
    final idx = key.hashCode.abs() % themes.length;
    final t = themes[idx];
    return NestFestival(
      id: '${t.id}_$key',
      title: t.title,
      blurb: t.blurb,
      emoji: t.emoji,
      bonusShards: t.bonusShards,
      bonusXp: t.bonusXp,
    );
  }
}

class FestivalProgress {
  final String weekKey;
  final bool claimed;
  final bool engaged;

  const FestivalProgress({
    required this.weekKey,
    this.claimed = false,
    this.engaged = false,
  });

  FestivalProgress copyWith({bool? claimed, bool? engaged}) => FestivalProgress(
        weekKey: weekKey,
        claimed: claimed ?? this.claimed,
        engaged: engaged ?? this.engaged,
      );

  static FestivalProgress emptyThisWeek() => FestivalProgress(
        weekKey: NestFestival.weekKey(),
      );
}
