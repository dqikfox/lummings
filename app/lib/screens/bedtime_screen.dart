import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/feedback.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/lumming_avatar.dart';
import '../widgets/nest_section_header.dart';

/// Soft evening wind-down — once per night, never locks the app.
class BedtimeScreen extends StatefulWidget {
  const BedtimeScreen({super.key});

  @override
  State<BedtimeScreen> createState() => _BedtimeScreenState();
}

class _BedtimeScreenState extends State<BedtimeScreen> {
  int step = 0;
  bool busy = false;
  String? resultMsg;

  static const breaths = [
    'Breathe in soft light…',
    'Hold a tiny spark…',
    'Breathe out worries…',
  ];

  Future<void> _finish() async {
    if (busy) return;
    setState(() => busy = true);
    final hl = context.read<HeartlightController>();
    final name = hl.activeLumming.name;
    await NestFeedback.softSuccess();
    if (!mounted) return;
    final r = await hl.performBedtime(
      note: 'Three soft breaths with $name',
    );
    if (!mounted) return;
    setState(() {
      busy = false;
      resultMsg = r.message;
      step = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final l = hl.activeLumming;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF070A14),
            l.heartlight.accent.withOpacity(0.12),
            const Color(0xFF0A0E1C),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Bedtime Nest'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            NestSectionHeader(
              title: 'Moon tuck',
              trailing: hl.bedtimeDoneToday ? 'Done' : 'Open',
              accent: LummingsColors.tidelight,
            ),
            const SizedBox(height: 8),
            Text(
              'A gentle wind-down with ${l.name}. Once per night. Never a lock — parents keep soft reminders only.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: LummingAvatar(
                lumming: l,
                size: 140,
                glowing: true,
                phase: hl.active.phase,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1.02, 1.02),
                  duration: 2200.ms,
                ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l.heartlight.line,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: l.heartlight.accent.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (hl.bedtimeDoneToday && step < 3)
              GlassCard(
                accent: LummingsColors.tidelight,
                child: const Text(
                  '🌙 Already tucked in tonight. Come back tomorrow for another soft glow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                ),
              )
            else ...[
              if (step < 3)
                GlassCard(
                  accent: l.heartlight.accent,
                  child: Column(
                    children: [
                      Text(
                        step < breaths.length
                            ? breaths[step]
                            : 'Ready to tuck the glow?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step ${step + 1} of 3 · soft breaths only',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : () async {
                                  await NestFeedback.lightTap();
                                  if (step < 2) {
                                    setState(() => step++);
                                  } else {
                                    await _finish();
                                  }
                                },
                          child: Text(
                            step < 2 ? 'Next breath' : (busy ? 'Tucking…' : 'Tuck Heartlight'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (resultMsg != null) ...[
                const SizedBox(height: 16),
                GlassCard(
                  accent: LummingsColors.starYellow,
                  child: Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        resultMsg!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to Nest'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20),
            Text(
              'Heartlights are essence — ${l.heartlight.name} is who ${l.name} is. Bedtime does not remove bond; it rests the glow.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
