import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/ai_service.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/library_provider.dart';
import '../../../models/library_item.dart';
import '../../../core/utils/logger.dart';

// Predefined personas for debate
const _predefinedPersonas = [
  ('Socrates', Icons.psychology_rounded, Color(0xFF7C3AED)),
  ('Einstein', Icons.science_rounded, Color(0xFF06B6D4)),
  ('Shakespeare', Icons.theater_comedy_rounded, Color(0xFFEC4899)),
  ('Cleopatra', Icons.stars_rounded, Color(0xFFF59E0B)),
  ('Tesla', Icons.bolt_rounded, Color(0xFF10B981)),
];

const _debateStyles = ['Philosophical', 'Educational', 'Formal', 'Aggressive'];

class DebateScreen extends ConsumerStatefulWidget {
  const DebateScreen({super.key});
  @override
  ConsumerState<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends ConsumerState<DebateScreen> {
  final _topicController = TextEditingController();
  // removed direct AiServiceLocal instantiation

  String? _selectedPersona1;
  String? _selectedPersona2;
  String _selectedStyle = 'Philosophical';
  bool _isGenerating = false;
  List<Map<String, String>> _dialogue = [];
  bool _showResult = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateDebate() async {
    if (_selectedPersona1 == null || _selectedPersona2 == null) {
      _showError('Please select two personas');
      return;
    }
    if (_topicController.text.trim().isEmpty) {
      _showError('Please enter a debate topic');
      return;
    }
    if (_selectedPersona1 == _selectedPersona2) {
      _showError('Please select two different personas');
      return;
    }

    setState(() {
      _isGenerating = true;
      _showResult = false;
      _dialogue = [];
    });

    final aiService = ref.read(aiServiceProvider);
    AppLogger.log("Starting debate: $_selectedPersona1 vs $_selectedPersona2 on topic: ${ _topicController.text.trim()}");
    final result = await aiService.generateDebate(
      personas: [_selectedPersona1!, _selectedPersona2!],
      topic: _topicController.text.trim(),
      style: _selectedStyle.toLowerCase(),
      rounds: 3,
    );
    AppLogger.log("Debate generation complete. Turns: ${result.length}");

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _dialogue = result;
        _showResult = true;
      });

      // [New] Save to Library
      final transcript = result.map((t) => "${t['speaker']}: ${t['text']}").join('\n\n');
      ref.read(libraryProvider.notifier).addItem(
            title: '${_selectedPersona1} vs ${_selectedPersona2}',
            type: LibraryItemType.debate,
            content: transcript,
            metadata: {
              'topic': _topicController.text.trim(),
              'style': _selectedStyle,
              'personas': [_selectedPersona1, _selectedPersona2],
            },
          );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Debate'),
        actions: [
          if (_showResult)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(() {
                _showResult = false;
                _dialogue = [];
              }),
            ),
        ],
      ),
      body: _showResult ? _buildResultView() : _buildSetupView(),
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Personas',
              style: Theme.of(context).textTheme.titleMedium)
              .animate().fadeIn(),
          const SizedBox(height: 4),
          Text('Choose two AI personas to debate',
              style: Theme.of(context).textTheme.bodyMedium)
              .animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Persona grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _predefinedPersonas.length,
            itemBuilder: (context, i) {
              final (name, icon, color) = _predefinedPersonas[i];
              final isP1 = _selectedPersona1 == name;
              final isP2 = _selectedPersona2 == name;
              final isSelected = isP1 || isP2;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isP1) { _selectedPersona1 = null; }
                    else if (isP2) { _selectedPersona2 = null; }
                    else if (_selectedPersona1 == null) { _selectedPersona1 = name; }
                    else if (_selectedPersona2 == null) { _selectedPersona2 = name; }
                    else { _selectedPersona1 = name; }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : AppTheme.cardColor,
                    border: Border.all(
                      color: isSelected ? color : AppTheme.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(isSelected ? 0.3 : 0.1),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isP1)
                        Text('P1', style: TextStyle(fontSize: 10, color: color)),
                      if (isP2)
                        Text('P2', style: TextStyle(fontSize: 10, color: color)),
                    ],
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 28),

          // Selected summary
          if (_selectedPersona1 != null || _selectedPersona2 != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassMorphism(borderRadius: 14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '${_selectedPersona1 ?? '—'} vs ${_selectedPersona2 ?? '—'}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

          Text('Debate Topic', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'e.g. "Is technology beneficial to humanity?"',
              prefixIcon:
                  Icon(Icons.lightbulb_outline, color: AppTheme.textSecondary),
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 24),

          Text('Debate Style', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _debateStyles.map((style) {
              final isActive = style == _selectedStyle;
              return GestureDetector(
                onTap: () => setState(() => _selectedStyle = style),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isActive
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.cardColor,
                    border: Border.all(
                      color: isActive ? AppTheme.primary : AppTheme.glassBorder,
                    ),
                  ),
                  child: Text(
                    style,
                    style: TextStyle(
                      color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateDebate,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_isGenerating ? 'Generating debate...' : 'Start Debate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dialogue.length,
            itemBuilder: (context, i) {
              final turn = _dialogue[i];
              final speaker = turn['speaker'] ?? '';
              final text = turn['text'] ?? '';
              final isModerator = speaker == 'Moderator';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speaker avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isModerator
                            ? AppTheme.secondary.withOpacity(0.2)
                            : AppTheme.primary.withOpacity(0.2),
                      ),
                      child: Icon(
                        isModerator
                            ? Icons.mic_rounded
                            : Icons.person_rounded,
                        color: isModerator ? AppTheme.secondary : AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speaker,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isModerator
                                  ? AppTheme.secondary.withOpacity(0.08)
                                  : AppTheme.glassSurface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppTheme.glassBorder),
                            ),
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: -0.05, end: 0);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _showResult = false;
                _dialogue = [];
              }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('New Debate'),
            ),
          ),
        ),
      ],
    );
  }
}

