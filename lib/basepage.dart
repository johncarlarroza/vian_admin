import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vian_admin/login.dart';
import 'package:vian_admin/pages/orders_page.dart';
import 'package:vian_admin/pages/payments_page.dart';
import 'package:vian_admin/pages/products_page.dart';
import 'package:vian_admin/pages/reports_page.dart';
import 'package:vian_admin/pages/settingspage.dart';
import 'package:vian_admin/pages/transactions_page.dart';
import 'package:vian_admin/sidebar.dart';

import 'dashboard_page.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int selectedIndex = 0;

  static const List<String> _pageTitles = [
    'Dashboard',
    'Transactions',
    'Orders',
    'Products',
    'Payments',
    'Reports',
    'Settings',
  ];

  static const List<String> _pageSubtitles = [
    'Overview of your café performance and activity.',
    'Monitor all transaction records and details.',
    'Manage customer orders and update statuses.',
    'Control your menu items, stock, and availability.',
    'Track payment methods, statuses, and revenue.',
    'View analytics, charts, and export business reports.',
    'Manage admin preferences and system information.',
  ];

  final List<Widget> pages =  [
    DashboardPage(),
    TransactionsPage(),
    OrdersPage(),
    ProductsPage(),
    PaymentsPage(),
    ReportsPage(),  
    // SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTitle = _pageTitles[selectedIndex];
    final currentSubtitle = _pageSubtitles[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Row(
          children: [
            VianSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                if (index < 0 || index >= pages.length) return;
                setState(() {
                  selectedIndex = index;
                });
              },
              onLogout: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
},
            ),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(
                    title: currentTitle,
                    subtitle: currentSubtitle,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: KeyedSubtree(
                        key: ValueKey(selectedIndex),
                        child: pages[selectedIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 96,
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.55),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildLogoCard(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIAN CAFÉ • $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2A24),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFF6E7C74),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                _buildAdminBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.storefront_rounded,
          color: Color(0xFF1F6D44),
          size: 30,
        ),
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFDDE9E1),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF1F6D44),
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Admin',
            style: TextStyle(
              color: Color(0xFF1F6D44),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}