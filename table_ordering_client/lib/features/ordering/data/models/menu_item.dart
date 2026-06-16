import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];

    return MenuItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Item').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(rawPrice),
      category: (json['category'] ?? 'General').toString(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '.').replaceAll(':', '.');
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  MenuItemEntity toEntity() => MenuItemEntity(
    id: id,
    name: name,
    description: description,
    price: price,
    category: category,
    isAvailable: isAvailable,
    imageUrl: imageUrl,
  );
}
