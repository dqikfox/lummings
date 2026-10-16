import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/lumming.dart';
import '../state/adventure_controller.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';

class AdventuresScreen extends StatefulWidget {
  const AdventuresScreen({super.key});

  @override
  State<AdventuresScreen> createState() => _AdventuresScreenState();
}

class _AdventuresScreenState extends State<AdventuresScreen> {
  static const packs = <_PackMeta>[
    _PackMeta(
      asset: 'assets/adventures/growing_together_001.json',
      title: 'The Night Forest Awakens',
      subtitle: 'First Heartlight adventure · ~6 min',
      emoji: '🌲',
      accent: LummingsColors.traillight,
    ),
    _PackMeta(
      asset: 'assets/adventures/spark_mixup_001.json',
      title: 'The Kind Mix-Up',
      subtitle: 'Sparklight adventure with Moki · ~5 min',
      emoji: '✨',
      accent: LummingsColors.sparklight,
    ),
    _PackMeta(
      asset: 'assets/adventures/leafy_steps_001.json',
      title: 'Three Leafy Steps',
      subtitle: 'Traillight adventure with Pip · ~5 min',
      emoji: '🍃',
      accent: LummingsColors.dreamTeal,
    ),
    _PackMeta(
      asset: 'assets/adventures/quiet_tide_001.json',
      title: 'The Quiet Tide',
      subtitle: 'Tidelight adventure with Nori · ~5 min',
      emoji: '🌙',
      accent: LummingsColors.tidelight,
    ),
  ];

  bool _inStory = false;

  Future<void> _openPack(String asset) async {
    final adv = context.read<AdventureController>();
    await adv.loadPack(asset);
    if (!mounted) return;
    if (adv.error == null && adv.pack != null) {
      setState(() => _inStory = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adv = context.watch<AdventureController>();
    final hl = context.watch<HeartlightController>();

    if (!_inStory || adv.pack == null || adv.node == null) {
      return _catalog(context, adv);
    }
    return _story(context, adv, hl);
  }

  Widget _catalog(BuildContext context, AdventureController adv) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const NestSectionHeader(
          title: 'Adventures',
          accent: LummingsColors.dreamTeal,
        ),
        const SizedBox(height: 10),
        Text(
          'Growing Together stories. Heartlights are essence — never separate creatures.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LummingsColors.muted,
                height: 1.35,
              ),
        ),
        if (adv.error != null) ...[
          const SizedBox(height: 12),
          Text(adv.error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 18),
        ...packs.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GlassCard(
              accent: p.accent,
              onTap: adv.loading ? null : () => _openPack(p.asset),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: RadialGradient(
                        colors: [
                          p.accent.withOpacity(0.45),
                          p.accent.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(color: p.accent.withOpacity(0.4)),
                    ),
                    alignment: Alignment.center,
                    child: Text(p.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.subtitle,
                          style: const TextStyle(
                            color: LummingsColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: p.accent,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (60 * i).ms, duration: 400.ms)
                .slideX(begin: 0.04, end: 0),
          );
        }),
        const SizedBox(height: 8),
        GlassCard(
          elevated: false,
          padding: const EdgeInsets.all(14),
          child: Text(
            'Finish an adventure to earn bond XP + essence shards for Charms. Soft hooks only — never punish.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }

  Widget _story(
    BuildContext context,
    AdventureController adv,
    HeartlightController hl,
  ) {
    if (adv.loading) {
      return const Center(
        child: CircularProgressIndicator(color: LummingsColors.starYellow),
      );
    }
    final pack = adv.pack!;
    final node = adv.node!;
    Lumming? speaker;
    if (node.speaker != null && node.speaker != 'narrator') {
      try {
        speaker = Lumming.crew.firstWhere((l) => l.id.name == node.speaker);
      } catch (_) {
        speaker = null;
      }
    }
    final accent = speaker?.heartlight.accent ?? LummingsColors.starYellow;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 28),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                adv.reset();
                setState(() => _inStory = false);
              },
            ),
            Expanded(
              child: Text(
                pack.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ),
        if (pack.subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              pack.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ),
        const SizedBox(height: 14),
        if (node.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: NestSectionHeader(title: node.title, accent: accent),
          ),
        if (speaker != null) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: accent.withOpacity(0.18),
                  border: Border.all(color: accent.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(speaker.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      speaker.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        GlassCard(
          accent: accent,
          padding: const EdgeInsets.all(18),
          child: Text(
            node.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ).animate().fadeIn(duration: 350.ms),
        const SizedBox(height: 18),
        if (node.isEnding) ...[
          GlassCard(
            accent: LummingsColors.starYellow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Adventure complete · +${adv.progress?.bondXpEarned ?? 0} path XP',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Completion bonus applied · Heartlight essence grows',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LummingsColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    adv.reset();
                    setState(() => _inStory = false);
                  },
                  child: const Text('Back to adventure list'),
                ),
              ],
            ),
          ),
        ] else
          ...node.choices.asMap().entries.map((e) {
            final c = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                accent: c.safetyCheck ? LummingsColors.dreamTeal : accent,
                elevated: true,
                padding: EdgeInsets.zero,
                onTap: () async {
                  await adv.choose(c, hl);
                  if (c.heartlightLine != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(c.heartlightLine!)),
                    );
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.safetyCheck ? '🛡️ ${c.label}' : c.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: (c.safetyCheck
                                ? LummingsColors.dreamTeal
                                : accent)
                            .withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (50 * e.key).ms)
                  .slideY(begin: 0.05, end: 0),
            );
          }),
      ],
    );
  }
}

class _PackMeta {
  final String asset;
  final String title;
  final String subtitle;
  final String emoji;
  final Color accent;
  const _PackMeta({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accent,
  });
}
