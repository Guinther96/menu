import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:table_ordering_client/core/utils/currency_formatter.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';

final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

/// Construit le PDF du reçu à partir de la commande authoritative (items et
/// montants issus du backend, voir orderByIdProvider) et de la session de
/// table validée. Ne recalcule aucun montant : réutilise order.subTotal /
/// order.fees / order.total tels qu'exposés par OrderEntity.
Future<Uint8List> buildReceiptPdf({
  required OrderEntity order,
  required TableSessionEntity session,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Align(
          alignment: pw.Alignment.topCenter,
          child: pw.ConstrainedBox(
            constraints: const pw.BoxConstraints(maxWidth: 360),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  session.restaurant.name,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Table ${session.table.number}',
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Commande #${order.id}',
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _dateTimeFormat.format(order.createdAt),
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                ...order.items.map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('${item.name} × ${item.quantity}'),
                              pw.Text(
                                '${formatPrice(item.unitPrice)} / unité',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(formatPrice(item.lineTotal)),
                      ],
                    ),
                  ),
                ),
                pw.Divider(),
                _amountRow('Sous-total', formatPrice(order.subTotal)),
                pw.SizedBox(height: 4),
                _amountRow('Frais', formatPrice(order.fees)),
                pw.Divider(),
                _amountRow(
                  'TOTAL',
                  formatPrice(order.total),
                  bold: true,
                  fontSize: 14,
                ),
                pw.SizedBox(height: 16),
                _amountRow('Statut', order.status.label),
              ],
            ),
          ),
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _amountRow(
  String label,
  String value, {
  bool bold = false,
  double fontSize = 11,
}) {
  final style = pw.TextStyle(
    fontSize: fontSize,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: style),
      pw.Text(value, style: style),
    ],
  );
}
