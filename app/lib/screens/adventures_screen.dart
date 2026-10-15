import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/adventure_controller.dart';
import '../state/heartlight_controller.dart';
import '../models/lumming.dart';

class AdventuresScreen extends StatefulWidget {
  const AdventuresScreen({super.key});

  @override
  State<AdventuresScreen> createState() => _AdventuresScreenState();
}

class _AdventuresScreenState extends State<AdventuresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdventureController>()
          .loadPack('assets/adventures/growing_together_001.json');
    });
  }

  @override
  Widget build(BuildContext context) {
    final adv = context.watch<AdventureController>();
    final hl = context.watch<HeartlightController>();

    if (adv.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adv.error != null) {
      return Center(child: Text(adv.error!));
    }
    if (adv.pack == null || adv.node == null) {
      return const Center(child: Text('No adventure loaded'));
    }

    final pack = adv.pack!;
    final node = adv.node!;
    Lumming? speaker;
    if (node.speaker != null) {
      try {
        speaker = Lumming.crew.firstWhere((l) => l.id.name == node.speaker);
      } catch (_) {
        speaker = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(pack.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        Text(pack.subtitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white70)),
        const SizedBox(height: 8),
        Text('Growing Together  ·  ~${pack.estimatedMinutes} min',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (node.title.isNotEmpty)
                  Text(node.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                if (speaker != null) ...[
                  const SizedBox(height: 6),
                  Text('${speaker.emoji} ${speaker.name}',
                      style: TextStyle(
                        color: speaker.heartlight.accent,
                        fontWeight: FontWeight.w700,
                      )),
                ],
                const SizedBox(height: 12),
                Text(node.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                        )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (node.isEnding) ...[
          Text(
            'Adventure complete · +${adv.progress!.bondXpEarned + pack.completionBondXp} bond · +${adv.progress!.shardsEarned + pack.completionShards} shards',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: adv.reset,
            child: const Text('Play again'),
          ),
        ] else
          ...node.choices.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onPressed: () => adv.choose(c, hl),
                child: Text(
                  c.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        if (adv.progress != null && adv.progress!.memories.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Growing Together memories',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...adv.progress!.memories.map(
            (m) => ListTile(
              dense: true,
              leading: const Icon(Icons.auto_awesome, size: 18),
              title: Text(m),
            ),
          ),
        ],
      ],
    );
  }
}
