import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message) {
    debugPrint("[PocketAudio] $message");
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint("[PocketAudio ERROR] $message");
    if (error != null) debugPrint("Error: $error");
    if (stackTrace != null) debugPrint("StackTrace: $stackTrace");
  }
}
