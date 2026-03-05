import 'ai_service.dart';
import '../models/persona_model.dart';

/// Remote AI implementation stub for future LLM integration.
class AiServiceRemote implements AiService {
  @override
  Future<String> generateSummary(String text) async {
    return "[Remote AI Stub] This would call a real LLM for summarization in production.";
  }

  @override
  Future<List<Map<String, String>>> generateDebate({
    required List<String> personas,
    required String topic,
    required String style,
    int rounds = 3,
  }) async {
    return [
      {
        'speaker': 'Moderator',
        'text': '[Remote AI Stub] Starting debate on $topic with $style style.'
      },
      {
        'speaker': personas.first,
        'text': '[Remote AI Stub] This is a remote LLM response for ${personas.first}.'
      },
    ];
  }

  @override
  Future<String> generatePersonaResponse({
    required PersonaModel persona,
    required String userInput,
  }) async {
    return "[Remote AI Stub] Response for ${persona.name}: This would be a real LLM output.";
  }

  @override
  Future<String> generatePodcastScript({
    required String text,
    required String format,
  }) async {
    return "[Remote AI Stub] Podcast script for the provided text in $format format.";
  }
}
