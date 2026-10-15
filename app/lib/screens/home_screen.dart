import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';
import 'talk_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final lumming = hl.activeLumming;
    final state = hl.active;
    final greeting = state.phase.name == 'dimmed'
        ? 'I missed you… my ${lumming.heartlight.name} is waiting.'
        : 'Your ${lumming.heartlight.name} is glowing today!';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Heartlight Nest',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                )),
        const SizedBox(height: 8),
        Text(greeting, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        HeartlightBar(
          state: state,
          heartlightName: lumming.heartlight.name,
          accent: lumming.heartlight.accent,
        ),
        const SizedBox(height: 28),
        Center(
          child: LummingAvatar(
            lumming: lumming,
            size: 160,
            glowing: state.phase.name != 'dimmed',
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${lumming.name} · ${lumming.title}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            lumming.heartlight.line,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TalkScreen()),
              ),
              icon: const Icon(Icons.mic_rounded),
              label: const Text('Talk'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.nfc_rounded),
              label: const Text('Sync Plush'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Your Crew',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Lumming.crew.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final l = Lumming.crew[i];
              final selected = l.id == hl.activeId;
              return GestureDetector(
                onTap: () => hl.setActive(l.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? l.heartlight.accent
                          : Colors.white24,
                      width: selected ? 2 : 1,
                    ),
                    color: selected
                        ? l.heartlight.accent.withOpacity(0.15)
                        : Colors.white10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(l.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12)),
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
