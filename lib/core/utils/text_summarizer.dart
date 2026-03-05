import 'package:flutter/foundation.dart';
import 'dart:math';

/// A pure Dart utility to perform extractive summarization using a word-frequency 
/// scoring algorithm. Zero dependencies, 100% local.
class TextSummarizer {
  TextSummarizer._();

  /// Stopwords list to filter out common words from frequency analysis.
  static const Set<String> _stopWords = {
    'the', 'is', 'at', 'which', 'on', 'and', 'a', 'an', 'in', 'to', 'for', 'with', 
    'of', 'from', 'it', 'was', 'were', 'had', 'has', 'have', 'be', 'been', 'being',
    'this', 'that', 'these', 'those', 'as', 'but', 'by', 'if', 'or', 'so', 'than',
    'there', 'when', 'where', 'who', 'how', 'why', 'what', 'can', 'should',
    'will', 'would', 'not', 'no', 'yes', 'we', 'you', 'he', 'she', 'they', 'our',
    'us', 'me', 'my', 'his', 'her', 'their', 'them', 'into', 'unto', 'up', 'down',
    'out', 'about', 'above', 'below', 'over', 'under', 'again', 'further', 'then',
    'once', 'here', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other',
    'some', 'such', 'nor', 'only', 'own', 'same', 'too', 'very', 's', 't', 'don',
    'shouldn', 'now', 'd', 'll', 'm', 'o', 're', 've', 'y', 'ain', 'aren', 'couldn',
    'didn', 'doesn', 'hadn', 'hasn', 'haven', 'isn', 'ma', 'mightn', 'mustn',
    'needn', 'shan', 'wasn', 'weren', 'won', 'wouldn'
  };

  /// Summarizes the given [text] based on word frequency scoring.
  static String summarize(
    String text, {
    double compressionRatio = 0.2,
    int minSentences = 5,
  }) {
    if (text.isEmpty) return "";
    if (text.length < 500) return text;

    final cleanText = text.replaceAll(RegExp(r'\r\n|\r|\n'), ' ').trim();
    final sentences = cleanText
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    if (sentences.isEmpty) return "";
    
    final List<MapEntry<int, String>> indexedSentences = [];
    final Set<String> seen = {};
    for (int i = 0; i < sentences.length; i++) {
       final s = sentences[i];
       if (seen.add(s)) {
         indexedSentences.add(MapEntry(i, s));
       }
    }

    if (indexedSentences.isEmpty) return sentences.take(2).join(' ');
    if (indexedSentences.length <= minSentences) {
      return indexedSentences.map((e) => e.value).join(' ');
    }

    final Map<String, int> frequencies = {};
    for (final entry in indexedSentences) {
      final words = _extractWords(entry.value);
      for (final word in words) {
        frequencies[word] = (frequencies[word] ?? 0) + 1;
      }
    }

    if (frequencies.isEmpty) {
      return indexedSentences.take(minSentences).map((e) => e.value).join(' ');
    }

    final Map<int, double> sentenceScores = {};
    for (final entry in indexedSentences) {
      final words = _extractWords(entry.value);
      double score = 0;
      for (final word in words) {
        if (frequencies.containsKey(word)) {
          score += frequencies[word]! * word.length;
        }
      }
      sentenceScores[entry.key] = score;
    }

    int targetCount = (indexedSentences.length * compressionRatio).round();
    targetCount = max(minSentences, targetCount);
    targetCount = min(targetCount, indexedSentences.length);

    final listToSort = sentenceScores.entries.toList();
    listToSort.sort((a, b) => b.value.compareTo(a.value));
    
    final topEntries = listToSort.take(targetCount).toList();
    // Restore original index order
    topEntries.sort((a, b) => a.key.compareTo(b.key));

    return topEntries.map((e) => indexedSentences.firstWhere((isnt) => isnt.key == e.key).value).join(' ');
  }

  static List<String> _extractWords(String sentence) {
    return sentence
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3 && !_stopWords.contains(w))
        .toList();
  }

  static Future<String> summarizeAsync(String text) async {
    return await compute((t) => summarize(t), text);
  }
}
