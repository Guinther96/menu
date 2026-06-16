import 'package:flutter_test/flutter_test.dart';
import 'package:table_ordering_client/features/ordering/data/models/order.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';

void main() {
  test('Map status variants to enPreparation', () {
    final variants = <String>[
      'EN_PREPARATION',
      'en preparation',
      'en-preparation',
      'preparing',
      'in_progress',
    ];

    for (final value in variants) {
      final order = Order.fromJson({
        'id': '1',
        'tableId': 'T1',
        'items': <Map<String, dynamic>>[],
        'createdAt': DateTime.now().toIso8601String(),
        'status': value,
      });

      expect(order.status, OrderStatus.enPreparation);
    }
  });

  test('Map status variants to annulee', () {
    final variants = <String>[
      'ANNULEE',
      'annule',
      'canceled',
      'cancelled',
      'rejected',
    ];

    for (final value in variants) {
      final order = Order.fromJson({
        'id': '1',
        'tableId': 'T1',
        'items': <Map<String, dynamic>>[],
        'createdAt': DateTime.now().toIso8601String(),
        'status': value,
      });

      expect(order.status, OrderStatus.annulee);
    }
  });
}
