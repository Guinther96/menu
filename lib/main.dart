import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/theme/app_theme.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/restaurant_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/menu_screen.dart';
import 'package:table_ordering_client/features/table_entry/presentation/screens/table_entry_screen.dart';
import 'package:table_ordering_client/services/order_client_providers.dart';
import 'package:table_ordering_client/core/utils/web_location.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const ProviderScope(child: RestaurantClientApp()));
}

class RestaurantClientApp extends ConsumerWidget {
  const RestaurantClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var restaurantId = ref.watch(restaurantIdProvider).trim();
    var tableToken = ref.watch(tableLinkTokenWithFallbackProvider).trim();

    // Fallback: if providers returned empty, try reading query params directly
    if (restaurantId.isEmpty || tableToken.isEmpty) {
      try {
        final q = Uri.base.queryParameters;
        restaurantId = restaurantId.isEmpty
            ? (q['restaurant_id'] ?? q['restaurantId'] ?? restaurantId)
            : restaurantId;
        tableToken = tableToken.isEmpty
            ? (q['table'] ?? q['table_id'] ?? q['tableId'] ?? tableToken)
            : tableToken;
      } catch (_) {}

      if ((restaurantId.isEmpty || tableToken.isEmpty) && kIsWeb) {
        try {
          final href = currentWindowHref();
          if (href != null) {
            final p = Uri.parse(href).queryParameters;
            restaurantId = restaurantId.isEmpty
                ? (p['restaurant_id'] ?? p['restaurantId'] ?? restaurantId)
                : restaurantId;
            tableToken = tableToken.isEmpty
                ? (p['table'] ?? p['table_id'] ?? p['tableId'] ?? tableToken)
                : tableToken;
          }
        } catch (_) {}
      }
    }
    // No restaurant_id in the link: we have nothing valid to query the
    // backend with (it rejects made-up ids), so ask the visitor to scan
    // their table's QR code instead of guessing and showing a raw API error.
    if (restaurantId.isEmpty) {
      return MaterialApp(
        title: 'Commande à table',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const TableEntryScreen(),
      );
    }

    final resolvedTableNumber = int.tryParse(tableToken) ?? 1;
    final session = TableSessionEntity(
      restaurant: RestaurantEntity(id: restaurantId, name: 'Restaurant'),
      table: TableEntity(
        id: tableToken.isNotEmpty ? tableToken : 'default-table',
        number: resolvedTableNumber,
        restaurantId: restaurantId,
        isActive: true,
      ),
    );

    return MaterialApp(
      title: 'Commande à table',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MenuScreen(session: session),
    );
  }
}
