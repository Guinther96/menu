import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_ordering_client/core/network/api_client.dart';
import 'package:table_ordering_client/features/ordering/data/datasources/ordering_remote_datasource.dart';
import 'package:table_ordering_client/features/ordering/data/models/order_item.dart';
import 'package:table_ordering_client/services/order_client_api_service.dart';

class _RecordingHttpClientAdapter implements HttpClientAdapter {
  _RecordingHttpClientAdapter({required this.responseBody});

  final ResponseBody responseBody;
  RequestOptions? lastRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    return responseBody;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('API route synchronization', () {
    test('remote datasource uses the backend menu route', () async {
      final adapter = _RecordingHttpClientAdapter(
        responseBody: ResponseBody.fromString(
          jsonEncode(<Map<String, dynamic>>[]),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = adapter;

      final datasource = OrderingRemoteDataSource(apiClient);
      await datasource.getMenu('restaurant-123');

      expect(adapter.lastRequestOptions?.path, '/menu/restaurant-123');
    });

    test('remote datasource sends snake_case order payload fields', () async {
      final adapter = _RecordingHttpClientAdapter(
        responseBody: ResponseBody.fromString(
          jsonEncode(<String, dynamic>{
            'id': 'order-1',
            'table_id': 'table-1',
            'items': <dynamic>[],
            'createdAt': '2024-01-01T00:00:00.000Z',
            'status': 'PENDING',
          }),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = adapter;

      final datasource = OrderingRemoteDataSource(apiClient);
      await datasource.createOrder(
        tableId: 'table-1',
        items: const [
          OrderItem(
            menuItemId: 'menu-item-1',
            name: 'Pizza',
            unitPrice: 10.5,
            quantity: 1,
          ),
        ],
        globalNote: 'No onions',
      );

      final data = adapter.lastRequestOptions?.data as Map<String, dynamic>;
      expect(data['table_id'], 'table-1');
      expect(data['global_note'], 'No onions');
      expect(data['items'][0]['menu_item_id'], 'menu-item-1');
    });

    test('service uses the backend tables route', () async {
      final adapter = _RecordingHttpClientAdapter(
        responseBody: ResponseBody.fromString(
          jsonEncode(<dynamic>[]),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = adapter;

      final service = OrderClientApiService(apiClient: apiClient);
      await service.fetchTables('restaurant-123');

      expect(adapter.lastRequestOptions?.path, '/tables/restaurant-123');
    });
  });
}
