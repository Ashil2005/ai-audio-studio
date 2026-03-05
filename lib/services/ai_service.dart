import '../models/persona_model.dart';

/// Abstract AI service interface.
/// All AI features flow through this interface.
/// Swap implementation class to upgrade from local → real LLM.
abstract class AiService {
  /// Generate a concise summary of [text].
  Future<String> generateSummary(String text);

  /// Generate a debate between [personas] on [topic] with the given [style].
  /// Returns a list of dialogue turns: [{'speaker': '...', 'text': '...'}]
  Future<List<Map<String, String>>> generateDebate({
    required List<String> personas,
    required String topic,
    required String style,
    int rounds = 3,
  });

  /// Generate a response from a persona based on user input.
  Future<String> generatePersonaResponse({
    required PersonaModel persona,
    required String userInput,
  });

  /// Generate a podcast script from [text].
  Future<String> generatePodcastScript({
    required String text,
    required String format, // 'solo' | 'two-host' | 'debate' | 'lecture'
  });
}
