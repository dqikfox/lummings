import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/talk_replies.dart';
import '../state/heartlight_controller.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';

class TalkScreen extends StatefulWidget {
  const TalkScreen({super.key});

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  final List<_Bubble> _thread = [];
  bool _busy = false;

  Future<void> _say(String promptKey, {String? kidLine}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final hl = context.read<HeartlightController>();
    final l = hl.activeLumming;

    if (kidLine != null) {
      setState(() => _thread.add(_Bubble(fromKid: true, text: kidLine)));
    }

    final reply = TalkCatalog.pick(l.id, promptKey);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _thread.add(_Bubble(fromKid: false, text: reply.text));
      _busy = false;
    });

    await hl.rewardTalk(
      bondXp: reply.bondXp,
      shards: reply.shards,
      memory: reply.bondXp > 0
          ? 'Talked with ${l.name}: $promptKey'
          : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final l = hl.activeLumming;

    return Scaffold(
      appBar: AppBar(title: Text('Talk with ${l.name}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: HeartlightBar(
              state: hl.active,
              heartlightName: l.heartlight.name,
              accent: l.heartlight.accent,
            ),
          ),
          const SizedBox(height: 8),
          LummingAvatar(lumming: l, size: 88),
          const SizedBox(height: 4),
          Text(
            l.heartlight.line,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _thread.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Offline Talk (Phase 0)\nKind, short, Safety First.\nLive voice AI comes in Phase 1.1.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white54),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _thread.length,
                    itemBuilder: (context, i) {
                      final b = _thread[i];
                      return Align(
                        alignment: b.fromKid
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: b.fromKid
                                ? l.heartlight.accent.withOpacity(0.25)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: b.fromKid
                                  ? l.heartlight.accent.withOpacity(0.5)
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(b.text),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _chip('Tell me a story', 'story', 'Tell me a story'),
                _chip('Hug', 'hug', 'Can I have a hug?'),
                _chip('Adventure', 'adventure', 'Want an adventure?'),
                _chip('I feel…', 'feel', 'I have a feeling to share'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton.filled(
              iconSize: 32,
              style: IconButton.styleFrom(
                backgroundColor: l.heartlight.accent.withOpacity(0.2),
                foregroundColor: l.heartlight.accent,
                padding: const EdgeInsets.all(18),
              ),
              icon: const Icon(Icons.mic_rounded),
              onPressed: _busy
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${l.name}: Voice AI + on-device safety filters land in Phase 1.1. Use the chips for now!',
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String key, String kidLine) {
    return ActionChip(
      label: Text(label),
      onPressed: _busy ? null : () => _say(key, kidLine: kidLine),
    );
  }
}

class _Bubble {
  final bool fromKid;
  final String text;
  _Bubble({required this.fromKid, required this.text});
}
