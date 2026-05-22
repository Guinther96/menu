import 'dart:async';

import 'package:table_ordering_client/features/ordering/data/models/menu_item.dart';
import 'package:table_ordering_client/features/ordering/data/models/order.dart';
import 'package:table_ordering_client/features/ordering/data/models/order_item.dart';
import 'package:table_ordering_client/features/ordering/data/models/restaurant.dart';
import 'package:table_ordering_client/features/ordering/data/models/table.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';

class OrderingMockDataSource {
  final List<MenuItem> _menu = const [
    MenuItem(
      id: 'm1',
      name: 'Burger Maison',
      description: 'Steak hache, cheddar, sauce maison',
      price: 12.9,
      category: 'Burgers',
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=900',
    ),
    MenuItem(
      id: 'm2',
      name: 'Salade Cesar',
      description: 'Poulet grille, croutons, parmesan',
      price: 10.5,
      category: 'Salades',
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900',
    ),
    MenuItem(
      id: 'm3',
      name: 'Pizza Truffe',
      description: 'Creme truffee, mozzarella, roquette',
      price: 16,
      category: 'Pizzas',
      isAvailable: false,
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=900',
    ),
    MenuItem(
      id: 'm4',
      name: 'Tiramisu',
      description: 'Cafe, mascarpone, cacao',
      price: 6.9,
      category: 'Desserts',
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=900',
    ),
    MenuItem(
      id: 'm5',
      name: 'Citronnade Maison',
      description: 'Citron frais et menthe',
      price: 4.2,
      category: 'Boissons',
      isAvailable: true,
    ),
  ];

  final Map<String, Order> _orders = {};

  Future<({Restaurant restaurant, Table table})> validateTable(
    String tableCode, {
    String? restaurantId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (tableCode.trim().isEmpty || !tableCode.contains('table')) {
      throw Exception('Code table invalide.');
    }

    return (
      restaurant: const Restaurant(id: 'r1', name: 'La Flamme Urbaine'),
      table: const Table(
        id: 't12',
        number: 12,
        restaurantId: 'r1',
        isActive: true,
      ),
    );
  }

  Future<List<MenuItem>> getMenu(String restaurantId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _menu;
  }

  Future<Order> createOrder({
    required String tableId,
    required List<OrderItem> items,
    String? globalNote,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final id =
        'CMD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = Order(
      id: id,
      tableId: tableId,
      items: items,
      createdAt: DateTime.now(),
      status: OrderStatus.enAttente,
      globalNote: globalNote,
      fees: 1.5,
    );

    _orders[id] = order;
    return order;
  }

  Future<Order> getOrderById(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final current = _orders[orderId];

    if (current == null) {
      throw Exception('Commande introuvable.');
    }

    final elapsedSeconds = DateTime.now()
        .difference(current.createdAt)
        .inSeconds;
    final status = _statusByElapsedSeconds(elapsedSeconds);

    final updated = Order(
      id: current.id,
      tableId: current.tableId,
      items: current.items,
      createdAt: current.createdAt,
      status: status,
      globalNote: current.globalNote,
      fees: current.fees,
    );

    _orders[orderId] = updated;
    return updated;
  }

  Stream<Order> watchOrderStatus(
    String orderId, {
    Duration interval = const Duration(seconds: 5),
  }) {
    return Stream.periodic(
      interval,
    ).asyncMap((_) => getOrderById(orderId)).startWith(getOrderById(orderId));
  }

  OrderStatus _statusByElapsedSeconds(int elapsedSeconds) {
    if (elapsedSeconds < 10) return OrderStatus.enAttente;
    if (elapsedSeconds < 20) return OrderStatus.enPreparation;
    if (elapsedSeconds < 30) return OrderStatus.prete;
    if (elapsedSeconds < 45) return OrderStatus.livree;
    return OrderStatus.livree;
  }
}

extension<T> on Stream<T> {
  Stream<T> startWith(Future<T> firstValue) async* {
    yield await firstValue;
    yield* this;
  }
}
