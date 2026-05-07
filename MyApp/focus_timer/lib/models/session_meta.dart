class SessionMeta {
  final String name;
  final int durationSeconds;
  final int maxRecordings;
  final DateTime createdAt;
  final String folderName;

  SessionMeta({
    required this.name,
    required this.durationSeconds,
    required this.maxRecordings,
    required this.createdAt,
    required this.folderName,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationSeconds': durationSeconds,
        'maxRecordings': maxRecordings,
        'createdAt': createdAt.toIso8601String(),
        'folderName': folderName,
      };

  factory SessionMeta.fromJson(Map<String, dynamic> json) {
    return SessionMeta(
      name: (json['name'] ?? 'Session').toString(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 60,
      maxRecordings: (json['maxRecordings'] as num?)?.toInt() ?? 10,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      folderName: (json['folderName'] ?? '').toString(),
    );
  }
}
