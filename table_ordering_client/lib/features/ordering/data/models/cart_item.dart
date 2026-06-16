import 'package:table_ordering_client/features/ordering/data/models/menu_item.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/cart_item_entity.dart';

class CartItem {
  const CartItem({required this.menuItem, required this.quantity, this.note});

  final MenuItem menuItem;
  final int quantity;
  final String? note;

  CartItemEntity toEntity() {
    return CartItemEntity(
      menuItem: menuItem.toEntity(),
      quantity: quantity,
      note: note,
    );
  }
}
