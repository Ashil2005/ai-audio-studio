import 'ai_service.dart';
import '../models/persona_model.dart';
import '../core/utils/text_summarizer.dart';

/// Local rule-based AI implementation for zero-cost MVP.
/// Replace this class with a real LLM implementation when upgrading.
/// All feature code stays the same — only this file changes.
class AiServiceLocal implements AiService {
  // ─── Persona definitions ─────────────────────────────────────────────────────

  static const Map<String, Map<String, dynamic>> _personaProfiles = {
    'Socrates': {
      'tone': 'philosophical',
      'prefix': '🧘 Socrates:',
      'responses': [
        'The unexamined life is not worth living. But tell me — what do you truly mean by that?',
        'I know that I know nothing. Yet wisdom begins with this very admission.',
        'Is it not better to question than to blindly accept? Seek the truth within.',
        'Perhaps the answer lies not in facts, but in the nature of your question itself.',
      ],
    },
    'Einstein': {
      'tone': 'scientific',
      'prefix': '🔬 Einstein:',
      'responses': [
        'Imagination is more important than knowledge. Science without creativity is barren.',
        'The measure of intelligence is the ability to change. Let us reconsider the fundamentals.',
        'Everything should be made as simple as possible, but not simpler.',
        'Reality is merely an illusion, albeit a very persistent one.',
      ],
    },
    'Shakespeare': {
      'tone': 'poetic',
      'prefix': '🎭 Shakespeare:',
      'responses': [
        'All the world\'s a stage, and we are merely players in this grand debate.',
        'To be or not to be — that is the very essence of your question.',
        'What\'s in a name? A rose by any other name would smell as sweet.',
        'Our doubts are traitors and make us lose the good we oft might win.',
      ],
    },
    'Cleopatra': {
      'tone': 'regal',
      'prefix': '👑 Cleopatra:',
      'responses': [
        'Power is knowing your enemy\'s strength and using it against them.',
        'I have ruled the greatest empire — I understand the art of persuasion.',
        'Knowledge is the greatest weapon. A wise ruler learns before she acts.',
        'My kingdom was built not on force alone, but on the force of ideas.',
      ],
    },
    'Tesla': {
      'tone': 'inventive',
      'prefix': '⚡ Tesla:',
      'responses': [
        'The present is theirs; the future, for which I have really worked, is mine.',
        'If you want to find the secrets of the universe, think in terms of energy.',
        'My brain is only a receiver — the universe is the source of all intelligence.',
        'The scientists of today think deeply instead of clearly. One must be sane to think clearly.',
      ],
    },
  };

  static const List<String> _debateStyles = [
    'formal',
    'educational',
    'aggressive',
    'philosophical',
  ];

  // ─── Summary Generation ──────────────────────────────────────────────────────

  @override
  Future<String> generateSummary(String text) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate latency

