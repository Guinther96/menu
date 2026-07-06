import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/theme/app_theme.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/restaurant_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/menu_screen.dart';
import 'package:table_ordering_client/services/order_client_providers.dart';

void main() {
  runApp(const ProviderScope(child: RestaurantClientApp()));
}

class RestaurantClientApp extends ConsumerWidget {
  const RestaurantClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantId = ref.watch(restaurantIdProvider).trim();
    final resolvedRestaurantId = restaurantId.isEmpty ? 'demo-restaurant' : restaurantId;
    final session = TableSessionEntity(
      restaurant: RestaurantEntity(
        id: resolvedRestaurantId,
        name: 'Restaurant',
      ),
      table: TableEntity(
        id: 'default-table',
        number: 1,
        restaurantId: resolvedRestaurantId,
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
