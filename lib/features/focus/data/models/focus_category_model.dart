import 'package:lorofy/features/focus/domain/models/focus_category.dart';

class FocusCategoryModel extends FocusCategory {
  FocusCategoryModel({
    required super.id,
    required super.name,
    super.iconName,
    super.colorHex,
    required super.isSystem,
  });

  factory FocusCategoryModel.fromJson(Map<String, dynamic> json) {
    return FocusCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
      isSystem: json['system'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
      'system': isSystem,
    };
  }
}