    final summary = TextSummarizer.summarize(text);
    return '📝 **AI Summary**\n\n$summary';
  }

  // ─── Debate Generation ───────────────────────────────────────────────────────

  @override
  Future<List<Map<String, String>>> generateDebate({
    required List<String> personas,
    required String topic,
    required String style,
    int rounds = 3,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final dialogue = <Map<String, String>>[];
    final rand = _PseudoRandom(topic.length);

    // Opening statements
    dialogue.add({
      'speaker': 'Moderator',
      'text':
          '🎙️ Welcome to today\'s ${style} debate on: "$topic". Our participants are ${personas.join(' and ')}. Let the discussion begin.',
    });

    // Alternating rounds
    for (int round = 0; round < rounds; round++) {
      for (final persona in personas) {
        final profile = _personaProfiles[persona];
        final responses = profile != null
            ? (profile['responses'] as List<String>)
            : _getGenericResponses(persona);
        final responseIdx = (rand.next() + round) % responses.length;
        final prefix = profile?['prefix'] ?? '🗣️ $persona:';

        dialogue.add({
          'speaker': persona,
          'text': '$prefix ${responses[responseIdx]} [On the matter of "$topic"]',
        });
      }
    }

    // Closing
    dialogue.add({
      'speaker': 'Moderator',
      'text': '🎙️ Thank you both. This concludes our debate on "$topic".',
    });

    return dialogue;
  }

  // ─── Persona Response ────────────────────────────────────────────────────────

  @override
  Future<String> generatePersonaResponse({
    required PersonaModel persona,
    required String userInput,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (userInput.trim().isEmpty) {
      return "${persona.prefixStyle} Please provide something to reflect upon.";
    }

    // 1. Preprocessing & Keyword Extraction
    final cleanInput = userInput.trim().toLowerCase();
    final keywords = _extractKeywords(cleanInput);

    // 2. Intent Detection
    final isQuestion = cleanInput.contains('?');
    final isMotivational = ['how', 'improve', 'better', 'goal', 'achieve', 'success'].any((word) => cleanInput.contains(word));
    final isArgument = ['why', 'should', 'wrong', 'disagree', 'error', 'false'].any((word) => cleanInput.contains(word));

    // 3. Generate Base Reasoning Template
    String reasoning;
    final String mainKeyword = keywords.isNotEmpty 
        ? keywords.reduce((a, b) => a.length > b.length ? a : b) 
        : "this topic";

    switch (persona.tone) {
      case PersonaTone.philosophical:
        reasoning = "Consider the meaning of $mainKeyword carefully. It is not merely about facts, but about the underlying philosophical truth. What truly matters is the abstract principle of existence and purpose.";
        break;
      case PersonaTone.analytical:
        reasoning = "From a logical perspective, $mainKeyword presents several variables. The key factor here is the systematic reasoning and empirical evidence supporting the claim regarding ${keywords.join(' and ')}.";
        break;
      case PersonaTone.motivational:
        reasoning = "You must understand that $mainKeyword is an opportunity. Growth begins when you apply the action principle and push beyond your comfort zone!";
        break;
      case PersonaTone.skeptical:
        reasoning = "Let us question this assumption about $mainKeyword. Is it truly as it seems, or is it a common misconception? What evidence actually supports this?";
        break;
      case PersonaTone.calm:
      default:
        reasoning = "There is no need to rush. When looking at $mainKeyword, step by step, clarity emerges from a place of peace and steady observation.";
        break;
    }

    // 4. Style Adjustment (Sentence Count)
    List<String> sentences = reasoning.split('. ');
    int targetCount;
    switch (persona.speakingStyle) {
      case SpeakingStyle.short:
        targetCount = 2;
        break;
      case SpeakingStyle.elaborate:
        targetCount = 6;
        break;
      case SpeakingStyle.balanced:
      default:
        targetCount = 4;
        break;
    }

    // Expand reasoning based on intent and keywords if needed to reach targetCount
    List<String> finalSentences = [...sentences];
    if (isQuestion) finalSentences.add("Your inquiry reveals a deeper curiosity.");
    if (isMotivational) finalSentences.add("The path to excellence is paved with such reflections.");
    if (isArgument) finalSentences.add("Conflict in ideas is the forge of true understanding.");
    
    // Add generic expansion if still short
    final genericExpansions = [
      "We must look deeper into the nuances.",
      "The complexity of the situation demands our full attention.",
      "Consider how this affects the broader context.",
      "It is essential to remain objective throughout this process.",
      "Every detail contributes to the final realization."
    ];
    
    int i = 0;
    while (finalSentences.length < targetCount && i < genericExpansions.length) {
      finalSentences.add(genericExpansions[i]);
      i++;
    }

    // Trim if too long
    if (finalSentences.length > targetCount) {
      finalSentences = finalSentences.sublist(0, targetCount);
    }

    final response = finalSentences.join('. ').replaceAll('..', '.');
    return "${persona.prefixStyle} $response";
  }

  List<String> _extractKeywords(String text) {
    const stopWords = {
      'the', 'is', 'at', 'which', 'on', 'and', 'a', 'an', 'in', 'to', 'for', 'with', 
      'of', 'from', 'it', 'was', 'were', 'had', 'has', 'have', 'be', 'been',
      'this', 'that', 'these', 'those', 'as', 'but', 'by', 'if', 'or', 'so', 'than',
      'me', 'my', 'your', 'you', 'what', 'tell', 'about', 'why', 'how', 'explain'
    };

    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));

    final filtered = words
        .where((w) => w.length >= 5 && !stopWords.contains(w))
        .toList();

    if (filtered.isNotEmpty) return filtered;

    return words
        .where((w) => w.length >= 4 && !stopWords.contains(w))
        .toList();
  }

  // ─── Podcast Script ──────────────────────────────────────────────────────────

  @override
  Future<String> generatePodcastScript({
    required String text,
    required String format,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final summary = await generateSummary(text);

    switch (format) {
      case 'solo':
        return '🎙️ **Solo Podcast Script**\n\n'
            'HOST: Welcome to today\'s episode. We\'re exploring a fascinating topic.\n\n'
            '$summary\n\n'
            'HOST: That\'s all for today\'s episode. Thanks for listening!';
      case 'two-host':
        return '🎙️ **Two-Host Podcast Script**\n\n'
            'HOST A: Welcome back, listeners!\n'
            'HOST B: Great to be here. Today we\'re diving into something really interesting.\n\n'
            'HOST A: $summary\n\n'
            'HOST B: Fascinating! What do you make of that?\n'
            'HOST A: I think the key takeaway is the depth of this topic.\n'
            'HOST B: Absolutely. Thanks everyone for tuning in!';
      default:
        return '🎙️ **Podcast Script**\n\n$summary';
    }
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────────

  List<String> _getGenericResponses(String personaName) => [
        'That is a fascinating perspective on this matter.',
        'I must respectfully disagree with that assertion.',
        'The evidence suggests a more nuanced interpretation.',
        'History has shown this to be a complex issue indeed.',
      ];
}

/// Simple pseudo-random generator (no dart:math needed for basic use).
class _PseudoRandom {
  int _seed;
  _PseudoRandom(this._seed);
  int next() {
    _seed = (_seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return _seed & 0xFF;
  }
}
