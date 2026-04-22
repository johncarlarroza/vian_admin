import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkText = Color(0xFF1F2A24);
  static const Color softText = Color(0xFF6E7C74);
  static const Color borderColor = Color(0xFFDDE9E1);
  static const Color danger = Color(0xFFD05C5C);
  static const Color gold = Color(0xFFD9A441);
  static const Color blue = Color(0xFF4B78D1);

  final GlobalKey _salesChartKey = GlobalKey();
  final GlobalKey _paymentsChartKey = GlobalKey();

  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      child: FutureBuilder<_ReportsData>(
        future: _loadReportsData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load reports: ${snapshot.error}',
                style: const TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(data),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopStats(data),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 1100;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: RepaintBoundary(
                                    key: _salesChartKey,
                                    child: _buildDailySalesChart(data),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 5,
                                  child: RepaintBoundary(
                                    key: _paymentsChartKey,
                                    child: _buildPaymentMethodChart(data),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              RepaintBoundary(
                                key: _salesChartKey,
                                child: _buildDailySalesChart(data),
                              ),
                              const SizedBox(height: 16),
                              RepaintBoundary(
                                key: _paymentsChartKey,
                                child: _buildPaymentMethodChart(data),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 1100;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildStatusBreakdown(data)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTopProducts(data)),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildStatusBreakdown(data),
                              const SizedBox(height: 16),
                              _buildTopProducts(data),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildRecentSummary(data),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_ReportsData> _loadReportsData() async {
    final firestore = FirebaseFirestore.instance;

    final txSnap = await firestore
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .get();

    final userSnap = await firestore.collection('users').get();

    return _ReportsData.fromSnapshots(
      transactions: txSnap.docs,
      users: userSnap.docs,
    );
  }

  Widget _buildHeader(_ReportsData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Overall business insights, charts, revenue, user activity, and downloadable PDF reports.',
                  style: TextStyle(
                    fontSize: 13,
                    color: softText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _exporting ? null : () => _exportPdf(data),
            style: FilledButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            icon: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_rounded),
            label: Text(_exporting ? 'Exporting...' : 'Export PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats(_ReportsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (constraints.maxWidth < 1300) crossAxisCount = 3;
        if (constraints.maxWidth < 850) crossAxisCount = 2;
        if (constraints.maxWidth < 560) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.9,
          children: [
            _statCard(
              'Users',
              '${data.totalUsers}',
              Icons.people_alt_rounded,
              blue,
            ),
            _statCard(
              'Transactions',
              '${data.totalTransactions}',
              Icons.receipt_long_rounded,
              primaryGreen,
            ),
            _statCard(
              'Paid Payments',
              '${data.paidPayments}',
              Icons.check_circle_rounded,
              primaryGreen,
            ),
            _statCard(
              'Revenue',
              '₱${data.totalRevenue.toStringAsFixed(2)}',
              Icons.account_balance_wallet_rounded,
              gold,
            ),
            _statCard(
              'Average Sale',
              '₱${data.averageSale.toStringAsFixed(2)}',
              Icons.trending_up_rounded,
              blue,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: softText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySalesChart(_ReportsData data) {
    final maxY = data.dailySales.isEmpty
        ? 100.0
        : data.dailySales.values.reduce((a, b) => a > b ? a : b) + 20;

    final labels = data.dailySales.keys.toList();
    final values = data.dailySales.values.toList();

    return Container(
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
          const Text(
            'Daily Sales Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revenue for the last 7 recorded days.',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxY / 5,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₱${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: softText,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: softText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    spots: List.generate(
                      values.length,
                      (index) => FlSpot(index.toDouble(), values[index]),
                    ),
                    color: primaryGreen,
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryGreen.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChart(_ReportsData data) {
    final items = [
      _BarPoint('Cash', data.cashRevenue, gold),
      _BarPoint('GCash', data.gcashRevenue, blue),
    ];

    final maxY = items.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b) + 20;

    return Container(
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
          const Text(
            'Payment Method Revenue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revenue split by payment channel.',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (maxY <= 0 ? 100 : maxY) / 5,
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₱${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: softText,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= items.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            items[index].label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: softText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  items.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: items[index].value,
                        width: 28,
                        borderRadius: BorderRadius.circular(8),
                        color: items[index].color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(_ReportsData data) {
    final items = [
      _statusRow('Pending', data.pendingOrders, gold),
      _statusRow('Preparing', data.preparingOrders, blue),
      _statusRow('Completed', data.completedOrders, primaryGreen),
      _statusRow('Cancelled', data.cancelledOrders, danger),
    ];

    return Container(
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
          const Text(
            'Order Status Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Current order distribution based on saved statuses.',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ...items,
        ],
      ),
    );
  }

  Widget _statusRow(String label, int value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
            child: const Icon(Icons.pie_chart_rounded, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: darkText,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(_ReportsData data) {
    return Container(
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
          const Text(
            'Top Selling Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Most purchased items from transaction item records.',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          if (data.topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No product sales data yet.',
                style: TextStyle(
                  color: softText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            ...data.topProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryGreen.withOpacity(0.12),
                      foregroundColor: primaryGreen,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                    ),
                    Text(
                      '${item.qty} sold',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentSummary(_ReportsData data) {
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
          const Text(
            'Report Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This report currently shows ${data.totalUsers} registered users, ${data.totalTransactions} transactions, ₱${data.totalRevenue.toStringAsFixed(2)} total paid revenue, and ${data.completedOrders} completed orders. Cash revenue is ₱${data.cashRevenue.toStringAsFixed(2)}, while GCash revenue is ₱${data.gcashRevenue.toStringAsFixed(2)}.',
            style: const TextStyle(
              color: softText,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(_ReportsData data) async {
    setState(() => _exporting = true);

    try {
      final salesChartBytes = await _captureChart(_salesChartKey);
      final paymentChartBytes = await _captureChart(_paymentsChartKey);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) => [
            pw.Text(
              'VIAN CAFÉ - REPORTS & ANALYTICS',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Generated report summary',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _pdfRow('Total Users', '${data.totalUsers}'),
                  _pdfRow('Total Transactions', '${data.totalTransactions}'),
                  _pdfRow('Paid Payments', '${data.paidPayments}'),
                  _pdfRow('Total Revenue', '₱${data.totalRevenue.toStringAsFixed(2)}'),
                  _pdfRow('Cash Revenue', '₱${data.cashRevenue.toStringAsFixed(2)}'),
                  _pdfRow('GCash Revenue', '₱${data.gcashRevenue.toStringAsFixed(2)}'),
                  _pdfRow('Average Sale', '₱${data.averageSale.toStringAsFixed(2)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Order Status Breakdown',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Pending: ${data.pendingOrders}'),
            pw.Bullet(text: 'Preparing: ${data.preparingOrders}'),
            pw.Bullet(text: 'Completed: ${data.completedOrders}'),
            pw.Bullet(text: 'Cancelled: ${data.cancelledOrders}'),
            pw.SizedBox(height: 18),
            if (salesChartBytes != null) ...[
              pw.Text(
                'Daily Sales Trend',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(salesChartBytes), height: 220),
              pw.SizedBox(height: 16),
            ],
            if (paymentChartBytes != null) ...[
              pw.Text(
                'Payment Method Revenue',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(paymentChartBytes), height: 220),
              pw.SizedBox(height: 16),
            ],
            pw.Text(
              'Top Products',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (data.topProducts.isEmpty)
              pw.Text('No product sales data yet.')
            else
              ...data.topProducts.take(8).map(
                    (item) => pw.Bullet(text: '${item.name} - ${item.qty} sold'),
                  ),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: 'vian_reports.pdf',
        onLayout: (format) async => pdf.save(),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  Future<Uint8List?> _captureChart(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}

class _ReportsData {
  final int totalUsers;
  final int totalTransactions;
  final int paidPayments;
  final int pendingOrders;
  final int preparingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double cashRevenue;
  final double gcashRevenue;
  final double averageSale;
  final Map<String, double> dailySales;
  final List<_TopProductItem> topProducts;

  const _ReportsData({
    required this.totalUsers,
    required this.totalTransactions,
    required this.paidPayments,
    required this.pendingOrders,
    required this.preparingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.cashRevenue,
    required this.gcashRevenue,
    required this.averageSale,
    required this.dailySales,
    required this.topProducts,
  });

  factory _ReportsData.fromSnapshots({
    required List<QueryDocumentSnapshot> transactions,
    required List<QueryDocumentSnapshot> users,
  }) {
    int paidPayments = 0;
    int pendingOrders = 0;
    int preparingOrders = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;

    double totalRevenue = 0;
    double cashRevenue = 0;
    double gcashRevenue = 0;

    final Map<String, double> dayMap = {};
    final Map<String, int> productQty = {};

    for (final doc in transactions) {
      final data = doc.data() as Map<String, dynamic>;

      final total = _toDouble(data['total']);
      final status = (data['status'] ?? '').toString().toLowerCase();
      final paymentMethod = (data['paymentMethod'] ?? '').toString().toLowerCase();
      final paymentStatus = (data['paymentStatus'] ?? '').toString().toLowerCase();

      if (status == 'pending') pendingOrders++;
      if (status == 'preparing') preparingOrders++;
      if (status == 'completed') completedOrders++;
      if (status == 'cancelled') cancelledOrders++;

      if (paymentStatus == 'paid') {
        paidPayments++;
        totalRevenue += total;

        if (paymentMethod == 'cash') {
          cashRevenue += total;
        } else if (paymentMethod == 'gcash') {
          gcashRevenue += total;
        }
      }

      final createdAt = data['createdAt'];
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        final key = _shortDate(dt);
        dayMap[key] = (dayMap[key] ?? 0) + total;
      }

      final items = data['items'];
      if (items is List) {
        for (final item in items) {
          if (item is Map) {
            final name = (item['name'] ?? 'Unknown Item').toString();
            final qty = _toInt(item['quantity']);
            productQty[name] = (productQty[name] ?? 0) + qty;
          }
        }
      }
    }

    final sortedDays = dayMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final last7 = sortedDays.length > 7
        ? sortedDays.sublist(sortedDays.length - 7)
        : sortedDays;

    final dailySales = {
      for (final entry in last7) entry.key: entry.value,
    };

    final topProducts = productQty.entries
        .map((e) => _TopProductItem(name: e.key, qty: e.value))
        .toList()
      ..sort((a, b) => b.qty.compareTo(a.qty));

    final avg = paidPayments == 0 ? 0.0 : totalRevenue / paidPayments;

    return _ReportsData(
      totalUsers: users.length,
      totalTransactions: transactions.length,
      paidPayments: paidPayments,
      pendingOrders: pendingOrders,
      preparingOrders: preparingOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
      cashRevenue: cashRevenue,
      gcashRevenue: gcashRevenue,
      averageSale: avg,
      dailySales: dailySales,
      topProducts: topProducts.take(10).toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _shortDate(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$mm/$dd';
  }
}

class _TopProductItem {
  final String name;
  final int qty;

  const _TopProductItem({
    required this.name,
    required this.qty,
  });
}

class _BarPoint {
  final String label;
  final double value;
  final Color color;

  const _BarPoint(this.label, this.value, this.color);
}