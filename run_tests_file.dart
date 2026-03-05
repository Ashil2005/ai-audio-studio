import 'dart:io';

void main() {
  const text = "First important sentence. "
      "Second filler sentence that is long enough to meet length requirement but less important. "
      "Third important sentence with keywords keywords keywords. "
      "Fourth Filler sentence of moderate length. "
      "Fifth important sentence explaining everything.";
      
  final paddedText = text + " Extra padding text " * 30;

  final cleanText = paddedText.replaceAll(RegExp(r'\r\n|\r|\n'), ' ').trim();
  final sentences = cleanText
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  
  for (final s in sentences) {
    print("Found: ${paddedText.indexOf(s)}");
  }
}
