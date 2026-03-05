import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('build_err_verbose.txt');
  if (!file.existsSync()) {
    print("File not found");
    return;
  }
  
  // Try reading as UTF-8 first, fallback to Latin-1
  List<String> lines = [];
  try {
    lines = file.readAsLinesSync(encoding: utf8);
  } catch (e) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = systemEncoding.decode(bytes);
      lines = decoded.split('\n');
    } catch (_) {
       lines = file.readAsLinesSync(encoding: latin1);
    }
  }
  
  bool capturing = false;
  final out = StringBuffer();
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (!capturing && line.contains("FAILURE: Build failed")) {
      capturing = true;
    }
    
    if (capturing) {
      out.writeln(line.trimRight());
      if (line.contains("Get more help at https://help.gradle.org")) {
        for(int j=1; j<=3 && i+j < lines.length; j++) {
            out.writeln(lines[i+j]);
        }
        break;
      }
    }
  }
  
  print(out.toString());
}
