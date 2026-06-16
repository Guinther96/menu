import 'package:flutter/material.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (OrderStatus.enAttente, 'EN_ATTENTE', Icons.schedule_rounded),
      (OrderStatus.enPreparation, 'EN_PREPARATION', Icons.soup_kitchen_rounded),
      (OrderStatus.prete, 'PRETE', Icons.done_all_rounded),
      (OrderStatus.livree, 'LIVREE', Icons.delivery_dining_rounded),
      (OrderStatus.annulee, 'ANNULEE', Icons.cancel_rounded),
    ];

    final activeIndex = steps.indexWhere((step) => step.$1 == status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _TimelineRow(
                label: steps[i].$2,
                icon: steps[i].$3,
                isActive: i <= activeIndex,
                isCurrent: i == activeIndex,
                isCancelled: status == OrderStatus.annulee,
              ),
              if (i < steps.length - 1)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  width: 2,
                  height: 24,
                  color: i < activeIndex
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
    required this.isCancelled,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    final color = isCancelled
        ? Colors.redAccent
        : isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style:
                (isCurrent
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.bodyMedium) ??
                const TextStyle(),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}
