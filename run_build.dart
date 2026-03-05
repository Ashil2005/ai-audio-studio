import 'dart:io';

void main() {
  final res = Process.runSync('flutter.bat', ['build', 'apk', '--debug', '-v']);
  File('build_out_utf8.txt').writeAsStringSync(res.stdout.toString() + "\n" + res.stderr.toString());
}
