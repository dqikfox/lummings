import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  static const charms = [
    ('Questlight Charm', 'lumo', true),
    ('Dreamlight Charm', 'lila', false),
    ('Traillight Charm', 'pip', false),
    ('Tidelight Charm', 'nori', true),
    ('Sparklight Charm', 'moki', false),
    ('Seasonal Star', 'all', false),
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HeartlightController>().active;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Collection & Charms',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Complete the set for rare rewards!  ·  ✨ ${s.essenceShards} shards',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: charms.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, i) {
            final (name, who, unlocked) = charms[i];
            final accent = who == 'all'
                ? Colors.amber
                : Lumming.crew
                    .firstWhere((l) => l.id.name == who)
                    .heartlight
                    .accent;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: unlocked ? accent : Colors.white24,
                ),
                color: unlocked ? accent.withOpacity(0.12) : Colors.white10,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.auto_awesome : Icons.lock_outline,
                    color: unlocked ? accent : Colors.white38,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: unlocked ? Colors.white : Colors.white54,
                      )),
                  const SizedBox(height: 4),
                  Text(unlocked ? 'Owned' : 'earn more',
                      style: TextStyle(
                        fontSize: 12,
                        color: unlocked ? accent : Colors.white38,
                      )),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
