class FocusCategory {
  final String id;
  final String name;
  final String? iconName;
  final String? colorHex;
  final bool isSystem;

  FocusCategory({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
    required this.isSystem,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'colorHex': colorHex,
        'isSystem': isSystem,
      };

  factory FocusCategory.fromJson(Map<String, dynamic> json) {
    return FocusCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
      isSystem: (json['isSystem'] ?? json['system']) as bool? ?? false,
    );
  }
}
