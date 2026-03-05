import 'package:audio_studio/core/utils/text_chunker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextChunker Large Text Tests', () {
    test('Should handle a very large text string (100k chars)', () {
      final largeText = 'This is a test sentence. ' * 4000; // ~100k chars
      expect(largeText.length, greaterThan(90000));

      final chunks = TextChunker.chunk(largeText, maxChunkSize: 3000);

      expect(chunks.isNotEmpty, true);
      
      // Each chunk except maybe the last should be close to 3000 but not over
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(3000));
        expect(chunk.isNotEmpty, true);
      }

      // Reconstructed text should be same as original minus whitespace differences
      final reconstructed = chunks.join(' ');
      expect(reconstructed.length, closeTo(largeText.length, 10000));
    });

    test('Should split at sentence boundaries preferentially', () {
      const text = 'Sentence one. Sentence two? Sentence three! Sentence four.';
      final chunks = TextChunker.chunk(text, maxChunkSize: 20);

      // It should split into multiple chunks
      expect(chunks.length, greaterThan(1));
      
      for (final chunk in chunks) {
        // Each chunk should end with a punctuation mark in this specific case
        expect(RegExp(r'[.!?]$').hasMatch(chunk), true);
      }
    });

    test('Should handle text with no punctuation by hard cutting', () {
      final longWord = 'A' * 100;
      final chunks = TextChunker.chunk(longWord, maxChunkSize: 10);
      
      expect(chunks.length, 10);
      for (final chunk in chunks) {
        expect(chunk.length, 10);
      }
    });
  });
}
