import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lumming.dart';
import '../../state/heartlight_controller.dart';
import '../../widgets/lumming_avatar.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0;
  LummingId? chosen;
  final pinCtrl = TextEditingController();

  @override
  void dispose() {
    pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _welcome() {
    return Column(
      children: [
        const Spacer(),
        Text('Welcome to Lummings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                )),
        const SizedBox(height: 8),
        Text('Little lights. Big little adventures.',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          children: Lumming.crew
              .map((l) => LummingAvatar(lumming: l, size: 64))
              .toList(),
        ),
        const Spacer(),
        const Chip(label: Text('Safety First')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => setState(() => step = 1),
          child: const Text('Meet Your Crew'),
        ),
      ],
    );
  }

  Widget _pick() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick your first friend',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                )),
        const SizedBox(height: 8),
        const Text(
            'The others join as your bond grows. Each Heartlight is their essence — who they are.'),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: Lumming.crew.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final l = Lumming.crew[i];
              final sel = chosen == l.id;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: sel ? l.heartlight.accent : Colors.white24,
                    width: sel ? 2 : 1,
                  ),
                ),
                leading: Text(l.emoji, style: const TextStyle(fontSize: 28)),
                title: Text('${l.name} · ${l.heartlight.name}'),
                subtitle: Text(l.blurb),
                selected: sel,
                onTap: () => setState(() => chosen = l.id),
              );
            },
          ),
        ),
        FilledButton(
          onPressed: chosen == null ? null : () => setState(() => step = 2),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _parent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Parents & Safety',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                )),
        const SizedBox(height: 8),
        const Text(
            'Set a PIN, keep privacy filters on, and grow together safely.'),
        const SizedBox(height: 20),
        TextField(
          controller: pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Parent PIN (optional but recommended)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: Icon(Icons.privacy_tip, color: Colors.lightGreenAccent),
          title: Text('Privacy Controls ON'),
          subtitle: Text('Default · COPPA-minded'),
        ),
        const ListTile(
          leading: Icon(Icons.filter_alt, color: Colors.lightGreenAccent),
          title: Text('Content Filters ON'),
          subtitle: Text('Default · age-appropriate'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () async {
            final hl = context.read<HeartlightController>();
            await hl.completeOnboarding(
              chosen ?? LummingId.lumo,
              pin: pinCtrl.text.trim().isEmpty ? null : pinCtrl.text.trim(),
            );
          },
          child: const Text('Start Growing Together'),
        ),
      ],
    );
  }
}
