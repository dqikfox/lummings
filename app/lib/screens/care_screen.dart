import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';
import '../services/feedback.dart';
import '../widgets/bond_levelup_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';
import '../widgets/streak_flame.dart';
import '../widgets/care_sparkle_overlay.dart';

class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> {
  String? lastMessage;
  bool busy = false;
  bool sparkle = false;

  Future<void> _care(String kind) async {
    setState(() => busy = true);
    final hl = context.read<HeartlightController>();
    final messenger = ScaffoldMessenger.of(context);
    await NestFeedback.carePulse();
    final result = await hl.performCare(kind: kind);
    if (!mounted) return;
    setState(() {
      busy = false;
      lastMessage = result.message;
      if (!result.alreadyDone) sparkle = true;
    });
    messenger.showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.leveledUp) {
      await NestFeedback.levelUpBurst();
      if (!mounted) return;
      await showBondLevelUpDialog(
        context,
        lumming: hl.activeLumming,
        newLevel: hl.active.bond.level,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final l = hl.activeLumming;
    final s = hl.active;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            NestSectionHeader(
              title: 'Care & Heartlight Ritual',
              accent: l.heartlight.accent,
            ),
            const SizedBox(height: 10),
            Text(
              l.heartlight.ritual,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LummingsColors.muted,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 18),
            HeartlightBar(
              state: s,
              heartlightName: l.heartlight.name,
              accent: l.heartlight.accent,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            StreakFlame(
              streak: s.careStreak,
              caredToday: s.caredToday,
              accent: l.heartlight.accent,
            ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
            const SizedBox(height: 28),
            Center(
              child: LummingAvatar(
                lumming: l,
                size: 148,
                glowing: true,
                phase: s.phase,
                equippedCharmId: s.equippedCharmId,
              ),
            ).animate().scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: 450.ms,
                ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Essence · ${l.heartlight.name}',
                style: TextStyle(
                  color: l.heartlight.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              accent: l.heartlight.accent,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _CareButton(
                    label: 'Hug',
                    icon: Icons.favorite_rounded,
                    color: LummingsColors.glowPink,
                    onPressed: busy ? null : () => _care('hug'),
                  ),
                  const SizedBox(height: 10),
                  _CareButton(
                    label: 'Talk',
                    icon: Icons.chat_bubble_rounded,
                    color: LummingsColors.dreamTeal,
                    onPressed: busy ? null : () => _care('talk'),
                  ),
                  const SizedBox(height: 10),
                  _CareButton(
                    label: 'Share a Story',
                    icon: Icons.menu_book_rounded,
                    color: LummingsColors.futurePurple,
                    onPressed: busy ? null : () => _care('story'),
                  ),
                  const SizedBox(height: 10),
                  _CareButton(
                    label: 'Sync Plush',
                    icon: Icons.nfc_rounded,
                    color: LummingsColors.muted,
                    outlined: true,
                    onPressed: busy
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Plush sync arrives in Phase 1.1 — NFC/BLE Heartlight LED.',
                                ),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
            if (lastMessage != null) ...[
              const SizedBox(height: 20),
              GlassCard(
                elevated: false,
                accent: l.heartlight.accent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  lastMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: CareSparkleOverlay(
            accent: l.heartlight.accent,
            play: sparkle,
            onDone: () {
              if (mounted) setState(() => sparkle = false);
            },
          ),
        ),
      ],
    );
  }
}

class _CareButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool outlined;

  const _CareButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: LummingsColors.warmWhite,
          side: BorderSide(color: color.withOpacity(0.35)),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: LummingsColors.softBlack,
      ),
    );
  }
}
