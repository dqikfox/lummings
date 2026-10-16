import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lumming.dart';
import '../state/adventure_controller.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';

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
    ),
    _PackMeta(
      asset: 'assets/adventures/spark_mixup_001.json',
      title: 'The Kind Mix-Up',
      subtitle: 'Sparklight adventure with Moki · ~5 min',
      emoji: '✨',
    ),
    _PackMeta(
      asset: 'assets/adventures/leafy_steps_001.json',
      title: 'Three Leafy Steps',
      subtitle: 'Traillight adventure with Pip · ~5 min',
      emoji: '🍃',
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
      padding: const EdgeInsets.all(20),
      children: [
        Text('Adventures',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(
          'Growing Together stories. Heartlights are essence — never separate creatures.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (adv.error != null) ...[
          const SizedBox(height: 12),
          Text(adv.error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 16),
        ...packs.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Text(p.emoji, style: const TextStyle(fontSize: 32)),
                title: Text(p.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(p.subtitle),
                trailing: const Icon(Icons.play_arrow_rounded),
                onTap: adv.loading ? null : () => _openPack(p.asset),
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Finish an adventure to earn bond XP + essence shards for Charms.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white54),
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
      return const Center(child: CircularProgressIndicator());
    }
    final pack = adv.pack!;
    final node = adv.node!;
    Lumming? speaker;
    if (node.speaker != null && node.speaker != 'narrator') {
      try {
        speaker =
            Lumming.crew.firstWhere((l) => l.id.name == node.speaker);
      } catch (_) {
        speaker = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        if (pack.subtitle.isNotEmpty)
          Text(pack.subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54)),
        const SizedBox(height: 12),
        if (node.title.isNotEmpty)
          Text(node.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (speaker != null) ...[
          Row(
            children: [
              Text(speaker.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                speaker.name,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: speaker.heartlight.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (speaker?.heartlight.accent ?? LummingsColors.starYellow)
                  .withOpacity(0.35),
            ),
          ),
          child: Text(node.body, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        if (node.isEnding) ...[
          Text(
            'Adventure complete · +${adv.progress?.bondXpEarned ?? 0} path XP '
            '(completion bonus applied)',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              adv.reset();
              setState(() => _inStory = false);
            },
            child: const Text('Back to adventure list'),
          ),
        ] else
          ...node.choices.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onPressed: () async {
                  await adv.choose(c, hl);
                  if (c.heartlightLine != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(c.heartlightLine!)),
                    );
                  }
                },
                child: Text(
                  c.safetyCheck ? '🛡️ ${c.label}' : c.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
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
  const _PackMeta({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}
