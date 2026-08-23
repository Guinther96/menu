import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:table_ordering_client/core/utils/currency_formatter.dart';
import 'package:table_ordering_client/core/widgets/error_state.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/utils/receipt_pdf_builder.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';

/// Affiche le reçu de la commande [orderId] et permet de le télécharger ou
/// de le partager en PDF. La commande est re-chargée via
/// [orderByIdProvider] (GET /orders/:id, même mécanisme d'accès que
/// OrderTrackingScreen) afin d'obtenir les articles et montants réels
/// validés par le backend plutôt que ceux du panier local.
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({required this.orderId, required this.session, super.key});

  final String orderId;
  final TableSessionEntity session;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _isProcessingPdf = false;

  Future<void> _downloadPdf(OrderEntity order) => _withPdf(
    order,
    (bytes) => Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'recu_commande_${order.id}.pdf',
    ),
  );

  Future<void> _sharePdf(OrderEntity order) => _withPdf(
    order,
    (bytes) => Printing.sharePdf(
      bytes: bytes,
      filename: 'recu_commande_${order.id}.pdf',
    ),
  );

  Future<void> _withPdf(
    OrderEntity order,
    Future<void> Function(Uint8List bytes) action,
  ) async {
    if (_isProcessingPdf) return;
    setState(() => _isProcessingPdf = true);
    try {
      final bytes = await buildReceiptPdf(order: order, session: widget.session);
      await action(bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de générer le reçu PDF. Réessayez.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderByIdProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Reçu de commande')),
      body: ResponsiveScaffoldBody(
        child: orderState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref.refresh(orderByIdProvider(widget.orderId)),
          ),
          data: (order) => ListView(
            children: [
              const SizedBox(height: 10),
              _ReceiptCard(order: order, session: widget.session),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _isProcessingPdf ? null : () => _downloadPdf(order),
                icon: _isProcessingPdf
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Télécharger le PDF'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isProcessingPdf ? null : () => _sharePdf(order),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Partager'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.order, required this.session});

  final OrderEntity order;
  final TableSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              session.restaurant.name,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Table ${session.table.number}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Commande #${order.id}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(order.createdAt),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.name} × ${item.quantity}'),
                          Text(
                            '${formatPrice(item.unitPrice)} / unité',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(formatPrice(item.lineTotal)),
                  ],
                ),
              ),
            ),
            const Divider(),
            _line(context, 'Sous-total', formatPrice(order.subTotal)),
            const SizedBox(height: 6),
            _line(context, 'Frais', formatPrice(order.fees)),
            const Divider(),
            _line(
              context,
              'TOTAL',
              formatPrice(order.total),
              highlight: true,
            ),
            const SizedBox(height: 12),
            _line(context, 'Statut', order.status.label),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dateTime.day)}/${two(dateTime.month)}/${dateTime.year} '
        '${two(dateTime.hour)}:${two(dateTime.minute)}';
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
