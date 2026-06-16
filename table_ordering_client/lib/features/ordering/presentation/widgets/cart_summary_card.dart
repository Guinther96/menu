import 'package:flutter/material.dart';
import 'package:table_ordering_client/core/utils/currency_formatter.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    required this.subTotal,
    required this.fees,
    required this.total,
    super.key,
  });

  final double subTotal;
  final double fees;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _line(context, 'Sous-total', formatPrice(subTotal)),
            const SizedBox(height: 8),
            _line(context, 'Frais', formatPrice(fees)),
            const Divider(height: 26),
            _line(context, 'Total', formatPrice(total), highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    final style = highlight
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
