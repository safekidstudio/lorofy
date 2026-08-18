class CountryModel {
  final String code;
  final String name;
  final String? flagUrl;

  const CountryModel({
    required this.code,
    required this.name,
    this.flagUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
      flagUrl: json['flagUrl'] as String?,
    );
  }
}
