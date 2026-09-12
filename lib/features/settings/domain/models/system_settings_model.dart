class SystemSettingsModel {
  final double rewardMultiplierMedium;
  final double rewardMultiplierStrict;
  final int rewardBaseCoinsPerMin;
  final int rewardBasePointsPerMin;
  final int penaltyPointsMedium;
  final int penaltyPointsStrict;

  const SystemSettingsModel({
    this.rewardMultiplierMedium = 1.0,
    this.rewardMultiplierStrict = 1.5,
    this.rewardBaseCoinsPerMin = 1,
    this.rewardBasePointsPerMin = 1,
    this.penaltyPointsMedium = 20,
    this.penaltyPointsStrict = 40,
  });

  factory SystemSettingsModel.fromMap(Map<String, dynamic> map) {
    return SystemSettingsModel(
      rewardMultiplierMedium:
          double.tryParse(map['focus.reward.multiplier.medium']?.toString() ?? '') ?? 1.0,
      rewardMultiplierStrict:
          double.tryParse(map['focus.reward.multiplier.strict']?.toString() ?? '') ?? 1.5,
      rewardBaseCoinsPerMin:
          int.tryParse(map['focus.reward.base_coins_per_min']?.toString() ?? '') ?? 1,
      rewardBasePointsPerMin:
          int.tryParse(map['focus.reward.base_points_per_min']?.toString() ?? '') ?? 1,
      penaltyPointsMedium:
          int.tryParse(map['focus.penalty.points.medium']?.toString() ?? '') ?? 20,
      penaltyPointsStrict:
          int.tryParse(map['focus.penalty.points.strict']?.toString() ?? '') ?? 40,
    );
  }

  Map<String, String> toMap() {
    return {
      'focus.reward.multiplier.medium': rewardMultiplierMedium.toString(),
      'focus.reward.multiplier.strict': rewardMultiplierStrict.toString(),
      'focus.reward.base_coins_per_min': rewardBaseCoinsPerMin.toString(),
      'focus.reward.base_points_per_min': rewardBasePointsPerMin.toString(),
      'focus.penalty.points.medium': penaltyPointsMedium.toString(),
      'focus.penalty.points.strict': penaltyPointsStrict.toString(),
    };
  }
}
