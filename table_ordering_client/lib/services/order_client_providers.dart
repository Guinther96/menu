import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';
import 'package:table_ordering_client/core/network/api_client.dart';

import 'order_client_api_service.dart';

Map<String, String> _extractLinkParams() {
  final params = <String, String>{};

  void mergeTrimmed(Map<String, String> source) {
    for (final entry in source.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();
      if (key.isEmpty || value.isEmpty) continue;
      params.putIfAbsent(key, () => value);
    }
  }

  try {
    mergeTrimmed(Uri.base.queryParameters);
  } catch (_) {
    // Ignore malformed URL query and continue.
  }

  try {
    final fragment = Uri.base.fragment.trim();
    if (fragment.isEmpty) {
      return params;
    }

    if (fragment.contains('?')) {
      final fragmentQueryPart = fragment.split('?').last;
      mergeTrimmed(Uri(query: fragmentQueryPart).queryParameters);
    } else if (fragment.contains('=')) {
      mergeTrimmed(Uri(query: fragment).queryParameters);
    }
  } catch (_) {
    // Ignore malformed URL fragment query and continue.
  }

  return params;
}

String _pickFirstNonEmpty(Map<String, String> params, List<String> keys) {
  for (final key in keys) {
    final value = params[key];
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

final backendBaseUrlProvider = Provider<String>((ref) {
  return AppConstants.apiBaseUrl;
});

/// Returns the authorization token from the URL query parameter `auth_token`.
/// Set by the QR code URL: https://yourapp.netlify.app/?auth_token=TOKEN
const bool useAuthTokenFallback = bool.fromEnvironment(
  'USE_AUTH_TOKEN_FALLBACK',
  defaultValue: false,
);

final authTokenProvider = Provider<String>((ref) {
  final params = _extractLinkParams();
  final fromLink = _pickFirstNonEmpty(params, const [
    'auth_token',
    'token',
    'api_key',
    'apikey',
    'authorization',
    'bearer',
  ]);
  if (fromLink.isNotEmpty) {
    return fromLink;
  }

  if (!useAuthTokenFallback) {
    return '';
  }

  return const String.fromEnvironment('AUTH_TOKEN').trim();
});

const bool useRestaurantIdFallback = bool.fromEnvironment(
  'USE_RESTAURANT_ID_FALLBACK',
  defaultValue: false,
);

final restaurantIdProvider = Provider<String>((ref) {
  final params = _extractLinkParams();
  final fromLink = _pickFirstNonEmpty(params, const [
    'restaurant_id',
    'restaurantId',
    'resto_id',
    'restoId',
    'restaurant',
    'rid',
  ]);
  if (fromLink.isNotEmpty) {
    return fromLink;
  }

  if (!useRestaurantIdFallback) {
    return '';
  }

  return const String.fromEnvironment('RESTAURANT_ID').trim();
});

/// Best-effort table token from QR deep links (table ID/code/number).
final tableLinkTokenProvider = Provider<String>((ref) {
  final params = _extractLinkParams();
  return _pickFirstNonEmpty(params, const [
    'table_id',
    'tableId',
    'table_code',
    'tableCode',
    'code',
    'table',
    'table_number',
    'tableNumber',
    'number',
  ]);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final authToken = ref.watch(authTokenProvider);
  print('Auth token = "$authToken"');
  return ApiClient(authToken: authToken.isNotEmpty ? authToken : null);
});

final orderClientApiServiceProvider = Provider<OrderClientApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final service = OrderClientApiService(apiClient: apiClient);
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
