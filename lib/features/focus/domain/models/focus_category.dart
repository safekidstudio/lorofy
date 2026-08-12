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
}
