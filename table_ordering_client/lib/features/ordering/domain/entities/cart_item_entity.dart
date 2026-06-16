import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';

class CartItemEntity {
  const CartItemEntity({
    required this.menuItem,
    required this.quantity,
    this.note,
  });

  final MenuItemEntity menuItem;
  final int quantity;
  final String? note;

  double get lineTotal => menuItem.price * quantity;

  CartItemEntity copyWith({
    MenuItemEntity? menuItem,
    int? quantity,
    String? note,
  }) {
    return CartItemEntity(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
