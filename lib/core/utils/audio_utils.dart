/// Utility helpers for audio formatting and calculations.
class AudioUtils {
  AudioUtils._();

  /// Format duration as MM:SS or H:MM:SS
  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  /// Format duration in minutes as human-readable string
  static String formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  /// Map speed value to display label
  static String speedLabel(double speed) {
    if (speed == 0.5) return '0.5×';
    if (speed == 0.75) return '0.75×';
    if (speed == 1.0) return '1×';
    if (speed == 1.25) return '1.25×';
    if (speed == 1.5) return '1.5×';
    if (speed == 1.75) return '1.75×';
    if (speed == 2.0) return '2×';
    return '${speed}×';
  }

  /// Available TTS playback speeds
  static const List<double> playbackSpeeds = [
    0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
  ];

  /// Estimate audio duration from word count (150 wpm average TTS)
  static Duration estimateDuration(int wordCount) =>
      Duration(seconds: (wordCount / 150 * 60).round());
}
