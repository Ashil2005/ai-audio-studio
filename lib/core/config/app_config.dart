// App-wide configuration constants
// No secrets here — all API keys go server-side when backend is added
enum AiMode { local, remote }

class AppConfig {
  AppConfig._();

  static const String appName = 'PocketAudio Studio';
  static const String appVersion = '1.0.0';

  // Feature flags — flip to true when upgrading
  static bool enableRemoteAI = false;
  static AiMode aiMode = AiMode.local;
  
  static const bool isPremiumEnabled = false;
  static const bool isLlmEnabled = false;
  static const bool isCloudTtsEnabled = false;
  static const bool isStripeEnabled = false;

  // Free-tier limits (enforced locally for UX only; real enforcement goes server-side)
  static const int freeMonthlyAudioMinutes = 30;
  static const int freeMonthlyDebates = 5;

  // AI abstraction — swap value when upgrading to real LLM
  static const String aiProvider = 'local'; // 'openai' | 'gemini' | 'local'
  static const String ttsProvider = 'flutter_tts'; // 'elevenlabs' | 'google' | 'flutter_tts'
  static const String sttProvider = 'speech_to_text'; // 'deepgram' | 'google' | 'speech_to_text'

  // Firestore collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String podcastsCollection = 'podcasts';
  static const String debatesCollection = 'debates';
  static const String personasCollection = 'personas';
  static const String summariesCollection = 'summaries';
}
