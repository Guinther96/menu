class MenuItemEntity {
  const MenuItemEntity({
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
}
