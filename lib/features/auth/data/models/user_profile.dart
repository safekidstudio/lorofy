class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String countryCode;
  final String countryName;
  final String timezone;
  final bool isOnboarded;
  final String? avatarUrl;
  final String defaultBlockMode;
  final int rankPoints;
  final int goldCoins;
  final int totalFocusMinutes;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezeCount;
  final bool canRepairStreak;
  final int repairableStreak;
  final int repairCostCoins;

  UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    required this.countryCode,
    required this.countryName,
    required this.timezone,
    required this.isOnboarded,
    this.avatarUrl,
    this.defaultBlockMode = 'MEDIUM',
    required this.rankPoints,
    this.goldCoins = 0,
    this.totalFocusMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakFreezeCount = 0,
    this.canRepairStreak = false,
    this.repairableStreak = 0,
    this.repairCostCoins = 100,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      countryCode: json['countryCode'] as String? ?? 'VN',
      countryName: json['countryName'] as String? ?? 'Vietnam',
      timezone: json['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
      isOnboarded: json['onboarded'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      defaultBlockMode: json['defaultBlockMode'] as String? ?? 'MEDIUM',
      rankPoints: json['rankPoints'] as int? ?? 0,
      goldCoins: json['goldCoins'] as int? ?? 0,
      totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      streakFreezeCount: json['streakFreezeCount'] as int? ?? 0,
      canRepairStreak: json['canRepairStreak'] as bool? ?? false,
      repairableStreak: json['repairableStreak'] as int? ?? 0,
      repairCostCoins: json['repairCostCoins'] as int? ?? 100,
    );
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? countryCode,
    String? countryName,
    String? timezone,
    bool? isOnboarded,
    String? avatarUrl,
    String? defaultBlockMode,
    int? rankPoints,
    int? goldCoins,
    int? totalFocusMinutes,
    int? currentStreak,
    int? longestStreak,
    int? streakFreezeCount,
    bool? canRepairStreak,
    int? repairableStreak,
    int? repairCostCoins,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      timezone: timezone ?? this.timezone,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      defaultBlockMode: defaultBlockMode ?? this.defaultBlockMode,
      rankPoints: rankPoints ?? this.rankPoints,
      goldCoins: goldCoins ?? this.goldCoins,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      canRepairStreak: canRepairStreak ?? this.canRepairStreak,
      repairableStreak: repairableStreak ?? this.repairableStreak,
      repairCostCoins: repairCostCoins ?? this.repairCostCoins,
    );
  }
}

