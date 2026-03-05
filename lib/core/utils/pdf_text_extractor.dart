import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

/// Utility to extract text from a local PDF file.
class PdfTextExtractorUtil {
  PdfTextExtractorUtil._();

  /// Async version of extraction to be run in an isolate.
  static Future<String> extractTextAsync(String filePath) async {
    return await compute((path) => extractTextFromPdf(path), filePath);
  }

  /// Extracts full text from a PDF file at [filePath].
  static Future<String> extractTextFromPdf(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      final List<int> bytes = await file.readAsBytes();
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);

      // Create a PDF text extractor
      final sf.PdfTextExtractor extractor = sf.PdfTextExtractor(document);

      // Extract text
      final String text = extractor.extractText();

      document.dispose();
      return _cleanText(text);
    } catch (e) {
      throw Exception('Failed to extract PDF text: $e');
    }
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\r\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
