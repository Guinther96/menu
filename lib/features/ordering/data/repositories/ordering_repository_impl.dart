import 'package:table_ordering_client/core/constants/app_constants.dart';
import 'package:table_ordering_client/core/network/api_client.dart';
import 'package:table_ordering_client/features/ordering/data/datasources/ordering_remote_datasource.dart';
import 'package:table_ordering_client/features/ordering/data/models/order_item.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/cart_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';
import 'package:table_ordering_client/services/order_client_api_service.dart';

class OrderingRepositoryImpl implements OrderingRepository {
  OrderingRepositoryImpl({
    ApiClient? apiClient,
    OrderClientApiService? apiService,
  }) : _remoteDataSource = OrderingRemoteDataSource(apiClient ?? ApiClient()),
       _apiService = apiService;

  final OrderingRemoteDataSource _remoteDataSource;
  final OrderClientApiService? _apiService;

  @override
  Future<TableSessionEntity> validateTable(
    String tableCode, {
    String? restaurantId,
  }) async {
    final sourceResult = await _remoteDataSource.validateTable(
      tableCode,
      restaurantId: restaurantId,
    );

    return TableSessionEntity(
      restaurant: sourceResult.restaurant.toEntity(),
      table: sourceResult.table.toEntity(),
    );
  }

  @override
  Future<List<MenuItemEntity>> getMenu(String restaurantId) async {
    if (_apiService != null) {
      final dtos = await _apiService.fetchMenu(restaurantId);
      return dtos
          .map(
            (dto) => MenuItemEntity(
              id: dto.id,
              name: dto.name,
              description: '',
              price: dto.price,
              category: dto.category ?? 'Général',
              isAvailable: dto.isAvailable,
              imageUrl: dto.imageUrl,
            ),
          )
          .toList();
    }

    final items = await _remoteDataSource.getMenu(restaurantId);
    return items.map((item) => item.toEntity()).toList();
  }

  @override
  Future<OrderEntity> createOrder({
    required String tableId,
    required List<CartItemEntity> items,
    String? globalNote,
  }) async {
    final payloadItems = items
        .map(
          (item) => OrderItem(
            menuItemId: item.menuItem.id,
            name: item.menuItem.name,
            unitPrice: item.menuItem.price,
            quantity: item.quantity,
            note: item.note,
          ),
        )
        .toList();

    if (_apiService != null) {
      final clientItems = items
          .map(
            (item) => CreateOrderItemInput(
              menuItemId: item.menuItem.id,
              quantity: item.quantity,
            ),
          )
          .toList();
      final result = await _apiService.createOrder(
        tableId: tableId,
        items: clientItems,
      );
      return _mapOrderResponse(result, tableId: tableId);
    }

    final createdOrder = await _remoteDataSource.createOrder(
      tableId: tableId,
      items: payloadItems,
      globalNote: globalNote,
    );
    return createdOrder.toEntity();
  }

  OrderEntity _mapOrderResponse(
    Map<String, dynamic> response, {
    required String tableId,
  }) {
    final rawCreatedAt =
        response['created_at'] as String? ?? response['createdAt'] as String?;
    return OrderEntity(
      id: (response['id'] ?? response['_id'] ?? '') as String,
      tableId:
          (response['table_id'] ?? response['tableId'] ?? tableId) as String,
      items: const [],
      createdAt: rawCreatedAt != null
          ? DateTime.parse(rawCreatedAt)
          : DateTime.now(),
      status: OrderStatus.enAttente,
      globalNote:
          response['globalNote'] as String? ??
          response['global_note'] as String?,
      fees: _toDouble(response['fees']),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '.').replaceAll(':', '.');
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    final order = await _remoteDataSource.getOrderById(orderId);

    return order.toEntity();
  }

  @override
  Stream<OrderEntity> watchOrderStatus(
    String orderId, {
    Duration interval = const Duration(seconds: 5),
  }) {
    final stream = _remoteDataSource.watchOrderStatus(
      orderId,
      interval: interval,
    );

    return stream.map((order) => order.toEntity());
  }
}
