import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/order_status_timeline.dart';

void main() {
  testWidgets('Met en évidence le statut en préparation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderStatusTimeline(status: OrderStatus.enPreparation),
        ),
      ),
    );

    expect(find.text('EN_ATTENTE'), findsOneWidget);
    expect(find.text('EN_PREPARATION'), findsOneWidget);
    expect(find.text('PRETE'), findsOneWidget);
  });
}
