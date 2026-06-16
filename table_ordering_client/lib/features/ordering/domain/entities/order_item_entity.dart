class OrderItemEntity {
  const OrderItemEntity({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.note,
  });

  final String menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? note;

  double get lineTotal => unitPrice * quantity;
}
