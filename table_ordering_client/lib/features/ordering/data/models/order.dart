import 'package:table_ordering_client/features/ordering/data/models/order_item.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';

class Order {
  const Order({
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
  final List<OrderItem> items;
  final DateTime createdAt;
  final OrderStatus status;
  final String? globalNote;
  final double fees;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    final rawStatus =
        json['status'] ?? json['order_status'] ?? json['orderStatus'] ?? json['state'];
    final rawTable = json['table'];
    final tableFromNested =
      rawTable is Map<String, dynamic> ? rawTable['id'] : null;

    return Order(
      id: (json['id'] ?? json['_id'] ?? json['orderId'] ?? '').toString(),
      tableId: (json['tableId'] ??
              json['table_id'] ??
          tableFromNested ??
              '')
          .toString(),
      items: (rawItems is List ? rawItems : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
          .toList(),
      createdAt: rawCreatedAt is String
          ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
          : DateTime.now(),
      status: _statusFromJson(rawStatus?.toString()),
      globalNote: (json['globalNote'] ?? json['global_note'])?.toString(),
        fees: _toDouble(json['fees']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'globalNote': globalNote,
      'fees': fees,
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      tableId: tableId,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      status: status,
      globalNote: globalNote,
      fees: fees,
    );
  }

  static OrderStatus _statusFromJson(String? value) {
    final normalized = _normalizeStatus(value);

    switch (normalized) {
      case 'ENATTENTE':
      case 'ATTENTE':
      case 'PENDING':
        return OrderStatus.enAttente;
      case 'ENPREPARATION':
      case 'PREPARATION':
      case 'PREPARING':
      case 'INPROGRESS':
        return OrderStatus.enPreparation;
      case 'PRET':
      case 'PRETE':
      case 'READY':
        return OrderStatus.prete;
      case 'DELIVERED':
      case 'LIVREE':
        return OrderStatus.livree;
      case 'ANNULE':
      case 'ANNULEE':
      case 'CANCELED':
      case 'CANCELLED':
      case 'REJECTED':
        return OrderStatus.annulee;
      default:
        return OrderStatus.enAttente;
    }
  }

  static String _normalizeStatus(String? value) {
    if (value == null) return '';

    return value
        .trim()
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('À', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ä', 'A')
        .replaceAll('Ù', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll('Î', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Ô', 'O')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C');
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim().replaceAll(',', '.').replaceAll(':', '.');
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }
}
