import 'package:audio_studio/models/persona_model.dart';
import 'package:audio_studio/services/ai_service_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AiServiceLocal aiService;

  setUp(() {
    aiService = AiServiceLocal();
  });

  group('Persona Engine Tests', () {
    const philosophicalPersona = PersonaModel(
      id: 'marcus',
      name: 'Marcus Aurelius',
      description: 'Stoic philosopher',
      tone: PersonaTone.philosophical,
      speakingStyle: SpeakingStyle.balanced,
      prefixStyle: '🧘 Marcus:',
    );

    const motivationalPersona = PersonaModel(
      id: 'tony',
      name: 'Motivational Coach',
      description: 'High energy coach',
      tone: PersonaTone.motivational,
      speakingStyle: SpeakingStyle.short,
      prefixStyle: '🔥 Coach:',
    );

    const analyticalPersona = PersonaModel(
      id: 'spock',
      name: 'Spock',
      description: 'Logical analytical mind',
      tone: PersonaTone.analytical,
      speakingStyle: SpeakingStyle.elaborate,
      prefixStyle: '🖖 Spock:',
    );

    test('Should handle empty input gracefully', () async {
      final response = await aiService.generatePersonaResponse(
        persona: philosophicalPersona,
        userInput: "",
      );
      expect(response, contains("Please provide something to reflect upon."));
      expect(response, startsWith("🧘 Marcus:"));
    });

    test('Philosophical persona should have correct tone and keywords', () async {
      final response = await aiService.generatePersonaResponse(
        persona: philosophicalPersona,
        userInput: "What is the meaning of life and death?",
      );
      expect(response, contains("meaning"));
      expect(response, contains("philosophical"));
      expect(response, contains("purpose"));
    });

    test('Motivational persona should be short and high energy', () async {
      final response = await aiService.generatePersonaResponse(
        persona: motivationalPersona,
        userInput: "I feel tired and lazy today.",
      );
      final sentences = response.split('. ');
      expect(sentences.length, lessThanOrEqualTo(2));
      expect(response, contains("opportunity"));
      expect(response, contains("Coach:"));
    });

    test('Analytical persona should be elaborate', () async {
      final response = await aiService.generatePersonaResponse(
        persona: analyticalPersona,
        userInput: "Tell me about the efficiency of solar energy.",
      );
      final sentences = response.split('. ');
      expect(sentences.length, greaterThanOrEqualTo(5));
      expect(response, contains("logical"));
      expect(response, contains("solar"));
    });

    test('Output should be deterministic (same input produces same output)', () async {
      const input = "Why is the sky blue?";
      
      final response1 = await aiService.generatePersonaResponse(
        persona: philosophicalPersona,
        userInput: input,
      );
      
      final response2 = await aiService.generatePersonaResponse(
        persona: philosophicalPersona,
        userInput: input,
      );
      
      expect(response1, equals(response2));
    });

    test('Intent detection: Question should add specific sentence', () async {
      final response = await aiService.generatePersonaResponse(
        persona: analyticalPersona,
        userInput: "Can you explain this?",
      );
      expect(response, contains("Your inquiry reveals a deeper curiosity."));
    });
  });
}
