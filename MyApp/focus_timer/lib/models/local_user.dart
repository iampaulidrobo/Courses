import 'dart:convert';

class LocalUser {
  final String displayName;
  final String loginMode;
  final String scopeId;

  const LocalUser({
    required this.displayName,
    required this.loginMode,
    required this.scopeId,
  });

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'loginMode': loginMode,
        'scopeId': scopeId,
      };

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      displayName: (json['displayName'] ?? 'User').toString(),
      loginMode: (json['loginMode'] ?? 'Guest').toString(),
      scopeId: (json['scopeId'] ?? 'guest').toString(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocalUser.fromJsonString(String raw) =>
      LocalUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
