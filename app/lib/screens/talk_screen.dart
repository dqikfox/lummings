import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/talk_replies.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
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
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
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
    final accent = l.heartlight.accent;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LummingsColors.nestGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Talk with ${l.name}'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: HeartlightBar(
                state: hl.active,
                heartlightName: l.heartlight.name,
                accent: accent,
              ),
            ),
            const SizedBox(height: 12),
            LummingAvatar(lumming: l, size: 88),
            const SizedBox(height: 6),
            Text(
              l.heartlight.line,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _thread.isEmpty
                  ? Center(
                      child: GlassCard(
                        elevated: false,
                        accent: accent,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Offline Talk (Phase 0)\nKind, short, Safety First.\nLive voice AI comes in Phase 1.1.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.white60,
                                height: 1.45,
                              ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.78,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: b.fromKid
                                    ? [
                                        accent.withOpacity(0.35),
                                        accent.withOpacity(0.18),
                                      ]
                                    : [
                                        LummingsColors.surfaceHi
                                            .withOpacity(0.95),
                                        LummingsColors.surface
                                            .withOpacity(0.85),
                                      ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(b.fromKid ? 16 : 4),
                                bottomRight:
                                    Radius.circular(b.fromKid ? 4 : 16),
                              ),
                              border: Border.all(
                                color: b.fromKid
                                    ? accent.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (b.fromKid ? accent : Colors.black)
                                      .withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              b.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: 0.08, end: 0);
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
                  _chip('Tell me a story', 'story', 'Tell me a story', accent),
                  _chip('Hug', 'hug', 'Can I have a hug?', accent),
                  _chip(
                      'Adventure', 'adventure', 'Want an adventure?', accent),
                  _chip(
                      'I feel…', 'feel', 'I have a feeling to share', accent),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: IconButton.filled(
                iconSize: 32,
                style: IconButton.styleFrom(
                  backgroundColor: accent.withOpacity(0.22),
                  foregroundColor: accent,
                  padding: const EdgeInsets.all(18),
                  side: BorderSide(color: accent.withOpacity(0.45)),
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
      ),
    );
  }

  Widget _chip(String label, String key, String kidLine, Color accent) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      backgroundColor: accent.withOpacity(0.12),
      side: BorderSide(color: accent.withOpacity(0.35)),
      onPressed: _busy ? null : () => _say(key, kidLine: kidLine),
    );
  }
}

class _Bubble {
  final bool fromKid;
  final String text;
  _Bubble({required this.fromKid, required this.text});
}
