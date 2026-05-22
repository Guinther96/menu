import 'package:table_ordering_client/features/ordering/domain/entities/cart_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';

abstract class OrderingRepository {
  Future<TableSessionEntity> validateTable(
    String tableCode, {
    String? restaurantId,
  });

  Future<List<MenuItemEntity>> getMenu(String restaurantId);

  Future<OrderEntity> createOrder({
    required String tableId,
    required List<CartItemEntity> items,
    String? globalNote,
  });

  Future<OrderEntity> getOrderById(String orderId);

  Stream<OrderEntity> watchOrderStatus(
    String orderId, {
    Duration interval = const Duration(seconds: 5),
  });
}
