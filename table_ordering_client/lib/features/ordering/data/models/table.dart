import 'package:table_ordering_client/features/ordering/domain/entities/table_entity.dart';

class Table {
  const Table({
    required this.id,
    required this.number,
    required this.restaurantId,
    required this.isActive,
  });

  final String id;
  final int number;
  final String restaurantId;
  final bool isActive;

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'] as String,
      number: json['number'] as int,
      restaurantId: json['restaurantId'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  TableEntity toEntity() => TableEntity(
    id: id,
    number: number,
    restaurantId: restaurantId,
    isActive: isActive,
  );
}
