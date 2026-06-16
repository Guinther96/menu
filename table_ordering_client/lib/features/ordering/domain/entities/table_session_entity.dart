import 'package:table_ordering_client/features/ordering/domain/entities/restaurant_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_entity.dart';

class TableSessionEntity {
  const TableSessionEntity({required this.restaurant, required this.table});

  final RestaurantEntity restaurant;
  final TableEntity table;
}
