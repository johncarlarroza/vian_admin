import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum ReportFilter {
  daily,
  weekly,
  monthly,
  yearly,
}

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

  ReportFilter _selectedFilter = ReportFilter.daily;
  bool _exporting = false;

  String get _filterLabel {
    switch (_selectedFilter) {
      case ReportFilter.daily:
        return 'Daily';
      case ReportFilter.weekly:
        return 'Weekly';
      case ReportFilter.monthly:
        return 'Monthly';
      case ReportFilter.yearly:
        return 'Yearly';
    }
  }

  DateTimeRange _selectedRange() {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case ReportFilter.daily:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);

      case ReportFilter.weekly:
        final today = DateTime(now.year, now.month, now.day);
        final start = today.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);

      case ReportFilter.monthly:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);

      case ReportFilter.yearly:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1);
        return DateTimeRange(start: start, end: end);
    }
  }

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
                      _buildRecentTransactions(data),
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
    final range = _selectedRange();

    final txSnap = await firestore
        .collection('transactions')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(range.start),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(range.end),
        )
        .orderBy('createdAt', descending: true)
        .get();

    final userSnap = await firestore.collection('users').get();

    return _ReportsData.fromSnapshots(
      transactions: txSnap.docs,
      users: userSnap.docs,
      filterLabel: _filterLabel,
      startDate: range.start,
      endDate: range.end,
    );
  }

  Widget _buildHeader(_ReportsData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${data.filterLabel} transaction report • ${_formatRange(data.startDate, data.endDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: softText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReportFilter>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(
                    value: ReportFilter.daily,
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: ReportFilter.weekly,
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: ReportFilter.monthly,
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: ReportFilter.yearly,
                    child: Text('Yearly'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
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
            label: Text(
              _exporting ? 'Exporting...' : 'Export ${data.filterLabel} PDF',
            ),
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
              '${data.filterLabel} Transactions',
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
          Text(
            '${data.filterLabel} Sales Trend',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Revenue within ${data.filterLabel.toLowerCase()} selected range.',
            style: const TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: labels.isEmpty
                ? const Center(
                    child: Text(
                      'No sales data for this period.',
                      style: TextStyle(
                        color: softText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : LineChart(
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

    final maxY =
        items.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b) +
            20;

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
          Text(
            '${data.filterLabel} revenue split by payment channel.',
            style: const TextStyle(
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
          Text(
            '${data.filterLabel} Order Status',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Order distribution based on saved statuses.',
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
          Text(
            '${data.filterLabel} Top Products',
            style: const TextStyle(
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

  Widget _buildRecentTransactions(_ReportsData data) {
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
            '${data.filterLabel} Transactions',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Transactions included in the selected report period.',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (data.recentTransactions.isEmpty)
            const Text(
              'No transactions found for this period.',
              style: TextStyle(
                color: softText,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...data.recentTransactions.take(10).map((tx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${tx.orderNumber} • ${tx.customerName}',
                        style: const TextStyle(
                          color: darkText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '₱${tx.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w900,
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
            'This ${data.filterLabel.toLowerCase()} report from ${_formatRange(data.startDate, data.endDate)} shows ${data.totalTransactions} transactions, ${data.paidPayments} paid payments, ₱${data.totalRevenue.toStringAsFixed(2)} total revenue, and ${data.completedOrders} completed orders. Cash revenue is ₱${data.cashRevenue.toStringAsFixed(2)}, while GCash revenue is ₱${data.gcashRevenue.toStringAsFixed(2)}.',
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
              'VIAN CAFÉ - ${data.filterLabel.toUpperCase()} TRANSACTION REPORT',
              style: pw.TextStyle(
                fontSize: 21,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Date range: ${_formatRange(data.startDate, data.endDate)}',
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
                  _pdfRow('Filtered Transactions', '${data.totalTransactions}'),
                  _pdfRow('Paid Payments', '${data.paidPayments}'),
                  _pdfRow(
                    'Total Revenue',
                    'PHP ${data.totalRevenue.toStringAsFixed(2)}',
                  ),
                  _pdfRow(
                    'Cash Revenue',
                    'PHP ${data.cashRevenue.toStringAsFixed(2)}',
                  ),
                  _pdfRow(
                    'GCash Revenue',
                    'PHP ${data.gcashRevenue.toStringAsFixed(2)}',
                  ),
                  _pdfRow(
                    'Average Sale',
                    'PHP ${data.averageSale.toStringAsFixed(2)}',
                  ),
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
                'Sales Trend',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Image(pw.MemoryImage(salesChartBytes), height: 200),
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
              pw.Image(pw.MemoryImage(paymentChartBytes), height: 200),
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
              pw.Text('No product sales data for this period.')
            else
              ...data.topProducts.take(8).map(
                    (item) => pw.Bullet(
                      text: '${item.name} - ${item.qty} sold',
                    ),
                  ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Transactions',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (data.recentTransactions.isEmpty)
              pw.Text('No transactions found for this period.')
            else
              pw.Table.fromTextArray(
                headers: const [
                  'Order No.',
                  'Customer',
                  'Payment',
                  'Status',
                  'Total',
                ],
                data: data.recentTransactions.map((tx) {
                  return [
                    tx.orderNumber,
                    tx.customerName,
                    tx.paymentMethod.toUpperCase(),
                    tx.status,
                    'PHP ${tx.total.toStringAsFixed(2)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
              ),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: 'vian_${data.filterLabel.toLowerCase()}_transactions.pdf',
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

  String _formatRange(DateTime start, DateTime end) {
    String f(DateTime d) {
      final y = d.year.toString();
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    final displayEnd = end.subtract(const Duration(days: 1));
    return '${f(start)} to ${f(displayEnd)}';
  }
}

class _ReportsData {
  final String filterLabel;
  final DateTime startDate;
  final DateTime endDate;

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
  final List<_ReportTransaction> recentTransactions;

  const _ReportsData({
    required this.filterLabel,
    required this.startDate,
    required this.endDate,
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
    required this.recentTransactions,
  });

  factory _ReportsData.fromSnapshots({
    required List<QueryDocumentSnapshot> transactions,
    required List<QueryDocumentSnapshot> users,
    required String filterLabel,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    int paidPayments = 0;
    int pendingOrders = 0;
    int preparingOrders = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;

    double totalRevenue = 0;
    double cashRevenue = 0;
    double gcashRevenue = 0;

    final Map<String, double> salesMap = {};
    final Map<String, int> productQty = {};
    final List<_ReportTransaction> reportTransactions = [];

    for (final doc in transactions) {
      final data = doc.data() as Map<String, dynamic>;

      final total = _toDouble(data['total']);
      final status = (data['status'] ?? '').toString().toLowerCase();
      final paymentMethod =
          (data['paymentMethod'] ?? '').toString().toLowerCase();
      final paymentStatus =
          (data['paymentStatus'] ?? '').toString().toLowerCase();

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
      DateTime? createdDate;

      if (createdAt is Timestamp) {
        createdDate = createdAt.toDate();
        final key = _chartLabel(createdDate, filterLabel);
        salesMap[key] = (salesMap[key] ?? 0) + total;
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

      reportTransactions.add(
        _ReportTransaction(
          orderNumber: (data['orderNumber'] ?? doc.id).toString(),
          customerName:
              (data['customerName'] ?? 'Walk-in Customer').toString(),
          paymentMethod: paymentMethod,
          status: status,
          total: total,
          createdAt: createdDate,
        ),
      );
    }

    final sortedSales = salesMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final dailySales = {
      for (final entry in sortedSales) entry.key: entry.value,
    };

    final topProducts = productQty.entries
        .map((e) => _TopProductItem(name: e.key, qty: e.value))
        .toList()
      ..sort((a, b) => b.qty.compareTo(a.qty));

    final avg = paidPayments == 0 ? 0.0 : totalRevenue / paidPayments;

    reportTransactions.sort((a, b) {
      final ad = a.createdAt ?? DateTime(1900);
      final bd = b.createdAt ?? DateTime(1900);
      return bd.compareTo(ad);
    });

    return _ReportsData(
      filterLabel: filterLabel,
      startDate: startDate,
      endDate: endDate,
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
      recentTransactions: reportTransactions,
    );
  }

  static String _chartLabel(DateTime dt, String filterLabel) {
    switch (filterLabel) {
      case 'Daily':
        final h = dt.hour.toString().padLeft(2, '0');
        return '$h:00';

      case 'Weekly':
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];

      case 'Monthly':
        return dt.day.toString().padLeft(2, '0');

      case 'Yearly':
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return months[dt.month - 1];

      default:
        final mm = dt.month.toString().padLeft(2, '0');
        final dd = dt.day.toString().padLeft(2, '0');
        return '$mm/$dd';
    }
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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

class _ReportTransaction {
  final String orderNumber;
  final String customerName;
  final String paymentMethod;
  final String status;
  final double total;
  final DateTime? createdAt;

  const _ReportTransaction({
    required this.orderNumber,
    required this.customerName,
    required this.paymentMethod,
    required this.status,
    required this.total,
    required this.createdAt,
  });
}

class _BarPoint {
  final String label;
  final double value;
  final Color color;

  const _BarPoint(this.label, this.value, this.color);
}