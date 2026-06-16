import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/utils/currency_formatter.dart';
import 'package:table_ordering_client/core/widgets/empty_state.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/order_confirmation_screen.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/cart_summary_card.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/quantity_selector.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({required this.session, super.key});

  final TableSessionEntity session;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _orderNoteController = TextEditingController();

  @override
  void dispose() {
    _orderNoteController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) return;

    ref
        .read(cartProvider.notifier)
        .setOrderNote(_orderNoteController.text.trim());

    final order = await ref
        .read(createOrderProvider.notifier)
        .create(
          tableId: widget.session.table.id,
          items: cart.items,
          globalNote: _orderNoteController.text.trim().isEmpty
              ? null
              : _orderNoteController.text.trim(),
        );

    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création de commande')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commande envoyée avec succès')),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            OrderConfirmationScreen(order: order, session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final creationState = ref.watch(createOrderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Votre panier')),
      body: ResponsiveScaffoldBody(
        child: cart.items.isEmpty
            ? const EmptyState(
                title: 'Panier vide',
                message: 'Ajoutez des plats pour valider votre commande.',
              )
            : ListView(
                children: [
                  const SizedBox(height: 10),
                  ...cart.items.map(
                    (item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(formatPrice(item.menuItem.price)),
                                  if ((item.note ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Note: ${item.note}'),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            QuantitySelector(
                              quantity: item.quantity,
                              compact: true,
                              onMinus: () => ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                    item.menuItem.id,
                                    item.quantity - 1,
                                  ),
                              onPlus: () => ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                    item.menuItem.id,
                                    item.quantity + 1,
                                  ),
                            ),
                            IconButton(
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .remove(item.menuItem.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _orderNoteController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note générale commande',
                      hintText: 'Ex: servir les boissons en premier',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CartSummaryCard(
                    subTotal: cart.subTotal,
                    fees: cart.fees,
                    total: cart.total,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: creationState.isLoading ? null : _confirmOrder,
                    child: creationState.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirmer la commande'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
