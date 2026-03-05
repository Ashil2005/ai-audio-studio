import 'package:audio_studio/core/utils/text_summarizer.dart';

void main() {
  const text = "Is this a question? This is a statement! Another one... And one more. " +
      "This part of the document has a lot of extra spaces and \n newlines \r\n that should be handled.";
  final paddedText = text + " Relevant keywords found here for frequency analysis. " * 40;

  final summary = TextSummarizer.summarize(paddedText);
  print("SUMMARY:\n$summary");
  print("\nContains ?: ${summary.contains('?')}");
  print("Contains !: ${summary.contains('!')}");
  print("Contains \\n: ${summary.contains('\n')}");
}
