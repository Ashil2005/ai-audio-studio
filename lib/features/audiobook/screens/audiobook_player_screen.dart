import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/audio_utils.dart';
import '../../../core/utils/text_summarizer.dart';
import '../../../services/tts_service_base.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/library_provider.dart';
import '../../../models/library_item.dart';
import '../../../core/utils/logger.dart';

class AudiobookPlayerScreen extends ConsumerStatefulWidget {
  final String title;
  final String text;

  const AudiobookPlayerScreen({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  ConsumerState<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends ConsumerState<AudiobookPlayerScreen> {
  double _playbackSpeed = 1.0;
  bool _isSummarizing = false;

  void _showSummaryDialog(BuildContext context) async {
    setState(() => _isSummarizing = true);
    
    try {
      AppLogger.log("Generating summary for: ${widget.title}");
      final summary = await TextSummarizer.summarizeAsync(widget.text);
      
      // Save to Library
      await ref.read(libraryProvider.notifier).addItem(
        title: 'Summary: ${widget.title}',
        type: LibraryItemType.summary,
        content: summary,
        metadata: {'source': widget.title},
      );

      if (mounted) {
        setState(() => _isSummarizing = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('AI Summary Generated'),
            content: SingleChildScrollView(child: Text(summary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
        );
      }
    } catch (e) {
      AppLogger.error("Summary generation failed", e);
      if (mounted) {
        setState(() => _isSummarizing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ttsService = ref.watch(ttsServiceProvider);

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          title: const Text('Playing Audiobook'),
          actions: [
            if (_isSummarizing)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAlbumArt(),
                  const SizedBox(height: 48),
                  _buildMetadata(),
                  const SizedBox(height: 32),
                  StreamBuilder<PlaybackState>(
                    stream: ttsService.playbackState,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      final isPlaying = state?.playing ?? false;
                      final currentIndex = ttsService.currentIndex;
                      final totalChunks = ttsService.totalChunks;
                      final progress = totalChunks > 0 ? currentIndex / totalChunks : 0.0;

                      return Column(
                        children: [
                          _buildProgressBar(progress, currentIndex, totalChunks),
                          const SizedBox(height: 24),
                          _buildCurrentSentence(ttsService.currentText),
                          const SizedBox(height: 48),
                          _buildControls(isPlaying, ttsService),
                          const SizedBox(height: 48),
                          _buildSpeedControl(ttsService),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Icon(Icons.menu_book_rounded, size: 100, color: Colors.white),
    );
  }

  Widget _buildMetadata() {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        const Text(
          'Local AI Voice',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, int current, int total) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.glassBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Segment $current', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Text('$total segments', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentSentence(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassMorphism(),
      child: Text(
        text.isNotEmpty ? text : "Loading...",
        style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildControls(bool isPlaying, TtsServiceBase service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10_rounded, size: 36),
          onPressed: () {}, // Not yet implemented for MVP
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: isPlaying ? service.pause : service.resume,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 32),
        IconButton(
          icon: const Icon(Icons.forward_10_rounded, size: 36),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSpeedControl(TtsServiceBase service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.speed_rounded, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        SizedBox(
          width: 200,
          child: Slider(
            value: _playbackSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: AudioUtils.speedLabel(_playbackSpeed),
            onChanged: (value) {
              setState(() => _playbackSpeed = value);
              service.setSpeed(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Text(
          AudioUtils.speedLabel(_playbackSpeed),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
