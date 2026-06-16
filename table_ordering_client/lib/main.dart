import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/theme/app_theme.dart';
import 'package:table_ordering_client/features/table_entry/presentation/screens/table_entry_screen.dart';

void main() {
  runApp(const ProviderScope(child: RestaurantClientApp()));
}

class RestaurantClientApp extends StatelessWidget {
  const RestaurantClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commande à table',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TableEntryScreen(),
    );
  }
}
