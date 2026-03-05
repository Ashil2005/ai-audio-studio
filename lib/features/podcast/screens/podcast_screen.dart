import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../models/podcast_model.dart';
import '../providers/podcast_provider.dart';

class PodcastScreen extends ConsumerStatefulWidget {
  const PodcastScreen({super.key});

  @override
  ConsumerState<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends ConsumerState<PodcastScreen> {
  final _topicController = TextEditingController();
  String _selectedFormat = 'solo';
  int _selectedDuration = 10;

  final List<String> _formats = ['solo', 'two-host', 'debate', 'lecture'];
  final List<int> _durations = [5, 10, 20];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastState = ref.watch(podcastGenerationProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Generate Podcast'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.studio);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic Input
                _buildTopicInput(),
                const SizedBox(height: 24),

                // Format Selection
                _buildFormatSelection(),
                const SizedBox(height: 24),

                // Duration Selection
                _buildDurationSelection(),
                const SizedBox(height: 32),

                // Generate Button
                _buildGenerateButton(podcastState),
                const SizedBox(height: 24),

                // Content Area
                _buildContentArea(podcastState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podcast Topic',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topicController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter the topic you want to create a podcast about...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                filled: true,
                fillColor: AppTheme.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podcast Format',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _formats.map((format) {
                final isSelected = format == _selectedFormat;
                return ChoiceChip(
                  label: Text(
                    format.replaceAll('-', ' ').toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFormat = format;
                      });
                    }
                  },
                  backgroundColor: AppTheme.background,
                  selectedColor: AppTheme.primary,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.glassBorder,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _durations.map((duration) {
                final isSelected = duration == _selectedDuration;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '$duration min',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDuration = duration;
                        });
                      }
                    },
                    backgroundColor: AppTheme.background,
                    selectedColor: AppTheme.primary,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.glassBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(PodcastGenerationState state) {
    final isGenerating = state.status == PodcastGenerationStatus.generating;
    
    return ElevatedButton(
      onPressed: isGenerating ? null : _generatePodcast,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isGenerating
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Generating...'),
              ],
            )
          : const Text(
              'Generate Podcast',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildContentArea(PodcastGenerationState state) {
    print("PODCAST UI: Building content area with status: ${state.status}");
    print("PODCAST UI: Script is null: ${state.script == null}");
    
    switch (state.status) {
      case PodcastGenerationStatus.idle:
        print("PODCAST UI: Rendering idle state");
        return _buildIdleState();
      case PodcastGenerationStatus.generating:
        print("PODCAST UI: Rendering loading state");
        return _buildLoadingState();
      case PodcastGenerationStatus.success:
        print("PODCAST UI: Rendering success state with script: ${state.script?.title}");
        return _buildSuccessState(state.script!);
      case PodcastGenerationStatus.error:
        print("PODCAST UI: Rendering error state: ${state.error}");
        return _buildErrorState(state.error!);
    }
  }

  Widget _buildIdleState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.podcasts_rounded,
              size: 64,
              color: AppTheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Ready to Generate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter a topic and click generate to create your podcast script',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Generating Podcast Script...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(PodcastScript script) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        script.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${script.format.toUpperCase()} • ${script.estimatedDuration} min',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: AppTheme.glassBorder, height: 1),
          
          // Script Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScriptSection('Introduction', script.intro),
                const SizedBox(height: 16),
                
                for (int i = 0; i < script.segments.length; i++) ...[
                  _buildScriptSection('Segment ${i + 1}', script.segments[i]),
                  const SizedBox(height: 16),
                ],
                
                _buildScriptSection('Closing', script.outro),
              ],
            ),
          ),
          
          const Divider(color: AppTheme.glassBorder, height: 1),
          
          // Convert to Audio Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => _convertToAudio(script),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded),
                  SizedBox(width: 8),
                  Text('Convert to Audio'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Generation Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(podcastGenerationProvider.notifier).reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generatePodcast() {
    ref.read(podcastGenerationProvider.notifier).generatePodcast(
          topic: _topicController.text,
          format: _selectedFormat,
          durationMinutes: _selectedDuration,
        );
  }

  void _convertToAudio(PodcastScript script) {
    // Navigate to audiobook player with the podcast script
    context.go(AppRoutes.audiobook, extra: {
      'title': script.title,
      'text': script.fullScript,
    });
  }
}