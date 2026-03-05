import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/persona_model.dart';
import '../voice_chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../../../providers/library_provider.dart';
import '../../../models/library_item.dart';

class VoiceChatScreen extends ConsumerStatefulWidget {
  final PersonaModel persona;

  const VoiceChatScreen({super.key, required this.persona});

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceChatProvider(widget.persona));
    final controller = ref.read(voiceChatProvider(widget.persona).notifier);

    // Auto-scroll on new messages
    ref.listen(voiceChatProvider(widget.persona), (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.persona.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Session',
            onPressed: () {
              if (state.messages.isEmpty) return;
              final transcript = state.messages.map((m) => "${m.isUser ? 'User' : m.sender}: ${m.text}").join('\n\n');
              ref.read(libraryProvider.notifier).addItem(
                title: 'Chat with ${widget.persona.name}',
                type: LibraryItemType.voiceChat,
                content: transcript,
                metadata: {
                  'personaId': widget.persona.id,
                  'messageCount': state.messages.length,
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session saved to Library')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.clearChat(),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: state.messages[index]);
              },
            ),
          ),

          // Processing Status
          if (state.isProcessing)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.persona.name} is thinking...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

          // Controls Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isListening)
                  Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(10, (index) => 
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                        .scaleY(
                          begin: 0.5,
                          end: 2.0,
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeInOut,
                        )
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                GestureDetector(
                  onTapDown: (_) {
                    HapticFeedback.lightImpact();
                    controller.startListening();
                  },
                  onTapUp: (_) {
                    HapticFeedback.mediumImpact();
                    controller.stopListening();
                  },
                  onTapCancel: () => controller.stopListening(),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: state.isListening 
                            ? [Colors.red, Colors.orange]
                            : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (state.isListening ? Colors.red : Theme.of(context).colorScheme.primary).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      state.isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ).animate(target: state.isListening ? 1 : 0)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  state.isListening ? "Listening..." : "Hold to speak",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.error!,
                      style: TextStyle(color: AppTheme.error, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
