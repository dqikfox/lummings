import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/charm.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  Color _accentFor(Charm c) {
    if (c.lummingId == 'all') return LummingsColors.starYellow;
    return Lumming.crew
        .firstWhere((l) => l.id.name == c.lummingId)
        .heartlight
        .accent;
  }

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final s = hl.active;
    final owned = hl.allOwnedCharms.length;
    final total = Charm.catalog.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Collection & Charms',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(
          'Heartlight memorabilia — not separate creatures. '
          'Complete the set for rare glow!  ·  $owned/$total owned  ·  ✨ ${s.essenceShards} shards',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total == 0 ? 0 : owned / total,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          color: LummingsColors.starYellow,
          backgroundColor: Colors.white12,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: Charm.catalog.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) {
            final charm = Charm.catalog[i];
            final unlocked = hl.ownsCharm(charm.id);
            final accent = _accentFor(charm);
            final canAfford = s.essenceShards >= charm.shardCost &&
                s.bond.level >= charm.minBondLevel &&
                !unlocked;

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                if (unlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${charm.emoji} ${charm.blurb}')),
                  );
                  return;
                }
                final result = await hl.purchaseCharm(charm.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: unlocked
                        ? accent
                        : canAfford
                            ? accent.withOpacity(0.6)
                            : Colors.white24,
                    width: unlocked ? 2 : 1,
                  ),
                  color: unlocked
                      ? accent.withOpacity(0.15)
                      : Colors.white10,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      unlocked ? charm.emoji : '🔒',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      charm.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: unlocked ? Colors.white : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unlocked
                          ? 'Owned · ${charm.rarity}'
                          : '✨ ${charm.shardCost} · L${charm.minBondLevel}+',
                      style: TextStyle(
                        fontSize: 11,
                        color: unlocked ? accent : Colors.white54,
                      ),
                    ),
                    if (!unlocked && canAfford) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Tap to unlock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Gentle hook: daily Care & Adventures earn shards. '
          'Missing a day never takes charms away — only soft “I missed you.”',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}
