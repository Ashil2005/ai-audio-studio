import 'package:audio_studio/core/utils/text_summarizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextSummarizer Tests', () {
    test('Should return empty string for empty input', () {
      expect(TextSummarizer.summarize(""), "");
    });

    test('Should return original text for short input (< 500 chars)', () {
      const shortText = "This is a short text. It should not be summarized because it is already brief. "
          "The summarizer only kicks in after 500 characters to ensure there is enough context.";
      expect(TextSummarizer.summarize(shortText), shortText);
    });

    test('Should summarize a large 100k character text', () {
      final buffer = StringBuffer();
      for (int i = 0; i < 1000; i++) {
        buffer.write("Sentence number $i discusses important topics concerning technology and ethics. ");
        buffer.write("We must consider how AI impacts our daily lives and the future of work. ");
      }
      final largeText = buffer.toString();
      expect(largeText.length, greaterThan(100000));

      final summary = TextSummarizer.summarize(largeText);

      expect(summary.length, lessThan(largeText.length));
      expect(summary.isNotEmpty, true);
      // Verify minSentences (default 3)
      final sentenceCount = summary.split(RegExp(r'(?<=[.!?])\s+')).length;
      expect(sentenceCount, greaterThanOrEqualTo(3));
    });

    test('Should give higher priority to keyword-heavy sentences', () {
      final text = "This is a generic sentence with no meaning. " * 20 +
          "Artificial Intelligence and Machine Learning are the most revolutionary technologies of our time. " +
          "The impact of Artificial Intelligence on Machine Learning development is massive. " +
          "AI and ML will change the world forever. " +
          "This is another generic sentence that probably should be ignored. " * 20;

      final summary = TextSummarizer.summarize(text, compressionRatio: 0.1);

      // The summary should contain the AI/ML keywords
      expect(summary.toLowerCase().contains("artificial intelligence"), true);
      expect(summary.toLowerCase().contains("machine learning"), true);
      expect(summary.split(RegExp(r'(?<=[.!?])\s+')).length, inInclusiveRange(3, 10));
    });

    test('Should preserve sentence order of the selected sentences', () {
      const text = "First important sentence. "
          "Second filler sentence that is long enough to meet length requirement but less important. "
          "Third important sentence with keywords keywords keywords. "
          "Fourth Filler sentence of moderate length. "
          "Fifth important sentence explaining everything.";
          
      // Pad to 500 chars to trigger summarizer
      final paddedText = text + " Extra padding text " * 30;

      final summary = TextSummarizer.summarize(paddedText);
      
      final sentences = summary.split(RegExp(r'(?<=[.!?])\s+'));
      
      // Check order via simple string contains in original sequence
      int lastIndex = -1;
      for (final s in sentences) {
        final currentIndex = paddedText.indexOf(s);
        expect(currentIndex, greaterThan(lastIndex));
        lastIndex = currentIndex;
      }
    });

    test('Should handle mixed punctuation and formatting', () {
      const text = "Is this a question? This is a statement! Another one... And one more. " +
          "This part of the document has a lot of extra spaces and \n newlines \r\n that should be handled.";
      final paddedText = text + " Relevant keywords found here for frequency analysis. " * 40;

      final summary = TextSummarizer.summarize(paddedText);
      expect(summary.contains("?"), true);
      expect(summary.contains("!"), true);
      expect(summary.contains("\n"), false); // Normalized in preprocessing
    });
  });
}
