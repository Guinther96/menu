import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/cart_summary_card.dart';

void main() {
  testWidgets('Affiche correctement sous-total, frais et total', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CartSummaryCard(subTotal: 20, fees: 1.5, total: 21.5),
        ),
      ),
    );

    expect(find.text('Sous-total'), findsOneWidget);
    expect(find.text('Frais'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.textContaining('21'), findsWidgets);
  });
}
