import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pdf_chunked_extractor.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/library_provider.dart';
import '../../../models/library_item.dart';

class PdfUploadScreen extends ConsumerStatefulWidget {
  const PdfUploadScreen({super.key});

  @override
  ConsumerState<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends ConsumerState<PdfUploadScreen> {
  bool _isExtracting = false;
  String? _extractedText;
  String? _fileName;
  String? _filePath;
  int _totalPages = 0;
  int _currentPage = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path;
        _extractedText = null;
      });
      _extractText();
    }
  }

  Future<void> _extractText() async {
    if (_filePath == null) return;

    setState(() {
      _isExtracting = true;
      _currentPage = 0;
      _totalPages = 0;
    });

    try {
      // First get page count
      final pageCount = await PdfChunkedExtractor.getPageCount(_filePath!);
      setState(() {
        _totalPages = pageCount;
      });

      // Extract text in chunks for large PDFs
      final text = await PdfChunkedExtractor.extractTextInChunks(
        _filePath!,
        chunkSize: 20,
        onProgress: (current, total) {
          setState(() {
            _currentPage = current;
          });
        },
      );

      setState(() {
        _extractedText = text;
        _isExtracting = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
      setState(() => _isExtracting = false);
    }
  }

  void _navigateToPlayer() {
    if (_extractedText == null || _fileName == null) return;
    
    // Start playback immediately for UX
    ref.read(ttsServiceProvider).startAudiobook(_fileName!, _extractedText!);
    
    // Persist for resume
    ref.read(ttsServiceProvider).persistState(_fileName!, _filePath!, 0);

    // [New] Save to Library
    ref.read(libraryProvider.notifier).addItem(
      title: _fileName!,
      type: LibraryItemType.audiobook,
      content: _filePath!, // For audiobooks, content is the file path
      metadata: {
        'charCount': _extractedText!.length,
        'lastIndex': 0,
      },
    );

    context.push(AppRoutes.audiobook, extra: {
      'title': _fileName,
      'text': _extractedText,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Convert PDF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildUploadCard(),
            const SizedBox(height: 32),
            if (_fileName != null) _buildFileInfo(),
            const Spacer(),
            if (_extractedText != null)
              ElevatedButton.icon(
                onPressed: _navigateToPlayer,
                icon: const Icon(Icons.play_circle_filled_rounded),
                label: const Text('Start Audiobook'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 200,
        decoration: AppTheme.glassMorphism(
          borderColor: _fileName != null ? AppTheme.primary : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file_rounded,
              size: 48,
              color: _fileName != null ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _fileName ?? 'Tap to select PDF',
              style: TextStyle(
                color: _fileName != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supports large PDFs (processed in segments)',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassMorphism(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _fileName!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isExtracting)
            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _totalPages > 0 
                          ? 'Processing PDF... (${_totalPages} pages)'
                          : 'Extracting text locally...',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (_totalPages > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    backgroundColor: AppTheme.glassBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_totalPages} pages total',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ],
            )
          else if (_extractedText != null)
            Text(
              'Characters extracted: ${_extractedText!.length}',
              style: const TextStyle(color: AppTheme.success, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
