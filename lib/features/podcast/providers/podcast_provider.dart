import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/podcast_model.dart';
import '../../../providers/service_providers.dart';
import '../services/podcast_service.dart';

// Podcast service provider
final podcastServiceProvider = Provider<PodcastService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return PodcastService(aiService);
});

// Podcast generation state
enum PodcastGenerationStatus { idle, generating, success, error }

class PodcastGenerationState {
  final PodcastGenerationStatus status;
  final PodcastScript? script;
  final String? error;

  const PodcastGenerationState({
    required this.status,
    this.script,
    this.error,
  });

  PodcastGenerationState copyWith({
    PodcastGenerationStatus? status,
    PodcastScript? script,
    String? error,
  }) {
    return PodcastGenerationState(
      status: status ?? this.status,
      script: script ?? this.script,
      error: error ?? this.error,
    );
  }
}

// Podcast generation state notifier
class PodcastGenerationNotifier extends StateNotifier<PodcastGenerationState> {
  final PodcastService _podcastService;

  PodcastGenerationNotifier(this._podcastService)
      : super(const PodcastGenerationState(status: PodcastGenerationStatus.idle));

  Future<void> generatePodcast({
    required String topic,
    required String format,
    required int durationMinutes,
  }) async {
    print("PODCAST: Starting generation for topic: $topic");
    
    if (topic.trim().isEmpty) {
      print("PODCAST: Error - empty topic");
      state = state.copyWith(
        status: PodcastGenerationStatus.error,
        error: 'Please enter a topic',
      );
      return;
    }

    print("PODCAST: Setting state to generating");
    state = state.copyWith(
      status: PodcastGenerationStatus.generating,
      error: null,
    );

    try {
      print("PODCAST: Calling podcast service");
      final script = await _podcastService.generatePodcast(
        topic: topic,
        format: format,
        durationMinutes: durationMinutes,
      );

      print("PODCAST: Generation successful, script title: ${script.title}");
      print("PODCAST: Setting state to success");
      state = state.copyWith(
        status: PodcastGenerationStatus.success,
        script: script,
      );
      print("PODCAST: State updated to success, current status: ${state.status}");
    } catch (e) {
      print("PODCAST: Generation failed with error: $e");
      state = state.copyWith(
        status: PodcastGenerationStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const PodcastGenerationState(status: PodcastGenerationStatus.idle);
  }
}

// Podcast generation provider
final podcastGenerationProvider = StateNotifierProvider<PodcastGenerationNotifier, PodcastGenerationState>((ref) {
  final podcastService = ref.watch(podcastServiceProvider);
  return PodcastGenerationNotifier(podcastService);
});