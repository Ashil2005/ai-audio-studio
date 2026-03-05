import 'dart:io';

void main() {
  final res = Process.runSync('flutter.bat', ['test', '--reporter=json']);
  File('out_tests_json.log').writeAsStringSync(res.stdout.toString() + "\n" + res.stderr.toString());
}
