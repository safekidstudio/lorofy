class PointHistoryModel {
  final String id;
  final String type; // "REWARD" or "PENALTY"
  final int points;
  final String title;
  final String description;
  final String categoryName;
  final String? blockMode;
  final DateTime timestamp;

  PointHistoryModel({
    required this.id,
    required this.type,
    required this.points,
    required this.title,
    required this.description,
    required this.categoryName,
    this.blockMode,
    required this.timestamp,
  });

  bool get isReward => type == 'REWARD' || points > 0;

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['timestamp'] != null) {
      parsedDate = DateTime.tryParse(json['timestamp'].toString())?.toLocal() ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return PointHistoryModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'REWARD',
      points: json['points'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? 'Khác',
      blockMode: json['blockMode'] as String?,
      timestamp: parsedDate,
    );
  }
}
