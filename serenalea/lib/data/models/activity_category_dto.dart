class ActivityCategory {
  final String id;
  final String name;
  final String description;
  final String iconName; // Nombre del icono para usar en Flutter
  final String colorHex; // Color representativo en hex
  final int order; // Orden de visualización
  final bool isActive; // Si está activa o no

  ActivityCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.order,
    this.isActive = true,
  });

  factory ActivityCategory.fromMap(Map<String, dynamic> map, String documentId) {
    return ActivityCategory(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? 'category',
      colorHex: map['colorHex'] ?? '#436A92',
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'order': order,
      'isActive': isActive,
    };
  }
}
