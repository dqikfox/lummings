import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/charm.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../services/feedback.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        NestSectionHeader(
          title: 'Collection & Charms',
          trailing: '$owned/$total',
          accent: LummingsColors.starYellow,
        ),
        const SizedBox(height: 10),
        Text(
          'Heartlight memorabilia — not separate creatures. '
          'Complete the set for rare glow!  ·  ✨ ${s.essenceShards} shards',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LummingsColors.muted,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          accent: LummingsColors.starYellow,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Set progress',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    '${((total == 0 ? 0 : owned / total) * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: LummingsColors.starYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : owned / total,
                  minHeight: 10,
                  color: LummingsColors.starYellow,
                  backgroundColor: Colors.white12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: Charm.catalog.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, i) {
            final charm = Charm.catalog[i];
            final unlocked = hl.ownsCharm(charm.id);
            final accent = _accentFor(charm);
            final canAfford = s.essenceShards >= charm.shardCost &&
                s.bond.level >= charm.minBondLevel &&
                !unlocked;

            return GlassCard(
              accent: unlocked
                  ? accent
                  : canAfford
                      ? accent
                      : null,
              elevated: unlocked || canAfford,
              padding: const EdgeInsets.all(14),
              onTap: () async {
                if (unlocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${charm.emoji} ${charm.blurb}')),
                  );
                  return;
                }
                final result = await hl.purchaseCharm(charm.id);
                if (result.ok) await NestFeedback.unlockCharm();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    unlocked ? charm.emoji : '🔒',
                    style: TextStyle(fontSize: unlocked ? 36 : 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    charm.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: unlocked
                          ? LummingsColors.warmWhite
                          : LummingsColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: unlocked
                          ? accent.withOpacity(0.2)
                          : Colors.white.withOpacity(0.06),
                    ),
                    child: Text(
                      unlocked
                          ? 'Owned · ${charm.rarity}'
                          : '✨ ${charm.shardCost} · L${charm.minBondLevel}+',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: unlocked ? accent : Colors.white54,
                      ),
                    ),
                  ),
                  if (!unlocked && canAfford) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to unlock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (40 * i).ms, duration: 350.ms)
                .slideY(begin: 0.06, end: 0);
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Gentle hook: daily Care & Adventures earn shards. '
          'Missing a day never takes charms away — only soft “I missed you.”',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}
