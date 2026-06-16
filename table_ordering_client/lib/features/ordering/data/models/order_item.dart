import 'package:table_ordering_client/features/ordering/domain/entities/order_item_entity.dart';

class OrderItem {
  const OrderItem({
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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    final rawUnitPrice = json['unitPrice'] ?? json['unit_price'] ?? json['price'];

    return OrderItem(
      menuItemId:
          (json['menuItemId'] ?? json['menu_item_id'] ?? json['id'] ?? '')
              .toString(),
      name: (json['name'] ?? json['menuItemName'] ?? json['menu_item_name'] ??
              'Item')
          .toString(),
      unitPrice: _toDouble(rawUnitPrice),
      quantity: rawQuantity is num
          ? rawQuantity.toInt()
          : int.tryParse(rawQuantity?.toString() ?? '') ?? 0,
      note: json['note']?.toString(),
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

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'note': note,
    };
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    menuItemId: menuItemId,
    name: name,
    unitPrice: unitPrice,
    quantity: quantity,
    note: note,
  );
}
