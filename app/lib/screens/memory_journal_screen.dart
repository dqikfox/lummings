import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';
import '../widgets/lumming_avatar.dart';

/// Memory Journal — beautiful timeline of Heartlight moments.
/// Memories are essence stories, never a separate creature log.
class MemoryJournalScreen extends StatelessWidget {
  const MemoryJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final l = hl.activeLumming;
    final memories = hl.active.memoryHighlights.reversed.toList();

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LummingsColors.nestGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Memory Journal'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: LummingAvatar(
                lumming: l,
                size: 96,
                glowing: true,
                phase: hl.active.phase,
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${l.name}\'s Heartlight memories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Essence moments that define who they are — not separate creatures.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 22),
            NestSectionHeader(
              title: 'Timeline',
              trailing: '${memories.length}',
              accent: l.heartlight.accent,
            ),
            const SizedBox(height: 12),
            if (memories.isEmpty)
              GlassCard(
                accent: l.heartlight.accent,
                child: Column(
                  children: [
                    Text('🌟', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 10),
                    Text(
                      'No memories yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Care, Talk, Adventures, and Charms write soft sparks here. '
                      'Come back after a hug — ${l.name} will remember.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: LummingsColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(memories.length, (i) {
                final m = memories[i];
                final isLatest = i == 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    accent: isLatest ? l.heartlight.accent : null,
                    elevated: isLatest,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                l.heartlight.accent.withOpacity(0.45),
                                l.heartlight.accent.withOpacity(0.12),
                              ],
                            ),
                            border: Border.all(
                              color: l.heartlight.accent.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _emojiFor(m),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLatest)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'Latest spark',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: l.heartlight.accent,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              Text(
                                m,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (30 * i).ms, duration: 320.ms)
                      .slideX(begin: 0.04, end: 0),
                );
              }),
            const SizedBox(height: 8),
            Text(
              'Gentle hook: kids return to re-read their story with ${l.name}. '
              'Memories never expire or get deleted by missing a day.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _emojiFor(String m) {
    final lower = m.toLowerCase();
    if (lower.contains('charm') || lower.contains('unlocked')) return '💎';
    if (lower.contains('festival')) return '🎉';
    if (lower.contains('came back') || lower.contains('missed')) return '💛';
    if (lower.contains('talk')) return '💬';
    if (lower.contains('adventure') ||
        lower.contains('forest') ||
        lower.contains('tide') ||
        lower.contains('leaf')) {
      return '📖';
    }
    if (lower.contains('spark') || lower.contains('daily')) return '✨';
    return '❤️';
  }
}
