import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';

import 'order_client_api_service.dart';

final backendBaseUrlProvider = Provider<String>((ref) {
  return AppConstants.apiBaseUrl;
});

final restaurantIdProvider = Provider<String>((ref) {
  return const String.fromEnvironment('RESTAURANT_ID');
});

final orderClientApiServiceProvider = Provider<OrderClientApiService>((ref) {
  final baseUrl = ref.watch(backendBaseUrlProvider);
  final service = OrderClientApiService(baseUrl: baseUrl);
  ref.onDispose(service.dispose);
  return service;
});

final clientMenuProvider = FutureProvider<List<MenuItemDto>>((ref) async {
  final service = ref.watch(orderClientApiServiceProvider);
  final restaurantId = ref.watch(restaurantIdProvider);
  if (restaurantId.isEmpty) {
    throw StateError('RESTAURANT_ID n\'est pas configure.');
  }
  return service.fetchMenu(restaurantId);
});

final clientTablesProvider = FutureProvider<List<TableDto>>((ref) async {
  final service = ref.watch(orderClientApiServiceProvider);
  final restaurantId = ref.watch(restaurantIdProvider);
  if (restaurantId.isEmpty) {
    throw StateError('RESTAURANT_ID n\'est pas configure.');
  }
  return service.fetchTables(restaurantId);
});
