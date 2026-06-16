import 'package:intl/intl.dart';

final NumberFormat _currency = NumberFormat.currency(
  locale: 'fr_HT',
  name: 'HTG',
  symbol: 'G',
  decimalDigits: 2,
);

String formatPrice(double value) => _currency.format(value);
