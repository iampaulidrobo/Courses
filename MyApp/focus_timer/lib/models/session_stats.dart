class SessionStats {
  final int totalVideos;
  final int recordedDays;
  final int currentStreak;
  final int longestStreak;

  const SessionStats({
    required this.totalVideos,
    required this.recordedDays,
    required this.currentStreak,
    required this.longestStreak,
  });
}
