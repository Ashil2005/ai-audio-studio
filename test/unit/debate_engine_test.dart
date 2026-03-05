import 'package:audio_studio/features/debate/debate_engine.dart';
import 'package:audio_studio/models/persona_model.dart';
import 'package:audio_studio/services/ai_service_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AiServiceLocal aiService;
  late DebateEngine debateEngine;

  setUp(() {
    aiService = AiServiceLocal();
    debateEngine = DebateEngine(aiService);
  });

  group('DebateEngine Tests', () {
    const persona1 = PersonaModel(
      id: 'p1',
      name: 'Persona One',
      description: 'Test persona',
      tone: PersonaTone.philosophical,
      speakingStyle: SpeakingStyle.short,
      prefixStyle: 'P1:',
    );

    const persona2 = PersonaModel(
      id: 'p2',
      name: 'Persona Two',
      description: 'Other test persona',
      tone: PersonaTone.analytical,
      speakingStyle: SpeakingStyle.short,
      prefixStyle: 'P2:',
    );

    test('Two personas, 2 rounds should produce correct message count', () async {
      final messages = await debateEngine.generateDebate(
        personas: [persona1, persona2],
        topic: 'Is technology good?',
        rounds: 2,
      );

      // 1 opening + (2 personas * 2 rounds) + 1 closing = 1 + 4 + 1 = 6
      expect(messages.length, 6);
      expect(messages.first.speakerName, 'Moderator');
      expect(messages.last.speakerName, 'Moderator');
      expect(messages[1].speakerId, 'p1');
      expect(messages[2].speakerId, 'p2');
    });

    test('Should throw ArgumentError if less than 2 personas', () {
      expect(
        () => debateEngine.generateDebate(personas: [persona1], topic: 'Test'),
        throwsArgumentError,
      );
    });

    test('Should return empty list for empty topic', () async {
      final messages = await debateEngine.generateDebate(
        personas: [persona1, persona2],
        topic: '',
      );
      expect(messages, isEmpty);
    });

    test('Debate should be deterministic', () async {
      const topic = 'Deterministic test topic';
      
      final result1 = await debateEngine.generateDebate(
        personas: [persona1, persona2],
        topic: topic,
        rounds: 1,
      );

      final result2 = await debateEngine.generateDebate(
        personas: [persona1, persona2],
        topic: topic,
        rounds: 1,
      );

      expect(result1.length, result2.length);
      for (int i = 0; i < result1.length; i++) {
        expect(result1[i].content, result2[i].content);
        expect(result1[i].speakerId, result2[i].speakerId);
      }
    });

    test('Three personas, 1 round should follow correct order', () async {
      const persona3 = PersonaModel(
        id: 'p3',
        name: 'Persona Three',
        description: 'Third persona',
        tone: PersonaTone.calm,
        speakingStyle: SpeakingStyle.short,
        prefixStyle: 'P3:',
      );

      final messages = await debateEngine.generateDebate(
        personas: [persona1, persona2, persona3],
        topic: 'Triple debate',
        rounds: 1,
      );

      // 1 opening + 3 persona turns + 1 closing = 5
      expect(messages.length, 5);
      expect(messages[1].speakerId, 'p1');
      expect(messages[2].speakerId, 'p2');
      expect(messages[3].speakerId, 'p3');
    });
  });
}
