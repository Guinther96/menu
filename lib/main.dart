import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/theme/app_theme.dart';
import 'package:table_ordering_client/features/table_entry/presentation/screens/table_entry_screen.dart';

void main() {
  runApp(const ProviderScope(child: RestaurantClientApp()));
}

class RestaurantClientApp extends ConsumerWidget {
  const RestaurantClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TableEntryScreen reads restaurant_id/table token from the URL itself,
    // calls the backend to validate the table (so we get the real table id
    // instead of trusting the raw QR/link token), and auto-navigates to the
    // menu as soon as validation succeeds. Building a TableSessionEntity
    // locally here — bypassing that backend validation — was the cause of
    // order creation failing: the fabricated table id doesn't exist in the
    // backend's tables table, so POST /orders gets rejected.
    return MaterialApp(
      title: 'Commande à table',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TableEntryScreen(),
    );
  }
}
