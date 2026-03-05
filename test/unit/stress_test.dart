import 'package:flutter_test/flutter_test.dart';
import 'package:audio_studio/core/utils/text_summarizer.dart';
import 'package:audio_studio/features/debate/debate_engine.dart';
import 'package:audio_studio/models/persona_model.dart';
import 'package:audio_studio/models/library_item.dart';
import 'package:audio_studio/services/ai_service_local.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Stage 5 Stress Tests', () {
    
    test('500,000 character summarization stress test', () async {
      // Create a massive string
      final sb = StringBuffer();
      final baseText = "The quick brown fox jumps over the lazy dog. ";
      for (int i = 0; i < 11000; i++) { // ~500k chars
        sb.write(baseText);
      }
      final hugeText = sb.toString();
      
      final startTime = DateTime.now();
      // Using direct summarize since summarizeAsync needs a flutter environment (compute)
      // but we can verify the core algorithm's speed.
      final summary = TextSummarizer.summarize(hugeText);
      final duration = DateTime.now().difference(startTime);
      
      print("500k char summary duration: ${duration.inMilliseconds}ms");
      expect(summary.isNotEmpty, true);
      expect(duration.inSeconds < 5, true); // Should be fast enough
    });

    test('20 debate rounds stress test', () async {
      final aiService = AiServiceLocal();
      final engine = DebateEngine(aiService);
      final persona1 = PersonaModel(
        id: '1', name: 'A', description: '', tone: PersonaTone.philosophical, 
        speakingStyle: SpeakingStyle.balanced, prefixStyle: 'A:'
      );
      final persona2 = PersonaModel(
        id: '2', name: 'B', description: '', tone: PersonaTone.skeptical, 
        speakingStyle: SpeakingStyle.short, prefixStyle: 'B:'
      );

      final startTime = DateTime.now();
      final results = await engine.generateDebate(
        topic: "Stress Testing AI",
        personas: [persona1, persona2],
        rounds: 20,
      );
      final duration = DateTime.now().difference(startTime);

      print("20 rounds debate duration: ${duration.inMilliseconds}ms");
      expect(results.length, 20);
    });

    test('100 library items persistence simulation', () {
      final items = <LibraryItem>[];
      final uuid = const Uuid();
      
      for (int i = 0; i < 100; i++) {
        items.add(LibraryItem(
          id: uuid.v4(),
          title: "Item $i",
          type: LibraryItemType.summary,
          content: "Content $i",
          createdAt: DateTime.now(),
        ));
      }

      expect(items.length, 100);
      expect(items[99].title, "Item 99");
    });
  });
}
