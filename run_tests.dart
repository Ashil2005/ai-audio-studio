import 'dart:io';

void main() {
  final text = "Is this a question? This is a statement! Another one... And one more. " +
      "This part of the document has a lot of extra spaces and \n newlines \r\n that should be handled.";
  final paddedText = text + " Relevant keywords found here for frequency analysis. " * 40;

  final cleanText = paddedText.replaceAll(RegExp(r'\r\n|\r|\n'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  final sentences = cleanText
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  
  for (var s in sentences) {
    print("LENGTH ${s.length}: $s");
  }
}
