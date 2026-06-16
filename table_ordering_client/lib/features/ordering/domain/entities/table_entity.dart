class TableEntity {
  const TableEntity({
    required this.id,
    required this.number,
    required this.restaurantId,
    required this.isActive,
  });

  final String id;
  final int number;
  final String restaurantId;
  final bool isActive;
}
