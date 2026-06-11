import 'dart:convert';

import 'package:http/http.dart' as http;

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
  OrderClientApiService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<MenuItemDto>> fetchMenu(String restaurantId) async {
    final uri = Uri.parse('$baseUrl/restaurants/$restaurantId/menu');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'fetchMenu failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw Exception('Invalid menu payload');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(MenuItemDto.fromJson)
        .toList();
  }

  Future<List<TableDto>> fetchTables(String restaurantId) async {
    final uri = Uri.parse('$baseUrl/restaurants/$restaurantId/tables');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'fetchTables failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw Exception('Invalid tables payload');
    }

    return decoded
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

    final uri = Uri.parse('$baseUrl/orders');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'table_id': tableId,
        'items': items.map((x) => x.toJson()).toList(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'createOrder failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid create order payload');
    }

    return decoded;
  }

  void dispose() {
    _client.close();
  }
}
