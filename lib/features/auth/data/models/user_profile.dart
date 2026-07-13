class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String countryCode;
  final String countryName;
  final String timezone;
  final bool isOnboarded;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    required this.countryCode,
    required this.countryName,
    required this.timezone,
    required this.isOnboarded,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      countryCode: json['countryCode'] as String,
      countryName: json['countryName'] as String,
      timezone: json['timezone'] as String,
      isOnboarded: json['onboarded'] as bool,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
