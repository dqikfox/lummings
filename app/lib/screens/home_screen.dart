import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../models/heartlight_state.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../state/nav_controller.dart';
import '../services/feedback.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';
import 'plus_screen.dart';
import 'talk_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final nav = context.read<NavController>();
    final lumming = hl.activeLumming;
    final state = hl.active;
    final greeting = state.phase == HeartlightPhase.dimmed
        ? 'I missed you… my ${lumming.heartlight.name} is waiting.'
        : 'Your ${lumming.heartlight.name} is glowing today!';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heartlight Nest',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: LummingsColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    LummingsColors.starYellow.withOpacity(0.22),
                    LummingsColors.starYellow.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: LummingsColors.starYellow.withOpacity(0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: LummingsColors.starYellow.withOpacity(0.15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Text(
                '✨ Nest',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: LummingsColors.starYellow,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.08, end: 0, curve: Curves.easeOut),
        if (hl.screenTimeLimitMinutes > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Parent soft limit · ${hl.screenTimeLimitMinutes} min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LummingsColors.muted.withOpacity(0.8),
                ),
          ),
        ],
        const SizedBox(height: 18),
        HeartlightBar(
          state: state,
          heartlightName: lumming.heartlight.name,
          accent: lumming.heartlight.accent,
        ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
        const SizedBox(height: 28),
        // Hero glow behind avatar
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      lumming.heartlight.accent.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              LummingAvatar(
                lumming: lumming,
                size: 168,
                glowing: state.phase != HeartlightPhase.dimmed,
                phase: state.phase,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 120.ms).scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
              duration: 500.ms,
            ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            lumming.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            lumming.title,
            style: TextStyle(
              color: lumming.heartlight.accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              lumming.heartlight.line,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    height: 1.35,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.mic_rounded,
                label: 'Talk',
                color: lumming.heartlight.accent,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TalkScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.favorite_rounded,
                label: 'Care',
                color: LummingsColors.glowPink,
                onTap: nav.care,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.auto_stories_rounded,
                label: 'Quest',
                color: LummingsColors.dreamTeal,
                onTap: nav.adventures,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.nfc_rounded,
                label: 'Plush',
                color: LummingsColors.futurePurple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Plush NFC/BLE sync lands in Phase 1.1 — Heartlight lives fully in the app for now ✨',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _DailyQuestsCard(hl: hl, nav: nav),
        const SizedBox(height: 14),
        _FestivalCard(hl: hl),
        const SizedBox(height: 14),
        _PlusBanner(hl: hl),
        const SizedBox(height: 22),
        NestSectionHeader(
          title: 'Your Crew',
          accent: lumming.heartlight.accent,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Lumming.crew.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final l = Lumming.crew[i];
              final selected = l.id == hl.activeId;
              return GestureDetector(
                onTap: () async {
                  await NestFeedback.softSelect();
                  await hl.setActive(l.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 96,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? l.heartlight.accent
                          : Colors.white.withOpacity(0.1),
                      width: selected ? 2 : 1,
                    ),
                    gradient: selected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              l.heartlight.accent.withOpacity(0.32),
                              LummingsColors.surface.withOpacity(0.7),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              LummingsColors.surfaceHi.withOpacity(0.75),
                              LummingsColors.surface.withOpacity(0.55),
                            ],
                          ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: l.heartlight.accent.withOpacity(0.35),
                              blurRadius: 16,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(
                        l.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: selected
                              ? LummingsColors.warmWhite
                              : LummingsColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.32),
                LummingsColors.surface.withOpacity(0.9),
              ],
            ),
            border: Border.all(color: color.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyQuestsCard extends StatelessWidget {
  final HeartlightController hl;
  final NavController nav;
  const _DailyQuestsCard({required this.hl, required this.nav});

  void _jump(QuestKind k) {
    switch (k) {
      case QuestKind.care:
        nav.care();
        break;
      case QuestKind.talk:
        nav.home();
        break;
      case QuestKind.adventure:
        nav.adventures();
        break;
      case QuestKind.collect:
        nav.collection();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = hl.quests;
    return GlassCard(
      accent: LummingsColors.starYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NestSectionHeader(
            title: 'Daily Sparks',
            trailing: '${q.doneCount}/${q.total}',
            accent: LummingsColors.starYellow,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: q.fraction,
              minHeight: 9,
              backgroundColor: Colors.white12,
              color: LummingsColors.starYellow,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            q.allDone
                ? 'All sparks lit — come back tomorrow ✨'
                : 'Soft hooks only. Miss a spark? No punishment.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: LummingsColors.muted),
          ),
          const SizedBox(height: 4),
          ...DailyQuest.roster.map((def) {
            final done = q.completedIds.contains(def.id);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? LummingsColors.starYellow.withOpacity(0.18)
                      : Colors.white.withOpacity(0.06),
                ),
                child: Text(
                  done ? '✅' : def.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              title: Text(
                def.title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? LummingsColors.muted : LummingsColors.warmWhite,
                ),
              ),
              subtitle: Text(
                def.blurb,
                style: const TextStyle(
                  fontSize: 12,
                  color: LummingsColors.muted,
                ),
              ),
              trailing: done
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      color: LummingsColors.starYellow,
                      onPressed: () => _jump(def.kind),
                    ),
            );
          }),
        ],
      ),
    );
  }
}

class _FestivalCard extends StatelessWidget {
  final HeartlightController hl;
  const _FestivalCard({required this.hl});

  @override
  Widget build(BuildContext context) {
    final fest = hl.currentFestival;
    final progress = hl.festival;
    return GlassCard(
      accent: LummingsColors.futurePurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NestSectionHeader(
            title: '${fest.emoji} ${fest.title}',
            trailing: progress.claimed ? 'Done' : 'Weekly',
            accent: LummingsColors.futurePurple,
          ),
          const SizedBox(height: 8),
          Text(
            fest.blurb,
            style: const TextStyle(color: LummingsColors.muted, height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            progress.claimed
                ? 'Festival glow claimed — soft FOMO only. Missed weeks never punish.'
                : progress.engaged
                    ? 'You engaged this week! Claim your Festival glow.'
                    : 'Do Care, Talk, Adventure, or a Charm — then claim. No pressure.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: progress.claimed
                  ? null
                  : () async {
                      await NestFeedback.lightTap();
                      final msg = await hl.claimFestivalBonus();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      }
                    },
              child: Text(
                progress.claimed
                    ? 'Claimed ✨'
                    : 'Claim Festival glow',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlusBanner extends StatelessWidget {
  final HeartlightController hl;
  const _PlusBanner({required this.hl});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accent: LummingsColors.starYellow,
      elevated: false,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlusScreen()),
        );
      },
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hl.isPlus ? 'Heartlight Plus active' : 'Heartlight Plus',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Cosmetic glow & early stories — bond stays free forever',
                  style: TextStyle(
                    fontSize: 12,
                    color: LummingsColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: LummingsColors.starYellow),
        ],
      ),
    );
  }
}
