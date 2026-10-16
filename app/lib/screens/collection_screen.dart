import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/charm.dart';
import '../models/nest_badge.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../services/feedback.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';
import '../widgets/lumming_avatar.dart';

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
    final equipped = s.equippedCharmId != null
        ? Charm.byId(s.equippedCharmId!)
        : null;

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
          'Unlock, equip, and show off your bond  ·  ✨ ${s.essenceShards} shards',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LummingsColors.muted,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 14),
        // Live equip preview
        GlassCard(
          accent: hl.activeLumming.heartlight.accent,
          child: Row(
            children: [
              LummingAvatar(
                lumming: hl.activeLumming,
                size: 72,
                glowing: true,
                phase: s.phase,
                equippedCharmId: s.equippedCharmId,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Equipped badge',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      equipped != null
                          ? '${equipped.emoji} ${equipped.name}'
                          : 'None — tap an owned charm to equip',
                      style: TextStyle(
                        color: LummingsColors.muted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    if (equipped != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final msg = await hl.equipCharm(null);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }
                        },
                        child: const Text('Unequip'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        NestSectionHeader(
          title: 'Nest Badges',
          trailing: '${hl.ownedBadges.length}/${NestBadge.catalog.length}',
          accent: LummingsColors.futurePurple,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NestBadge.catalog.map((b) {
            final has = hl.ownedBadges.contains(b.id);
            return Container(
              width: (MediaQuery.of(context).size.width - 56) / 2,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: has
                    ? LummingsColors.futurePurple.withOpacity(0.15)
                    : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: has
                      ? LummingsColors.futurePurple.withOpacity(0.4)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  Text(has ? b.emoji : '🔒', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          has ? b.name : '???',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          has ? b.blurb : 'Keep glowing to unlock',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        NestSectionHeader(
          title: 'Heartlight Charms',
          trailing: '$owned/$total',
          accent: LummingsColors.starYellow,
        ),
        const SizedBox(height: 10),
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
              if (owned >= total && total > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Full set! Crown is waiting if bond is high enough 👑',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: LummingsColors.starYellow.withOpacity(0.9),
                  ),
                ),
              ],
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
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, i) {
            final charm = Charm.catalog[i];
            final unlocked = hl.ownsCharm(charm.id);
            final isEquipped = s.equippedCharmId == charm.id;
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
              elevated: unlocked || canAfford || isEquipped,
              padding: const EdgeInsets.all(14),
              onTap: () async {
                if (unlocked) {
                  final msg = await hl.equipCharm(
                    isEquipped ? null : charm.id,
                  );
                  await NestFeedback.softSelect();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                  return;
                }
                final result = await hl.purchaseCharm(charm.id);
                if (result.ok) {
                  await NestFeedback.unlockCharm();
                  // Auto-equip freshly unlocked charm for instant dopamine.
                  await hl.equipCharm(charm.id);
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isEquipped)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: accent.withOpacity(0.25),
                        ),
                        child: Text(
                          'EQUIPPED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: accent,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
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
                          ? (isEquipped
                              ? 'Tap to unequip'
                              : 'Owned · tap equip')
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
          'Gentle hooks: daily Care & Adventures earn shards. '
          'Equip charms to customize your friend. '
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
