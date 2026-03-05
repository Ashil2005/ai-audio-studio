import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

/// Utility to extract text from large PDF files in chunks to avoid memory issues.
class PdfChunkedExtractor {
  PdfChunkedExtractor._();

  /// Extract text from PDF in chunks with progress callback.
  static Future<String> extractTextInChunks(
    String filePath, {
    int chunkSize = 20,
    Function(int current, int total)? onProgress,
  }) async {
    return await compute(
      (params) => _extractTextInChunksIsolate(
        params['filePath'] as String,
        params['chunkSize'] as int,
        params['sendPort'],
      ),
      {
        'filePath': filePath,
        'chunkSize': chunkSize,
        'sendPort': null, // We'll handle progress differently for now
      },
    );
  }

  static Future<String> _extractTextInChunksIsolate(
    String filePath,
    int chunkSize,
    dynamic sendPort,
  ) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      final List<int> bytes = await file.readAsBytes();
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);

      final int totalPages = document.pages.count;
      final StringBuffer fullText = StringBuffer();

      // Process in chunks
      for (int startPage = 0; startPage < totalPages; startPage += chunkSize) {
        final int endPage = (startPage + chunkSize - 1).clamp(0, totalPages - 1);
        
        // Extract text from current chunk
        final String chunkText = _extractTextFromPageRange(document, startPage, endPage);
        fullText.write(chunkText);
        fullText.write('\n\n'); // Add separator between chunks

        // Progress callback would go here if we had proper isolate communication
        // For now, we'll handle progress in the UI layer
      }

      document.dispose();
      return _cleanText(fullText.toString());
    } catch (e) {
      throw Exception('Failed to extract PDF text: $e');
    }
  }

  static String _extractTextFromPageRange(sf.PdfDocument document, int startPage, int endPage) {
    final StringBuffer chunkText = StringBuffer();
    
    for (int i = startPage; i <= endPage; i++) {
      if (i < document.pages.count) {
        final sf.PdfPage page = document.pages[i];
        final String pageText = sf.PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        chunkText.write(pageText);
        chunkText.write('\n');
      }
    }
    
    return chunkText.toString();
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\r\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Get page count without extracting text
  static Future<int> getPageCount(String filePath) async {
    return await compute(_getPageCountIsolate, filePath);
  }

  static Future<int> _getPageCountIsolate(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      final List<int> bytes = await file.readAsBytes();
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
      final int pageCount = document.pages.count;
      document.dispose();
      
      return pageCount;
    } catch (e) {
      throw Exception('Failed to get page count: $e');
    }
  }
}