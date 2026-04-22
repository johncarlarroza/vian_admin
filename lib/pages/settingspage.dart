import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkText = Color(0xFF1F2A24);
  static const Color softText = Color(0xFF6E7C74);
  static const Color borderColor = Color(0xFFDDE9E1);
  static const Color blue = Color(0xFF4B78D1);
  static const Color gold = Color(0xFFD9A441);

  bool notificationsEnabled = true;
  bool lowStockAlerts = true;
  bool salesReportEmails = false;
  bool autoMarkPaidOnCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      child: FutureBuilder<_SettingsStats>(
        future: _loadStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? const _SettingsStats();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage admin preferences, alerts, and café system information.',
                  style: TextStyle(
                    fontSize: 13,
                    color: softText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 1100;

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                _buildAdminCard(),
                                const SizedBox(height: 16),
                                _buildSystemInfoCard(stats),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _buildPreferencesCard(),
                                const SizedBox(height: 16),
                                _buildAboutCard(stats),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildAdminCard(),
                        const SizedBox(height: 16),
                        _buildPreferencesCard(),
                        const SizedBox(height: 16),
                        _buildSystemInfoCard(stats),
                        const SizedBox(height: 16),
                        _buildAboutCard(stats),
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

  Future<_SettingsStats> _loadStats() async {
    final firestore = FirebaseFirestore.instance;

    final usersSnap = await firestore.collection('users').get();
    final productsSnap = await firestore.collection('products').get();
    final txSnap = await firestore.collection('transactions').get();

    return _SettingsStats(
      totalUsers: usersSnap.docs.length,
      totalProducts: productsSnap.docs.length,
      totalTransactions: txSnap.docs.length,
    );
  }

  Widget _buildAdminCard() {
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
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFF1F6D44),
            child: Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'VIAN Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Administrator Account',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _infoChip(Icons.verified_user_rounded, 'Admin Access', primaryGreen),
          const SizedBox(height: 10),
          _infoChip(Icons.storefront_rounded, 'VIAN Café System', blue),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'These are local admin controls for your dashboard behavior.',
            style: TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: notificationsEnabled,
            activeColor: primaryGreen,
            title: const Text(
              'Enable Notifications',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Receive general admin notifications'),
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: lowStockAlerts,
            activeColor: primaryGreen,
            title: const Text(
              'Low Stock Alerts',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Alert when product stock is low'),
            onChanged: (value) {
              setState(() => lowStockAlerts = value);
            },
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: salesReportEmails,
            activeColor: primaryGreen,
            title: const Text(
              'Sales Report Emails',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Enable automated sales report reminders later'),
            onChanged: (value) {
              setState(() => salesReportEmails = value);
            },
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: autoMarkPaidOnCompleted,
            activeColor: primaryGreen,
            title: const Text(
              'Auto Mark Paid on Completed',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Used as admin preference for future workflows'),
            onChanged: (value) {
              setState(() => autoMarkPaidOnCompleted = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard(_SettingsStats stats) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          _rowInfo('App Name', 'VIAN Café Admin'),
          _rowInfo('System Version', '1.0.0'),
          _rowInfo('Users Collection', '${stats.totalUsers} records'),
          _rowInfo('Products Collection', '${stats.totalProducts} records'),
          _rowInfo('Transactions Collection', '${stats.totalTransactions} records'),
          _rowInfo('Theme', 'Green Premium Admin UI'),
        ],
      ),
    );
  }

  Widget _buildAboutCard(_SettingsStats stats) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Admin Panel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This admin system currently manages ${stats.totalProducts} products, ${stats.totalTransactions} transactions, and ${stats.totalUsers} users. It includes product management, order management, payments, transaction details, reports, and PDF exporting.',
            style: const TextStyle(
              color: softText,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _infoChip(Icons.inventory_2_rounded, 'Products', gold),
              _infoChip(Icons.receipt_long_rounded, 'Transactions', primaryGreen),
              _infoChip(Icons.payments_rounded, 'Payments', blue),
              _infoChip(Icons.bar_chart_rounded, 'Reports', primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
          Text(
            value,
            style: const TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsStats {
  final int totalUsers;
  final int totalProducts;
  final int totalTransactions;

  const _SettingsStats({
    this.totalUsers = 0,
    this.totalProducts = 0,
    this.totalTransactions = 0,
  });
}