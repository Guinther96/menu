import 'package:table_ordering_client/core/network/api_client.dart';

class MenuItemDto {
  MenuItemDto({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.isAvailable,
    this.category,
    this.imageUrl,
  });

  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final bool isAvailable;
  final String? category;
  final String? imageUrl;

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    return MenuItemDto(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String? ?? 'Item',
      price: double.tryParse('${json['price']}') ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class TableDto {
  TableDto({
    required this.id,
    required this.restaurantId,
    required this.number,
    this.qrCode,
  });

  final String id;
  final String restaurantId;
  final int number;
  final String? qrCode;

  factory TableDto.fromJson(Map<String, dynamic> json) {
    return TableDto(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      number: json['number'] as int? ?? 0,
      qrCode: json['qr_code'] as String?,
    );
  }
}

class CreateOrderItemInput {
  CreateOrderItemInput({required this.menuItemId, required this.quantity});

  final String menuItemId;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {'menu_item_id': menuItemId, 'quantity': quantity};
  }
}

class OrderClientApiService {
  OrderClientApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MenuItemDto>> fetchMenu(String restaurantId) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/restaurants/$restaurantId/menu',
    );
    final data = response.data ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(MenuItemDto.fromJson)
        .toList();
  }

  Future<List<TableDto>> fetchTables(String restaurantId) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/restaurants/$restaurantId/tables',
    );
    final data = response.data ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(TableDto.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> createOrder({
    required String tableId,
    required List<CreateOrderItemInput> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('createOrder requires at least one item');
    }

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/orders',
      data: {
        'table_id': tableId,
        'items': items.map((x) => x.toJson()).toList(),
      },
    );

    return response.data ?? <String, dynamic>{};
  }

  void dispose() {
    // ApiClient manages its own Dio instance; nothing to dispose here.
  }
}
