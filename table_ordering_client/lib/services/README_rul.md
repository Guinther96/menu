Flutter Client Order Kit

Files
- order_client_api_service.dart
- order_client_providers.dart

This kit provides the 3 methods you requested:
1) fetchMenu(restaurantId)
2) fetchTables(restaurantId)
3) createOrder(tableId, items)

Required dependencies in pubspec.yaml
- http: ^1.2.2
- flutter_riverpod: already in your project

Quick use example

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_client_api_service.dart';
import 'order_client_providers.dart';

class ClientOrderExample extends ConsumerStatefulWidget {
  const ClientOrderExample({super.key});

  @override
  ConsumerState<ClientOrderExample> createState() => _ClientOrderExampleState();
}

class _ClientOrderExampleState extends ConsumerState<ClientOrderExample> {
  String? selectedTableId;
  final Map<String, int> cart = <String, int>{};

  Future<void> _submitOrder() async {
    final service = ref.read(orderClientApiServiceProvider);

    if (selectedTableId == null || cart.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose table and add items')),
      );
      return;
    }

    final items = cart.entries
        .where((e) => e.value > 0)
        .map((e) => CreateOrderItemInput(menuItemId: e.key, quantity: e.value))
        .toList();

    try {
      await service.createOrder(tableId: selectedTableId!, items: items);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order sent to kitchen')),
      );
      setState(() => cart.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuProvider);
    final tablesAsync = ref.watch(tablesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Client Order')),
      body: Column(
        children: [
          tablesAsync.when(
            data: (tables) {
              return DropdownButton<String>(
                value: selectedTableId,
                hint: const Text('Choose table'),
                items: tables
                    .map(
                      (t) => DropdownMenuItem<String>(
                        value: t.id,
                        child: Text('Table ${t.number}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedTableId = value),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Tables error: $e'),
          ),
          Expanded(
            child: menuAsync.when(
              data: (menu) {
                final available = menu.where((m) => m.isAvailable).toList();
                return ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, i) {
                    final item = available[i];
                    final qty = cart[item.id] ?? 0;

                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.price.toStringAsFixed(2)} EUR'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                final next = (cart[item.id] ?? 0) - 1;
                                if (next <= 0) {
                                  cart.remove(item.id);
                                } else {
                                  cart[item.id] = next;
                                }
                              });
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$qty'),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                cart[item.id] = (cart[item.id] ?? 0) + 1;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Menu error: $e'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitOrder,
                child: const Text('Send order'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
