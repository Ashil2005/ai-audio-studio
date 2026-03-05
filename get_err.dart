import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('build_out_ps1.txt');
  if (!file.existsSync()) {
    print("File not found");
    return;
  }
  
  List<String> lines = [];
  try {
    lines = file.readAsStringSync().split('\n');
  } catch (e) {
    try {
      final bytes = file.readAsBytesSync();
      lines = utf8.decode(bytes, allowMalformed: true).split('\n');
    } catch (_) {}
  }
  
  final out = StringBuffer();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.contains("e: ") || line.contains("FAILURE:") || line.contains("What went wrong")) {
      out.writeln(line);
      for(int j=1; j<=20 && i+j < lines.length; j++) {
         out.writeln(lines[i+j].trim());
      }
      break;
    }
  }
  print(out.toString());
}
