import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';

import 'order_client_api_service.dart';

final backendBaseUrlProvider = Provider<String>((ref) {
  return AppConstants.apiBaseUrl;
});

/// Returns the restaurant ID from the URL query parameter `restaurant_id`.
/// Set by the QR code URL: https://yourapp.netlify.app/?restaurant_id=<id>
final restaurantIdProvider = Provider<String>((ref) {
  final fromQuery =
      Uri.base.queryParameters['restaurant_id'] ??
      Uri.base.queryParameters['restaurantId'] ??
      '';

  if (fromQuery.isNotEmpty) {
    return fromQuery;
  }

  // Some QR links can carry query params in the URL fragment.
  final fragment = Uri.base.fragment;
  if (fragment.contains('?')) {
    final fragmentQuery = Uri.splitQueryString(fragment.split('?').last);
    final fromFragment =
        fragmentQuery['restaurant_id'] ?? fragmentQuery['restaurantId'] ?? '';
    if (fromFragment.isNotEmpty) {
      return fromFragment;
    }
  }

  // Optional local/dev fallback.
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
    return const <MenuItemDto>[];
  }
  return service.fetchMenu(restaurantId);
});

final clientTablesProvider = FutureProvider<List<TableDto>>((ref) async {
  final service = ref.watch(orderClientApiServiceProvider);
  final restaurantId = ref.watch(restaurantIdProvider);
  if (restaurantId.isEmpty) {
    return const <TableDto>[];
  }
  return service.fetchTables(restaurantId);
});
