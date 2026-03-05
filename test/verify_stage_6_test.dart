import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_studio/core/config/app_config.dart';
import 'package:audio_studio/providers/service_providers.dart';
import 'package:audio_studio/services/ai_service.dart';

void main() {
  test('AI Provider should toggle between local and remote', () async {
    print("--- Testing LOCAL mode (Default) ---");
    {
      final container = ProviderContainer();
      print("AppConfig.enableRemoteAI: ${AppConfig.enableRemoteAI}");
      final aiLocal = container.read(aiServiceProvider);
      final responseLocal = await aiLocal.generateSummary("Hello world");
      print("Response: $responseLocal");
      
      // Should be local summary (📝 **AI Summary**)
      expect(responseLocal.contains("AI Summary"), isTrue);
      container.dispose();
    }

    print("\n--- Testing REMOTE mode (Toggle) ---");
    {
      AppConfig.enableRemoteAI = true;
      AppConfig.aiMode = AiMode.remote;
      
      final container = ProviderContainer();
      print("AppConfig.enableRemoteAI: ${AppConfig.enableRemoteAI}");
      print("AppConfig.aiMode: ${AppConfig.aiMode}");
      
      final aiRemote = container.read(aiServiceProvider);
      final responseRemote = await aiRemote.generateSummary("Hello world");
      print("Response: $responseRemote");

      expect(responseRemote.contains("[Remote AI Stub]"), isTrue);
      
      container.dispose();
    }

    // Reset to default for other tests
    AppConfig.enableRemoteAI = false;
    AppConfig.aiMode = AiMode.local;
  });
}
