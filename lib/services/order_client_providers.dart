import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';

import 'order_client_api_service.dart';

final backendBaseUrlProvider = Provider<String>((ref) {
  return AppConstants.apiBaseUrl;
});

/// Returns the restaurant ID for this session.
///
/// Priority order:
///   1. `restaurant_id` URL query parameter (web runtime, set by QR code URL)
///   2. `RESTAURANT_ID` compile-time dart-define (CI / local dev)
final restaurantIdProvider = Provider<String>((ref) {
  if (kIsWeb) {
    final fromUrl = Uri.base.queryParameters['restaurant_id'] ?? '';
    if (fromUrl.isNotEmpty) return fromUrl;
  }
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
