import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/heartlight_controller.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';

class TalkScreen extends StatelessWidget {
  const TalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final l = hl.activeLumming;

    return Scaffold(
      appBar: AppBar(title: Text('Talk with ${l.name}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            HeartlightBar(
              state: hl.active,
              heartlightName: l.heartlight.name,
              accent: l.heartlight.accent,
            ),
            const Spacer(),
            LummingAvatar(lumming: l, size: 150),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: l.heartlight.accent.withOpacity(0.4)),
              ),
              child: Text(
                l.heartlight.line,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _chip(context, 'Tell me a story'),
                _chip(context, 'Hug'),
                _chip(context, 'Adventure'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: l.heartlight.accent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: l.heartlight.accent.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 36,
                icon: const Icon(Icons.mic_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l.name} is ready — full voice AI + safety filters land in Phase 1.1. For now, try Care or Adventures!',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('“$label” — coming with moderated Talk AI')),
        );
      },
    );
  }
}
