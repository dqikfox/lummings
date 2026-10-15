class AdventureChoice {
  final String id;
  final String label;
  final String nextNodeId;
  final int bondXp;
  final int shards;
  final String? memoryNote;
  final String? heartlightLine; // spoken by a Lumming
  final bool safetyCheck; // if true, choice models "ask a trusted adult"

  const AdventureChoice({
    required this.id,
    required this.label,
    required this.nextNodeId,
    this.bondXp = 5,
    this.shards = 0,
    this.memoryNote,
    this.heartlightLine,
    this.safetyCheck = false,
  });

  factory AdventureChoice.fromJson(Map<String, dynamic> j) => AdventureChoice(
        id: j['id'] as String,
        label: j['label'] as String,
        nextNodeId: j['next'] as String,
        bondXp: (j['bond_xp'] as num?)?.toInt() ?? 5,
        shards: (j['shards'] as num?)?.toInt() ?? 0,
        memoryNote: j['memory'] as String?,
        heartlightLine: j['line'] as String?,
        safetyCheck: j['safety_check'] as bool? ?? false,
      );
}

class AdventureNode {
  final String id;
  final String title;
  final String body;
  final String? speaker; // lumo | lila | pip | nori | moki | narrator
  final String? mood;
  final List<AdventureChoice> choices;
  final bool isEnding;
  final String? endingKind; // warm | curious | bonded

  const AdventureNode({
    required this.id,
    required this.title,
    required this.body,
    this.speaker,
    this.mood,
    required this.choices,
    this.isEnding = false,
    this.endingKind,
  });

  factory AdventureNode.fromJson(Map<String, dynamic> j) => AdventureNode(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        body: j['body'] as String,
        speaker: j['speaker'] as String?,
        mood: j['mood'] as String?,
        choices: (j['choices'] as List? ?? [])
            .map((c) => AdventureChoice.fromJson(c as Map<String, dynamic>))
            .toList(),
        isEnding: j['ending'] as bool? ?? false,
        endingKind: j['ending_kind'] as String?,
      );
}

class AdventurePack {
  final String id;
  final String title;
  final String subtitle;
  final String synopsis;
  final int estimatedMinutes;
  final List<String> crew; // lumming ids featured
  final String startNodeId;
  final Map<String, AdventureNode> nodes;
  final int completionBondXp;
  final int completionShards;

  const AdventurePack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.synopsis,
    required this.estimatedMinutes,
    required this.crew,
    required this.startNodeId,
    required this.nodes,
    this.completionBondXp = 40,
    this.completionShards = 3,
  });

  factory AdventurePack.fromJson(Map<String, dynamic> j) {
    final nodeList = (j['nodes'] as List)
        .map((n) => AdventureNode.fromJson(n as Map<String, dynamic>))
        .toList();
    return AdventurePack(
      id: j['id'] as String,
      title: j['title'] as String,
      subtitle: j['subtitle'] as String? ?? '',
      synopsis: j['synopsis'] as String? ?? '',
      estimatedMinutes: (j['estimated_minutes'] as num?)?.toInt() ?? 5,
      crew: (j['crew'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      startNodeId: j['start'] as String,
      nodes: {for (final n in nodeList) n.id: n},
      completionBondXp: (j['completion_bond_xp'] as num?)?.toInt() ?? 40,
      completionShards: (j['completion_shards'] as num?)?.toInt() ?? 3,
    );
  }
}

class AdventureProgress {
  final String packId;
  final String currentNodeId;
  final List<String> path;
  final int bondXpEarned;
  final int shardsEarned;
  final List<String> memories;
  final bool completed;

  const AdventureProgress({
    required this.packId,
    required this.currentNodeId,
    required this.path,
    required this.bondXpEarned,
    required this.shardsEarned,
    required this.memories,
    required this.completed,
  });

  AdventureProgress copyWith({
    String? currentNodeId,
    List<String>? path,
    int? bondXpEarned,
    int? shardsEarned,
    List<String>? memories,
    bool? completed,
  }) =>
      AdventureProgress(
        packId: packId,
        currentNodeId: currentNodeId ?? this.currentNodeId,
        path: path ?? this.path,
        bondXpEarned: bondXpEarned ?? this.bondXpEarned,
        shardsEarned: shardsEarned ?? this.shardsEarned,
        memories: memories ?? this.memories,
        completed: completed ?? this.completed,
      );
}
