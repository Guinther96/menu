import 'package:table_ordering_client/core/network/api_client.dart';
import 'package:table_ordering_client/features/ordering/data/models/menu_item.dart';
import 'package:table_ordering_client/features/ordering/data/models/order.dart';
import 'package:table_ordering_client/features/ordering/data/models/order_item.dart';
import 'package:table_ordering_client/features/ordering/data/models/restaurant.dart';
import 'package:table_ordering_client/features/ordering/data/models/table.dart';

class OrderingRemoteDataSource {
  OrderingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<({Restaurant restaurant, Table table})> validateTable(
    String tableCode, {
    String? restaurantId,
  }) async {
    final resolvedRestaurantId = restaurantId?.trim() ?? '';
    final queryParameters = <String, dynamic>{'code': tableCode};
    if (resolvedRestaurantId.isNotEmpty) {
      queryParameters['restaurant_id'] = resolvedRestaurantId;
    }

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/tables/validate',
      queryParameters: queryParameters,
    );

    final data = response.data ?? <String, dynamic>{};
    return (
      restaurant: Restaurant.fromJson(
        data['restaurant'] as Map<String, dynamic>,
      ),
      table: Table.fromJson(data['table'] as Map<String, dynamic>),
    );
  }

  Future<List<MenuItem>> getMenu(String restaurantId) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/restaurants/$restaurantId/menu',
    );
    final data = response.data ?? <dynamic>[];

    return data
        .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Order> createOrder({
    required String tableId,
    required List<OrderItem> items,
    String? globalNote,
  }) async {
    final payload = {
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'globalNote': globalNote,
    };

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/orders',
      data: payload,
    );
    return Order.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Order> getOrderById(String orderId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/orders/$orderId',
    );
    return Order.fromJson(response.data ?? <String, dynamic>{});
  }

  // Point d'extension: brancher ici WebSocket/Supabase Realtime.
  Stream<Order> watchOrderStatus(
    String orderId, {
    Duration interval = const Duration(seconds: 5),
  }) {
    return Stream.periodic(interval).asyncMap((_) => getOrderById(orderId));
  }
}
