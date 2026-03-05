import 'dart:io';

void main() {
  final file = File('build_err_verbose.txt');
  if (!file.existsSync()) {
    print("File not found");
    return;
  }
  
  final lines = file.readAsLinesSync();
  
  bool inFailure = false;
  bool inWhatWentWrong = false;
  
  final out = StringBuffer();
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (!inFailure && line.contains("FAILURE: Build failed with an exception.")) {
      inFailure = true;
      out.writeln(line);
      continue;
    }
    
    if (inFailure) {
      out.writeln(line);
      
      // Stop after printing a few lines past "Get more help at"
      if (line.contains("Get more help at https://help.gradle.org")) {
        // give it a few more lines maybe
        for (int j = 1; j <= 5 && i + j < lines.length; j++) {
           out.writeln(lines[i+j]);
        }
        break;
      }
    }
  }
  
  print(out.toString());
}
