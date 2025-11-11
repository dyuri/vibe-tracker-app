/// Application settings model
class AppSettings {
  final String serverUrl;
  final String? accessToken;
  final String? currentSession;
  final int trackingIntervalSeconds;

  AppSettings({
    required this.serverUrl,
    this.accessToken,
    this.currentSession,
    this.trackingIntervalSeconds = 60,
  });

  AppSettings copyWith({
    String? serverUrl,
    String? accessToken,
    String? currentSession,
    int? trackingIntervalSeconds,
  }) {
    return AppSettings(
      serverUrl: serverUrl ?? this.serverUrl,
      accessToken: accessToken ?? this.accessToken,
      currentSession: currentSession ?? this.currentSession,
      trackingIntervalSeconds: trackingIntervalSeconds ?? this.trackingIntervalSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'accessToken': accessToken,
      'currentSession': currentSession,
      'trackingIntervalSeconds': trackingIntervalSeconds,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      serverUrl: json['serverUrl'] as String? ?? '',
      accessToken: json['accessToken'] as String?,
      currentSession: json['currentSession'] as String?,
      trackingIntervalSeconds: json['trackingIntervalSeconds'] as int? ?? 60,
    );
  }

  bool get isConfigured => serverUrl.isNotEmpty && accessToken != null && accessToken!.isNotEmpty;
}
