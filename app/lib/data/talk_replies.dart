import '../models/lumming.dart';

/// Offline Talk replies — Phase 0 before live LLM.
/// Rules: short, kind, never real-world medical/legal advice, always
/// point hard problems to a trusted adult (Safety First).
class TalkReply {
  final String promptKey;
  final String text;
  final int bondXp;
  final int shards;

  const TalkReply({
    required this.promptKey,
    required this.text,
    this.bondXp = 5,
    this.shards = 0,
  });
}

class TalkCatalog {
  static List<TalkReply> forLumming(LummingId id) {
    switch (id) {
      case LummingId.lumo:
        return const [
          TalkReply(
            promptKey: 'story',
            text:
                'Player one — that\'s you. Once, a tiny controller glowed red and turned a big scary level into three safe co-op steps. We checked the map. We chose. We won together. Your turn — what quest should we map next?',
            bondXp: 8,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'hug',
            text:
                'Questlight pulse online. Hug accepted. System status: safer, warmer, +1 friend. If something feels too big, we pick one small next move — or we ask a trusted adult. Ready when you are.',
            bondXp: 6,
          ),
          TalkReply(
            promptKey: 'adventure',
            text:
                'Adventure mode? Check. Look first. Pick a step. Try it together. The Night Forest is waiting in Adventures — or invent a new path with me right here.',
            bondXp: 5,
          ),
          TalkReply(
            promptKey: 'feel',
            text:
                'Feelings are valid data. Name the feeling. Shrink the problem. Choose one co-op step. If it\'s heavy, a trusted adult is the best party member.',
            bondXp: 7,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'default',
            text:
                'Let\'s I-lumming-Nate our next move. I\'m listening — story, hug, adventure, or a feeling you want to map.',
          ),
        ];
      case LummingId.luna:
        return const [
          TalkReply(
            promptKey: 'story',
            text:
                'Once, a violet ribbon unfurled into a path of pictures: a worry, a hand, a heart that glowed from the inside. The pictures didn\'t erase the worry — they named it. Shall we name yours?',
            bondXp: 8,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'hug',
            text:
                'Soft moon-hug. Dreamlight wraps around the edges of the day. You are not alone in the story.',
            bondXp: 6,
          ),
          TalkReply(
            promptKey: 'adventure',
            text:
                'Adventures can be quiet. Sometimes the bravest quest is saying a feeling out loud. Want a story-path, or shall we open Adventures together?',
            bondXp: 5,
          ),
          TalkReply(
            promptKey: 'feel',
            text:
                'Name the wonder. Imagine possibilities. Find what is true. Hard truths belong with a trusted adult — I can help you practice the words.',
            bondXp: 7,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'default',
            text:
                'Let\'s I-lumming-Nate your what-if. I\'m here for stories, soft hugs, and careful feelings.',
          ),
        ];
      case LummingId.sprout:
        return const [
          TalkReply(
            promptKey: 'story',
            text:
                'Once the path had three wobbly stones. Rushing made fireflies bump noses. Going slow made the trail glow. Look first. Pick a step. Try it together.',
            bondXp: 8,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'hug',
            text:
                'Leaf-hug complete. Traillight steady. We don\'t have to finish the whole forest today — just the next safe step.',
            bondXp: 6,
          ),
          TalkReply(
            promptKey: 'adventure',
            text:
                'Adventure checklist: 1) look, 2) choose one step, 3) check in. Night Forest is in Adventures if you want a guided path.',
            bondXp: 5,
          ),
          TalkReply(
            promptKey: 'feel',
            text:
                'Big feelings can be split into steps, same as trails. If a step feels too steep, ask a trusted adult to walk with you.',
            bondXp: 7,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'default',
            text:
                'Let\'s I-lumming-Nate the way. I help break big paths into leafy little steps.',
          ),
        ];
      case LummingId.nori:
        return const [
          TalkReply(
            promptKey: 'story',
            text:
                'Lowbeam the lantern noticed a quiet question no one had rushed past. The little things glowed when we paused. Want to notice something together?',
            bondXp: 8,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'hug',
            text:
                'Tide-hug. Soft silver centre. Sometimes the kindest thing is a long pause and a quiet breath.',
            bondXp: 6,
          ),
          TalkReply(
            promptKey: 'adventure',
            text:
                'Adventures can be soft. Approach quietly. Notice carefully. Explore without rushing. The Night Forest waits when you\'re ready.',
            bondXp: 5,
          ),
          TalkReply(
            promptKey: 'feel',
            text:
                'Pause. Notice. Wonder together. If a feeling is storm-big, a trusted adult is a safe harbour.',
            bondXp: 7,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'default',
            text:
                'Let\'s I-lumming-Nate the little things. I\'m good at quiet noticing.',
          ),
        ];
      case LummingId.moki:
        return const [
          TalkReply(
            promptKey: 'story',
            text:
                'Plot twist! A mix-up tried to look like a monster. We made a kind joke, rearranged the pixels, and it turned into a clearer pattern. Want a silly story or a real one?',
            bondXp: 8,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'hug',
            text:
                'Chaos-hug with sparkles. Mix-ups shrink when we laugh kindly — never mean, always gentle.',
            bondXp: 6,
          ),
          TalkReply(
            promptKey: 'adventure',
            text:
                'Adventure = kind jokes + careful checks. Spot the mix-up. Check it kindly. Try a new idea. Or open Adventures for the Night Forest!',
            bondXp: 5,
          ),
          TalkReply(
            promptKey: 'feel',
            text:
                'Feelings can feel like plot twists. We examine them carefully. If it\'s scary-big, bring a trusted adult into the party.',
            bondXp: 7,
            shards: 1,
          ),
          TalkReply(
            promptKey: 'default',
            text:
                'Let\'s I-lumming-Nate that plot twist. Ready for stories, hugs, or adventures.',
          ),
        ];
    }
  }

  static TalkReply pick(LummingId id, String promptKey) {
    final list = forLumming(id);
    return list.firstWhere(
      (r) => r.promptKey == promptKey,
      orElse: () => list.firstWhere((r) => r.promptKey == 'default'),
    );
  }
}
