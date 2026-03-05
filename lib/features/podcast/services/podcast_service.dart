import '../../../models/podcast_model.dart';
import '../../../services/ai_service.dart';

class PodcastService {
  final AiService _aiService;

  PodcastService(this._aiService);

  Future<PodcastScript> generatePodcast({
    required String topic,
    required String format,
    required int durationMinutes,
  }) async {
    // Generate the podcast script using AI service
    final scriptText = await _aiService.generatePodcastScript(
      text: topic,
      format: format,
    );

    // Parse the generated script into structured format
    final parsedScript = _parseScript(scriptText, topic, format, durationMinutes);
    
    return parsedScript;
  }

  PodcastScript _parseScript(String scriptText, String topic, String format, int duration) {
    final lines = scriptText.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    // Extract title
    String title = 'Podcast: $topic';
    if (lines.isNotEmpty && lines.first.toLowerCase().contains('title')) {
      title = lines.first.replaceAll(RegExp(r'^title:?\s*', caseSensitive: false), '');
      lines.removeAt(0);
    }

    // Find intro section
    String intro = '';
    List<String> segments = [];
    String outro = '';

    int currentSection = 0; // 0: intro, 1: segments, 2: outro
    StringBuffer currentBuffer = StringBuffer();

    for (String line in lines) {
      final lowerLine = line.toLowerCase();
      
      if (lowerLine.contains('intro') || lowerLine.contains('opening')) {
        if (currentBuffer.isNotEmpty && currentSection == 0) {
          intro = currentBuffer.toString().trim();
        }
        currentSection = 0;
        currentBuffer.clear();
        continue;
      } else if (lowerLine.contains('segment') || lowerLine.contains('part')) {
        if (currentBuffer.isNotEmpty) {
          if (currentSection == 0) {
            intro = currentBuffer.toString().trim();
          } else if (currentSection == 1) {
            segments.add(currentBuffer.toString().trim());
          }
        }
        currentSection = 1;
        currentBuffer.clear();
        continue;
      } else if (lowerLine.contains('outro') || lowerLine.contains('closing') || lowerLine.contains('conclusion')) {
        if (currentBuffer.isNotEmpty) {
          if (currentSection == 0) {
            intro = currentBuffer.toString().trim();
          } else if (currentSection == 1) {
            segments.add(currentBuffer.toString().trim());
          }
        }
        currentSection = 2;
        currentBuffer.clear();
        continue;
      }

      currentBuffer.writeln(line);
    }

    // Handle remaining content
    if (currentBuffer.isNotEmpty) {
      final content = currentBuffer.toString().trim();
      if (currentSection == 0) {
        intro = content;
      } else if (currentSection == 1) {
        segments.add(content);
      } else if (currentSection == 2) {
        outro = content;
      }
    }

    // Fallback if parsing didn't work well
    if (intro.isEmpty && segments.isEmpty && outro.isEmpty) {
      // Split the script into roughly equal parts
      final allText = scriptText.trim();
      final words = allText.split(' ');
      final wordsPerSection = words.length ~/ 4;
      
      intro = words.take(wordsPerSection).join(' ');
      segments = [
        words.skip(wordsPerSection).take(wordsPerSection).join(' '),
        words.skip(wordsPerSection * 2).take(wordsPerSection).join(' '),
      ];
      outro = words.skip(wordsPerSection * 3).join(' ');
    }

    return PodcastScript(
      title: title,
      intro: intro,
      segments: segments,
      outro: outro,
      format: format,
      estimatedDuration: duration,
    );
  }
}