import 'dart:math';

import 'session_meta.dart';

class SessionSummary {
  final SessionMeta meta;
  final String path;
  final int videoCount;

  SessionSummary({
    required this.meta,
    required this.path,
    required this.videoCount,
  });

  int get remaining => max(0, meta.maxRecordings - videoCount);
  double get progress =>
      meta.maxRecordings <= 0 ? 0.0 : (videoCount / meta.maxRecordings).clamp(0.0, 1.0);
}
