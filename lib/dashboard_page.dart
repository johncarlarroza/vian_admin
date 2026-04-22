import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkGreen = Color(0xFF163829);
  static const Color softGreen = Color(0xFFEAF6EF);
  static const Color borderColor = Color(0xFFDDE9E1);
  static const Color textDark = Color(0xFF1F2A24);
  static const Color textSoft = Color(0xFF6E7C74);
  static const Color cardWhite = Colors.white;
  static const Color accentGold = Color(0xFFD9A441);
  static const Color danger = Color(0xFFD05C5C);
  static const Color blue = Color(0xFF4B78D1);
  static const Color purple = Color(0xFF8A6FF0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load dashboard: ${snapshot.error}',
                style: const TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final data = _DashboardData.fromDocs(docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(data),
                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 4;
                    if (constraints.maxWidth < 1300) crossAxisCount = 2;
                    if (constraints.maxWidth < 720) crossAxisCount = 1;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.65,
                      children: [
                        _KpiCard(
                          title: 'Today’s Sales',
                          value: '₱${data.todaySales.toStringAsFixed(0)}',
                          subtitle: 'Revenue recorded today',
                          icon: Icons.payments_rounded,
                          iconBg: softGreen,
                          iconColor: primaryGreen,
                        ),
                        _KpiCard(
                          title: 'Transactions',
                          value: '${data.totalTransactions}',
                          subtitle: 'All successful records',
                          icon: Icons.receipt_long_rounded,
                          iconBg: const Color(0xFFFFF5E8),
                          iconColor: accentGold,
                        ),
                        _KpiCard(
                          title: 'Completed Orders',
                          value: '${data.completedOrders}',
                          subtitle: 'Finished transactions',
                          icon: Icons.task_alt_rounded,
                          iconBg: const Color(0xFFEAF6EF),
                          iconColor: primaryGreen,
                        ),
                        _KpiCard(
                          title: 'Top Product',
                          value: data.topProductName,
                          subtitle: 'Best selling item',
                          icon: Icons.local_cafe_rounded,
                          iconBg: const Color(0xFFEFF4FF),
                          iconColor: blue,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1180;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _SalesLineChartCard(data: data)),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: _PaymentPieChartCard(data: data)),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _SalesLineChartCard(data: data),
                        const SizedBox(height: 16),
                        _PaymentPieChartCard(data: data),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1180;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _TopProductsBarChartCard(data: data)),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: _OrderStatusCard(data: data)),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _TopProductsBarChartCard(data: data),
                        const SizedBox(height: 16),
                        _OrderStatusCard(data: data),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1180;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _RecentTransactionsCard(data: data)),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: _MiniInsightsCard(data: data)),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _RecentTransactionsCard(data: data),
                        const SizedBox(height: 16),
                        _MiniInsightsCard(data: data),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(_DashboardData data) {
    return _GlassCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6D44), Color(0xFF49A56F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.space_dashboard_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track revenue, payments, products, and order performance in one live dashboard.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              '${data.totalTransactions} Live Records',
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  final int totalTransactions;
  final int todayTransactions;
  final int completedOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double todaySales;
  final double cashTotal;
  final double gcashTotal;
  final String topProductName;
  final List<_RecentTransaction> recentTransactions;
  final List<_TopProduct> topProducts;
  final Map<String, double> weeklyRevenue;

  const _DashboardData({
    required this.totalTransactions,
    required this.todayTransactions,
    required this.completedOrders,
    required this.pendingOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.todaySales,
    required this.cashTotal,
    required this.gcashTotal,
    required this.topProductName,
    required this.recentTransactions,
    required this.topProducts,
    required this.weeklyRevenue,
  });

  static _DashboardData fromDocs(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    double totalRevenue = 0;
    double todaySales = 0;
    double cashTotal = 0;
    double gcashTotal = 0;
    int todayTransactions = 0;
    int completedOrders = 0;
    int pendingOrders = 0;
    int cancelledOrders = 0;

    final Map<String, int> productQtyMap = {};
    final Map<String, double> weekRevenueMap = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    final List<_RecentTransaction> recent = [];

    for (final doc in docs) {
      final map = doc.data() as Map<String, dynamic>;

      final total = _toDouble(map['total']);
      final status = (map['status'] ?? '').toString().toLowerCase();
      final paymentMethod = (map['paymentMethod'] ?? '').toString().toLowerCase();
      final orderNumber = (map['orderNumber'] ?? '-').toString();
      final customerName = (map['customerName'] ?? 'Walk-in Customer').toString();
      final orderType = (map['orderType'] ?? '').toString();
      final day = (map['day'] ?? '').toString();

      totalRevenue += total;

      if (status == 'completed') {
        completedOrders++;
      } else if (status == 'pending') {
        pendingOrders++;
      } else if (status == 'cancelled') {
        cancelledOrders++;
      }

      if (day == todayKey) {
        todaySales += total;
        todayTransactions++;
      }

      if (paymentMethod == 'cash') {
        cashTotal += total;
      } else if (paymentMethod == 'gcash') {
        gcashTotal += total;
      }

      final createdAt = map['createdAt'];
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        final weekday = _weekdayLabel(dt.weekday);
        if (weekRevenueMap.containsKey(weekday) && _isWithinLast7Days(dt, now)) {
          weekRevenueMap[weekday] = (weekRevenueMap[weekday] ?? 0) + total;
        }
      }

      final items = map['items'];
      if (items is List) {
        for (final item in items) {
          if (item is Map) {
            final name = (item['name'] ?? 'Unknown Item').toString();
            final qty = _toInt(item['quantity']);
            productQtyMap[name] = (productQtyMap[name] ?? 0) + qty;
          }
        }
      }

      recent.add(
        _RecentTransaction(
          orderNumber: orderNumber,
          customerName: customerName,
          orderType: orderType,
          paymentMethod: paymentMethod,
          total: total,
          status: status,
          createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
        ),
      );
    }

    final topProducts = productQtyMap.entries
        .map((e) => _TopProduct(name: e.key, quantity: e.value))
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return _DashboardData(
      totalTransactions: docs.length,
      todayTransactions: todayTransactions,
      completedOrders: completedOrders,
      pendingOrders: pendingOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
      todaySales: todaySales,
      cashTotal: cashTotal,
      gcashTotal: gcashTotal,
      topProductName: topProducts.isEmpty ? 'No Data Yet' : topProducts.first.name,
      recentTransactions: recent.take(6).toList(),
      topProducts: topProducts.take(5).toList(),
      weeklyRevenue: weekRevenueMap,
    );
  }

  static String _dateKey(DateTime dt) {
    final yyyy = dt.year.toString();
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  static bool _isWithinLast7Days(DateTime date, DateTime now) {
    final diff = now.difference(date).inDays;
    return diff >= 0 && diff < 7;
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
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

class _RecentTransaction {
  final String orderNumber;
  final String customerName;
  final String orderType;
  final String paymentMethod;
  final double total;
  final String status;
  final DateTime? createdAt;

  const _RecentTransaction({
    required this.orderNumber,
    required this.customerName,
    required this.orderType,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}

class _TopProduct {
  final String name;
  final int quantity;

  const _TopProduct({required this.name, required this.quantity});
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.74),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: DashboardPage.borderColor.withOpacity(0.9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: DashboardPage.textSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardPage.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: DashboardPage.textSoft,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesLineChartCard extends StatelessWidget {
  final _DashboardData data;

  const _SalesLineChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final orderedWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = orderedWeek.map((day) => data.weeklyRevenue[day] ?? 0).toList();
    final maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 100.0 : maxValue + 20;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Revenue Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DashboardPage.textDark,
                  ),
                ),
              ),
              _TagChip(label: 'Line Chart'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total revenue: ₱${data.totalRevenue.toStringAsFixed(0)}',
            style: const TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: safeMax,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: safeMax / 5,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 46,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₱${value.toInt()}',
                          style: const TextStyle(
                            color: DashboardPage.textSoft,
                            fontSize: 10,
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
                        final i = value.toInt();
                        if (i < 0 || i >= orderedWeek.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            orderedWeek[i],
                            style: const TextStyle(
                              color: DashboardPage.textSoft,
                              fontSize: 11,
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
                    color: DashboardPage.primaryGreen,
                    belowBarData: BarAreaData(
                      show: true,
                      color: DashboardPage.primaryGreen.withOpacity(0.12),
                    ),
                    dotData: const FlDotData(show: true),
                    spots: List.generate(
                      values.length,
                      (i) => FlSpot(i.toDouble(), values[i]),
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
}

class _PaymentPieChartCard extends StatelessWidget {
  final _DashboardData data;

  const _PaymentPieChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.cashTotal + data.gcashTotal;
    final cashPercent = total <= 0 ? 0.0 : (data.cashTotal / total) * 100;
    final gcashPercent = total <= 0 ? 0.0 : (data.gcashTotal / total) * 100;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Payment Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DashboardPage.textDark,
                  ),
                ),
              ),
              _TagChip(label: 'Pie Chart'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Cash vs GCash collection.',
            style: TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 230,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 52,
                sectionsSpace: 3,
                sections: [
                  PieChartSectionData(
                    value: data.cashTotal <= 0 ? 0.01 : data.cashTotal,
                    title: '${cashPercent.toStringAsFixed(0)}%',
                    radius: 62,
                    color: DashboardPage.accentGold,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  PieChartSectionData(
                    value: data.gcashTotal <= 0 ? 0.01 : data.gcashTotal,
                    title: '${gcashPercent.toStringAsFixed(0)}%',
                    radius: 62,
                    color: DashboardPage.blue,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _legendTile(
            color: DashboardPage.accentGold,
            label: 'Cash',
            value: '₱${data.cashTotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _legendTile(
            color: DashboardPage.blue,
            label: 'GCash',
            value: '₱${data.gcashTotal.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _legendTile({
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardPage.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 7, backgroundColor: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: DashboardPage.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsBarChartCard extends StatelessWidget {
  final _DashboardData data;

  const _TopProductsBarChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final products = data.topProducts.take(5).toList();
    final maxQty = products.isEmpty
        ? 5.0
        : products.map((e) => e.quantity.toDouble()).reduce((a, b) => a > b ? a : b) + 1;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Top Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DashboardPage.textDark,
                  ),
                ),
              ),
              _TagChip(label: 'Bar Graph'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Highest sold products based on quantity.',
            style: TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No product data yet.',
                  style: TextStyle(
                    color: DashboardPage.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: maxQty,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxQty / 5,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 28,
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: DashboardPage.textSoft,
                              fontSize: 10,
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
                          final i = value.toInt();
                          if (i < 0 || i >= products.length) {
                            return const SizedBox.shrink();
                          }
                          final text = products[i].name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 70,
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: DashboardPage.textSoft,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    products.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: products[index].quantity.toDouble(),
                          width: 24,
                          borderRadius: BorderRadius.circular(8),
                          color: [
                            DashboardPage.primaryGreen,
                            DashboardPage.blue,
                            DashboardPage.accentGold,
                            DashboardPage.purple,
                            const Color(0xFFEF8A5B),
                          ][index % 5],
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
}

class _OrderStatusCard extends StatelessWidget {
  final _DashboardData data;

  const _OrderStatusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DashboardPage.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quick overview of current order states.',
            style: TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _statusTile(
            icon: Icons.task_alt_rounded,
            iconColor: DashboardPage.primaryGreen,
            title: 'Completed',
            value: '${data.completedOrders}',
          ),
          const SizedBox(height: 12),
          _statusTile(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: DashboardPage.accentGold,
            title: 'Pending',
            value: '${data.pendingOrders}',
          ),
          const SizedBox(height: 12),
          _statusTile(
            icon: Icons.cancel_rounded,
            iconColor: DashboardPage.danger,
            title: 'Cancelled',
            value: '${data.cancelledOrders}',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DashboardPage.softGreen,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DashboardPage.borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.today_rounded,
                  color: DashboardPage.primaryGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Today’s orders: ${data.todayTransactions}',
                    style: const TextStyle(
                      color: DashboardPage.darkGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardPage.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.12),
            foregroundColor: iconColor,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: DashboardPage.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: DashboardPage.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final _DashboardData data;

  const _RecentTransactionsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DashboardPage.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Latest orders coming from Firestore.',
            style: TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (data.recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(
                    color: DashboardPage.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            ...data.recentTransactions.map((tx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DashboardPage.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6EF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: DashboardPage.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.orderNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: DashboardPage.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tx.customerName} • ${_formatOrderType(tx.orderType)} • ${tx.paymentMethod.toUpperCase()}',
                            style: const TextStyle(
                              color: DashboardPage.textSoft,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₱${tx.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: DashboardPage.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx.status,
                          style: const TextStyle(
                            color: DashboardPage.textSoft,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
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
}

class _MiniInsightsCard extends StatelessWidget {
  final _DashboardData data;

  const _MiniInsightsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DashboardPage.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Small highlights from your business data.',
            style: TextStyle(
              color: DashboardPage.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _miniTile(
            icon: Icons.money_rounded,
            color: DashboardPage.accentGold,
            title: 'Cash Revenue',
            value: '₱${data.cashTotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _miniTile(
            icon: Icons.qr_code_rounded,
            color: DashboardPage.blue,
            title: 'GCash Revenue',
            value: '₱${data.gcashTotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _miniTile(
            icon: Icons.local_fire_department_rounded,
            color: DashboardPage.purple,
            title: 'Best Seller',
            value: data.topProductName,
          ),
        ],
      ),
    );
  }

  Widget _miniTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardPage.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DashboardPage.textSoft,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DashboardPage.softGreen,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DashboardPage.borderColor),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: DashboardPage.primaryGreen,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}