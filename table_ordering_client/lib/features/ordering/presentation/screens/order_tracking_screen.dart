import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/widgets/error_state.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/order_status_timeline.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({
    required this.orderId,
    required this.session,
    super.key,
  });

  final String orderId;
  final TableSessionEntity session;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${minutes}m ${seconds}s';
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.enAttente:
        return 'EN_ATTENTE';
      case OrderStatus.enPreparation:
        return 'EN_PREPARATION';
      case OrderStatus.prete:
        return 'PRETE';
      case OrderStatus.livree:
        return 'LIVREE';
      case OrderStatus.annulee:
        return 'ANNULEE';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderStatusStreamProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text('Suivi commande $orderId')),
      body: ResponsiveScaffoldBody(
        child: orderState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref.refresh(orderStatusStreamProvider(orderId)),
          ),
          data: (order) {
            final elapsedState = ref.watch(
              elapsedTimeProvider(order.createdAt),
            );
            final elapsed = elapsedState.valueOrNull ?? Duration.zero;

            return ListView(
              children: [
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.restaurant.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('Table ${session.table.number}'),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          child: Chip(
                            key: ValueKey(order.status),
                            label: Text(_statusLabel(order.status)),
                            avatar: const Icon(
                              Icons.timelapse_rounded,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Temps écoulé: ${_formatDuration(elapsed)}'),
                        const SizedBox(height: 4),
                        const Text(
                          'Rafraîchissement automatique toutes les 5 secondes.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OrderStatusTimeline(status: order.status),
              ],
            );
          },
        ),
      ),
    );
  }
}
