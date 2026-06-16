import 'package:flutter/material.dart';
import 'package:table_ordering_client/core/utils/currency_formatter.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/quantity_selector.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    required this.item,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onMinus,
    required this.onPlus,
    super.key,
  });

  final MenuItemEntity item;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                              child: const Icon(Icons.fastfood_rounded),
                            );
                          },
                        )
                      : Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.12),
                          child: const Icon(Icons.fastfood_rounded),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(
                          label: Text(item.category),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        Text(
                          formatPrice(item.price),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              item.isAvailable
                  ? quantity == 0
                        ? ElevatedButton(
                            onPressed: onAdd,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(70, 40),
                            ),
                            child: const Text('Ajouter'),
                          )
                        : QuantitySelector(
                            quantity: quantity,
                            onMinus: onMinus,
                            onPlus: onPlus,
                            compact: true,
                          )
                  : const Chip(
                      label: Text('Indisponible'),
                      backgroundColor: Color(0xFFFFEEE8),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
