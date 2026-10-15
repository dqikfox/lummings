import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/adventure.dart';
import 'heartlight_controller.dart';

class AdventureController extends ChangeNotifier {
  AdventurePack? pack;
  AdventureProgress? progress;
  bool loading = false;
  String? error;

  AdventureNode? get node {
    if (pack == null || progress == null) return null;
    return pack!.nodes[progress!.currentNodeId];
  }

  Future<void> loadPack(String assetPath) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      pack = AdventurePack.fromJson(json);
      progress = AdventureProgress(
        packId: pack!.id,
        currentNodeId: pack!.startNodeId,
        path: [pack!.startNodeId],
        bondXpEarned: 0,
        shardsEarned: 0,
        memories: const [],
        completed: false,
      );
    } catch (e) {
      error = 'Could not open adventure: $e';
      pack = null;
      progress = null;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> choose(
    AdventureChoice choice,
    HeartlightController heartlight,
  ) async {
    if (pack == null || progress == null) return;
    final next = pack!.nodes[choice.nextNodeId];
    if (next == null) {
      error = 'Missing story node ${choice.nextNodeId}';
      notifyListeners();
      return;
    }

    final memories = [
      ...progress!.memories,
      if (choice.memoryNote != null) choice.memoryNote!,
    ];

    progress = progress!.copyWith(
      currentNodeId: next.id,
      path: [...progress!.path, next.id],
      bondXpEarned: progress!.bondXpEarned + choice.bondXp,
      shardsEarned: progress!.shardsEarned + choice.shards,
      memories: memories,
      completed: next.isEnding,
    );
    notifyListeners();

    if (next.isEnding) {
      await heartlight.rewardAdventure(
        bondXp: progress!.bondXpEarned + pack!.completionBondXp,
        shards: progress!.shardsEarned + pack!.completionShards,
        memories: progress!.memories,
      );
    }
  }

  void reset() {
    if (pack == null) return;
    progress = AdventureProgress(
      packId: pack!.id,
      currentNodeId: pack!.startNodeId,
      path: [pack!.startNodeId],
      bondXpEarned: 0,
      shardsEarned: 0,
      memories: const [],
      completed: false,
    );
    notifyListeners();
  }
}
