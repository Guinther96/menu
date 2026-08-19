// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:table_ordering_client/main.dart';

void main() {
  testWidgets('Demande de scanner un QR sans restaurant_id dans le lien', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RestaurantClientApp()));

    expect(find.text('Configuration requise'), findsOneWidget);
    expect(
      find.textContaining('Le lien QR doit contenir restaurant_id'),
      findsOneWidget,
    );
  });
}
