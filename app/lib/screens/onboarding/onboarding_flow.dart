import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/lumming.dart';
import '../../state/heartlight_controller.dart';
import '../../theme/lummings_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/lumming_avatar.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0;
  LummingId? chosen = LummingId.lumo;
  final pinCtrl = TextEditingController();

  @override
  void dispose() {
    pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LummingsColors.nestGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: step == 0
                ? _welcome()
                : step == 1
                    ? _pick()
                    : _parent(),
          ),
        ),
      ),
    );
  }

  Widget _welcome() {
    return Column(
      children: [
        const Spacer(),
        const Text(
          '✨',
          style: TextStyle(fontSize: 42),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.08, 1.08)),
        const SizedBox(height: 12),
        Text(
          'Welcome to Lummings',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'Little lights. Big little adventures.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: LummingsColors.muted,
              ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: Lumming.crew
              .map((l) => LummingAvatar(lumming: l, size: 68))
              .toList(),
        ),
        const Spacer(),
        const GlassCard(
          accent: LummingsColors.dreamTeal,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.shield_rounded, color: LummingsColors.dreamTeal),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Safety First · Heartlights are essence, never separate creatures',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => step = 1),
            child: const Text('Meet Your Crew'),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _pick() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pick your first friend',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Each Lumming has a Heartlight — their essence and soul.',
          style: TextStyle(color: LummingsColors.muted),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: Lumming.crew.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final l = Lumming.crew[i];
              final selected = chosen == l.id;
              return GlassCard(
                accent: selected ? l.heartlight.accent : null,
                onTap: () => setState(() => chosen = l.id),
                child: Row(
                  children: [
                    LummingAvatar(lumming: l, size: 64, glowing: selected),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            l.title,
                            style: TextStyle(
                              color: l.heartlight.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.blurb,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: LummingsColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded,
                          color: l.heartlight.accent),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: chosen == null
              ? null
              : () => setState(() => step = 2),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _parent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.family_restroom_rounded,
            size: 48, color: LummingsColors.starYellow),
        const SizedBox(height: 12),
        Text(
          'Parent gate',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Set a PIN for Parent Dashboard. Leave blank to skip for now.',
          textAlign: TextAlign.center,
          style: TextStyle(color: LummingsColors.muted),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Parent PIN (optional)',
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () async {
            final hl = context.read<HeartlightController>();
            final pin = pinCtrl.text.trim();
            await hl.completeOnboarding(
              chosen ?? LummingId.lumo,
              pin: pin.isEmpty ? null : pin,
            );
          },
          child: const Text('Start Growing Together'),
        ),
      ],
    );
  }
}
