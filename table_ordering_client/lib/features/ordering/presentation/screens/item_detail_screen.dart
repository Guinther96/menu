import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/utils/currency_formatter.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/quantity_selector.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({required this.item, super.key});

  final MenuItemEntity item;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: ResponsiveScaffoldBody(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 240,
                child: widget.item.imageUrl != null
                    ? Image.network(
                        widget.item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.12),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.local_dining_rounded,
                              size: 64,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        alignment: Alignment.center,
                        child: const Icon(Icons.local_dining_rounded, size: 64),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.item.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              formatPrice(widget.item.price),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            QuantitySelector(
              quantity: _quantity,
              onMinus: () =>
                  setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
              onPlus: () => setState(() => _quantity += 1),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note spéciale',
                hintText: 'Ex: sans oignon, sauce à part',
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: widget.item.isAvailable
                  ? () {
                      ref
                          .read(cartProvider.notifier)
                          .add(
                            widget.item,
                            quantity: _quantity,
                            note: _noteController.text.trim().isEmpty
                                ? null
                                : _noteController.text.trim(),
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.item.name} ajouté au panier'),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Ajouter au panier'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
