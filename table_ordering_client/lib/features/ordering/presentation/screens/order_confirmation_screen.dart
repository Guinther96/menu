import 'package:flutter/material.dart';
import 'package:table_ordering_client/core/utils/currency_formatter.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/order_tracking_screen.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    required this.order,
    required this.session,
    super.key,
  });

  final OrderEntity order;
  final TableSessionEntity session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commande confirmée')),
      body: ResponsiveScaffoldBody(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'Commande envoyée !',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Numéro de commande: ${order.id}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Total: ${formatPrice(order.total)}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderId: order.id,
                      session: session,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.radar_rounded),
              label: const Text('Suivre ma commande'),
            ),
          ],
        ),
      ),
    );
  }
}
