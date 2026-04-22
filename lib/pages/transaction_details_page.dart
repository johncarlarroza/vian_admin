import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const TransactionDetailsPage({
    super.key,
    required this.data,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkText = Color(0xFF1F2A24);
  static const Color softText = Color(0xFF6E7C74);
  static const Color borderColor = Color(0xFFDDE9E1);

  bool _exportingPdf = false;

  Map<String, dynamic> get data => widget.data;

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List?) ?? [];
    final createdAt = data['createdAt'];
    final DateTime? dateTime =
        createdAt is Timestamp ? createdAt.toDate() : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _exportingPdf ? null : _exportPdf,
              icon: _exportingPdf
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(_exportingPdf ? 'Exporting...' : 'Export PDF'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopCard(dateTime),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 820) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildItemsCard(items),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                _buildCustomerCard(),
                                const SizedBox(height: 16),
                                _buildPaymentCard(),
                                const SizedBox(height: 16),
                                _buildMetaCard(dateTime),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildCustomerCard(),
                        const SizedBox(height: 16),
                        _buildPaymentCard(),
                        const SizedBox(height: 16),
                        _buildMetaCard(dateTime),
                        const SizedBox(height: 16),
                        _buildItemsCard(items),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _exportingPdf = true);

    try {
      final pdf = await _buildPdfDocument();

      await Printing.layoutPdf(
        name: '${(data['orderNumber'] ?? 'transaction').toString()}.pdf',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF ready for download/print.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exportingPdf = false);
      }
    }
  }

  Future<pw.Document> _buildPdfDocument() async {
    final pdf = pw.Document();

    Uint8List? logoBytes;
    try {
      final logo = await rootBundle.load('assets/logo.png');
      logoBytes = logo.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    final items = (data['items'] as List?) ?? [];
    final createdAt = data['createdAt'];
    final DateTime? dateTime =
        createdAt is Timestamp ? createdAt.toDate() : null;

    final total = _toDouble(data['total']);
    final totalItems = _toInt(data['totalItems']);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoBytes != null)
                pw.Container(
                  width: 54,
                  height: 54,
                  margin: const pw.EdgeInsets.only(right: 14),
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VIAN CAFÉ',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Transaction Receipt / Admin Copy',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  (data['status'] ?? 'unknown').toString().toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 18),
          pw.Divider(),

          pw.SizedBox(height: 10),
          pw.Text(
            'Transaction Information',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          _pdfInfoRow('Order Number', (data['orderNumber'] ?? '-').toString()),
          _pdfInfoRow(
            'Customer Name',
            (data['customerName'] ?? 'Walk-in Customer').toString(),
          ),
          _pdfInfoRow(
            'Order Type',
            _formatOrderType((data['orderType'] ?? '').toString()),
          ),
          _pdfInfoRow(
            'Payment Method',
            (data['paymentMethod'] ?? '-').toString().toUpperCase(),
          ),
          _pdfInfoRow(
            'Payment Status',
            (data['paymentStatus'] ?? '-').toString(),
          ),
          _pdfInfoRow('Total Items', '$totalItems'),
          _pdfInfoRow(
            'Created At',
            dateTime == null ? 'No date available' : _formatDateTime(dateTime),
          ),

          pw.SizedBox(height: 18),
          pw.Text(
            'Ordered Items',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
            columnWidths: {
              0: const pw.FlexColumnWidth(3.2),
              1: const pw.FlexColumnWidth(1.8),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.6),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _pdfTableCell('Item', isHeader: true),
                  _pdfTableCell('Variant', isHeader: true),
                  _pdfTableCell('Qty', isHeader: true),
                  _pdfTableCell('Unit Price', isHeader: true),
                  _pdfTableCell('Subtotal', isHeader: true),
                ],
              ),
              ...items.map((item) {
                final map = item as Map;
                final name = (map['name'] ?? 'Unknown Item').toString();
                final variant = _prettyVariant((map['variant'] ?? '').toString());
                final quantity = _toInt(map['quantity']);
                final unitPrice = _toDouble(map['unitPrice']);
                final subtotal = _toDouble(map['subtotal']);

                return pw.TableRow(
                  children: [
                    _pdfTableCell(name),
                    _pdfTableCell(variant),
                    _pdfTableCell('$quantity'),
                    _pdfTableCell('${unitPrice.toStringAsFixed(2)}'),
                    _pdfTableCell('${subtotal.toStringAsFixed(2)}'),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 16),

          ...items.map((item) {
            final map = item as Map;
            final note = (map['note'] ?? '').toString().trim();
            final name = (map['name'] ?? 'Unknown Item').toString();

            if (note.isEmpty) {
              return pw.SizedBox();
            }

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: '$name note: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(text: note),
                  ],
                ),
              ),
            );
          }),

          pw.SizedBox(height: 14),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 220,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _pdfSummaryRow('Total Items', '$totalItems'),
                  pw.SizedBox(height: 8),
                  _pdfSummaryRow(
                    'Grand Total',
                    '${total.toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 6),
          pw.Text(
            'Generated from VIAN Café Admin System',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryRow(String label, String value, {bool bold = false}) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(label)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTopCard(DateTime? dateTime) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: primaryGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data['orderNumber'] ?? '-').toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateTime == null
                      ? 'No date available'
                      : _formatDateTime(dateTime),
                  style: const TextStyle(
                    color: softText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _statusChip((data['status'] ?? 'unknown').toString()),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return _sectionCard(
      title: 'Customer & Order Info',
      child: Column(
        children: [
          _infoRow(
            'Customer',
            (data['customerName'] ?? 'Walk-in Customer').toString(),
          ),
          _infoRow(
            'Order Type',
            _formatOrderType((data['orderType'] ?? '').toString()),
          ),
          _infoRow('Total Items', '${data['totalItems'] ?? 0}'),
          _infoRow('Day', (data['day'] ?? '-').toString()),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return _sectionCard(
      title: 'Payment Info',
      child: Column(
        children: [
          _infoRow(
            'Payment Method',
            (data['paymentMethod'] ?? '-').toString().toUpperCase(),
          ),
          _infoRow(
            'Payment Status',
            (data['paymentStatus'] ?? '-').toString(),
          ),
          _infoRow(
            'Total',
            '${_toDouble(data['total']).toStringAsFixed(2)}',
            valueColor: primaryGreen,
            boldValue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(DateTime? dateTime) {
    return _sectionCard(
      title: 'Transaction Meta',
      child: Column(
        children: [
          _infoRow('Transaction ID', (data['transactionId'] ?? '-').toString()),
          _infoRow('Month', (data['month'] ?? '-').toString()),
          _infoRow('Year', (data['year'] ?? '-').toString()),
          _infoRow(
            'Created At',
            dateTime == null ? 'No date available' : _formatDateTime(dateTime),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List items) {
    return _sectionCard(
      title: 'Ordered Items',
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No items found.',
                  style: TextStyle(
                    color: softText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                ...items.map((item) {
                  final map = item as Map;
                  final name = (map['name'] ?? 'Unknown Item').toString();
                  final variant = (map['variant'] ?? '').toString();
                  final quantity = map['quantity'] ?? 0;
                  final unitPrice = _toDouble(map['unitPrice']);
                  final subtotal = _toDouble(map['subtotal']);
                  final note = (map['note'] ?? '').toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: darkText,
                                  fontSize: 15.5,
                                ),
                              ),
                            ),
                            Text(
                              '${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: primaryGreen,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _smallTag('Variant: ${_prettyVariant(variant)}'),
                            _smallTag('Qty: $quantity'),
                            _smallTag('${unitPrice.toStringAsFixed(2)} each'),
                          ],
                        ),
                        if (note.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Note: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  note,
                                  style: const TextStyle(
                                    color: softText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Row(
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: darkText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_toDouble(data['total']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = darkText,
    bool boldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: softText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontWeight: boldValue ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();

    Color bgColor;
    Color fgColor;

    if (s == 'completed') {
      bgColor = const Color(0xFFEAF6EF);
      fgColor = primaryGreen;
    } else if (s == 'pending') {
      bgColor = const Color(0xFFFFF5E8);
      fgColor = const Color(0xFFD9A441);
    } else if (s == 'cancelled') {
      bgColor = const Color(0xFFFFEFEF);
      fgColor = const Color(0xFFD05C5C);
    } else {
      bgColor = const Color(0xFFF1F3F4);
      fgColor = softText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  static String _formatOrderType(String value) {
    return value == 'dine_in'
        ? 'Dine-In'
        : value == 'takeout'
            ? 'Takeout'
            : value;
  }

  static String _prettyVariant(String variant) {
    switch (variant) {
      case 'hot':
        return 'Hot';
      case 'iced12':
        return 'Iced 12oz';
      case 'iced16':
        return 'Iced 16oz';
      case 'regular':
        return 'Regular';
      case 'large':
        return 'Large';
      case 'withDrink':
        return 'With Drink';
      case 'slice':
        return 'Slice';
      default:
        return variant.replaceAll('_', ' ');
    }
  }

  static String _formatDateTime(DateTime dt) {
    final yyyy = dt.year.toString();
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');

    final hour = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final meridiem = dt.hour >= 12 ? 'PM' : 'AM';

    return '$yyyy-$mm-$dd • $hour:$min $meridiem';
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}