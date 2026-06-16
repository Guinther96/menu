import 'package:table_ordering_client/features/ordering/domain/entities/order_item_entity.dart';

enum OrderStatus { enAttente, enPreparation, prete, livree, annulee }

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.tableId,
    required this.items,
    required this.createdAt,
    required this.status,
    this.globalNote,
    this.fees = 0,
  });

  final String id;
  final String tableId;
  final List<OrderItemEntity> items;
  final DateTime createdAt;
  final OrderStatus status;
  final String? globalNote;
  final double fees;

  double get subTotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  double get total => subTotal + fees;
}
