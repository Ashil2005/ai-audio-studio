import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_studio/core/config/app_config.dart';
import 'package:audio_studio/providers/service_providers.dart';
import 'package:audio_studio/services/ai_service.dart';

void main() async {
  print("--- Testing LOCAL mode (Default) ---");
  {
    final container = ProviderContainer();
    print("AppConfig.enableRemoteAI: ${AppConfig.enableRemoteAI}");
    final aiLocal = container.read(aiServiceProvider);
    final responseLocal = await aiLocal.generateSummary("Hello world");
    print("Response: $responseLocal");
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

    if (responseRemote.contains("[Remote AI Stub]")) {
      print("\n✅ SUCCESS: Remote stub verified!");
    } else {
      print("\n❌ FAILURE: Remote stub NOT triggered!");
      // Reset for safety
      AppConfig.enableRemoteAI = false;
      AppConfig.aiMode = AiMode.local;
      throw Exception("Remote toggle failed");
    }
    container.dispose();
  }

  // Reset to default for other tests
  AppConfig.enableRemoteAI = false;
  AppConfig.aiMode = AiMode.local;
  print("\n--- Verification Complete ---");
}
