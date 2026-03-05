/// Utility to split large text into chunks for TTS processing.
/// Splits at paragraph/sentence boundaries. Max 3000 chars per chunk.
/// Fully local — no external dependencies.
class TextChunker {
  TextChunker._();

  static const int defaultMaxChunkSize = 3000;

  /// Splits [text] into chunks of at most [maxChunkSize] characters.
  /// Prefers splitting at double-newlines (paragraphs), then single newlines,
  /// then sentence endings (. ! ?), then spaces.
  static List<String> chunk(String text,
      {int maxChunkSize = defaultMaxChunkSize}) {
    if (text.isEmpty) return [];
    if (text.length <= maxChunkSize) return [text.trim()];

    final chunks = <String>[];
    String remaining = text.trim();

    while (remaining.isNotEmpty) {
      if (remaining.length <= maxChunkSize) {
        chunks.add(remaining.trim());
        break;
      }

      int splitIndex = _findBestSplitPoint(remaining, maxChunkSize);
      final chunk = remaining.substring(0, splitIndex).trim();
      if (chunk.isNotEmpty) chunks.add(chunk);
      remaining = remaining.substring(splitIndex).trim();
    }

    return chunks.where((c) => c.isNotEmpty).toList();
  }

  static int _findBestSplitPoint(String text, int maxSize) {
    // 1. Try paragraph break (\n\n)
    final paraIdx = text.lastIndexOf('\n\n', maxSize);
    if (paraIdx > maxSize * 0.5) return paraIdx;

    // 2. Try single newline
    final newlineIdx = text.lastIndexOf('\n', maxSize);
    if (newlineIdx > maxSize * 0.5) return newlineIdx;

    // 3. Try sentence ending (. or ! or ?)
    for (final punct in ['. ', '! ', '? ']) {
      final idx = text.lastIndexOf(punct, maxSize);
      if (idx > maxSize * 0.5) return idx + 1;
    }

    // 4. Try word boundary (space)
    final spaceIdx = text.lastIndexOf(' ', maxSize);
    if (spaceIdx > 0) return spaceIdx;

    // 5. Hard cut
    return maxSize;
  }

  /// Estimates word count for a chunk.
  static int estimateWordCount(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  /// Estimates reading time in seconds (avg 150 wpm TTS speed).
  static double estimateAudioDurationSeconds(String text) =>
      estimateWordCount(text) / 150 * 60;
}
