import 'package:table_ordering_client/features/ordering/domain/entities/cart_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';
import 'package:table_ordering_client/services/order_client_api_service.dart';

class OrderingRepositoryImpl implements OrderingRepository {
  OrderingRepositoryImpl(this._api);

  final OrderClientApiService _api;

  @override
  Future<TableSessionEntity> validateTable(
    String tableCode, {
    String? restaurantId,
  }) async {
    throw UnimplementedError('validateTable non implémenté');
  }

  @override
  Future<List<MenuItemEntity>> getMenu(String restaurantId) async {
    final dtos = await _api.fetchMenu(restaurantId);

    return dtos.map((dto) {
      return MenuItemEntity(
        id: dto.id,
        name: dto.name,
        description: '',
        price: dto.price,
        category: dto.category ?? 'Général',
        isAvailable: dto.isAvailable,
        imageUrl: dto.imageUrl,
      );
    }).toList();
  }

  @override
  Future<OrderEntity> createOrder({
    required String tableId,
    required List<CartItemEntity> items,
    String? globalNote,
  }) async {
    final result = await _api.createOrder(
      tableId: tableId,
      items: items
          .map(
            (e) => CreateOrderItemInput(
              menuItemId: e.menuItem.id,
              quantity: e.quantity,
            ),
          )
          .toList(),
    );

    final orderItems = items.map((e) {
      return OrderItemEntity(
        menuItemId: e.menuItem.id,
        name: e.menuItem.name,
        quantity: e.quantity,
        unitPrice: e.menuItem.price,
        note: e.note,
      );
    }).toList();

    return OrderEntity(
      id: result['id']?.toString() ?? '',
      tableId: tableId,
      items: orderItems,
      createdAt: DateTime.now(),
      status: OrderStatus.enAttente,
      globalNote: globalNote,
      fees: 0,
    );
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) {
    throw UnimplementedError();
  }

  @override
  Stream<OrderEntity> watchOrderStatus(
    String orderId, {
    Duration interval = const Duration(seconds: 5),
  }) {
    throw UnimplementedError();
  }
}