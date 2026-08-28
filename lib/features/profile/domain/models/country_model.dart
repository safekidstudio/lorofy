class CountryModel {
  final String code;
  final String name;
  final String? flagUrl;

  const CountryModel({
    required this.code,
    required this.name,
    this.flagUrl,
  });

  String get flagEmoji {
    if (code.length != 2) return '🏳️';
    final int firstLetter = code.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'flagUrl': flagUrl,
    };
  }

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
      flagUrl: json['flagUrl'] as String?,
    );
  }
}
