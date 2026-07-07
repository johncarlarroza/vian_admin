import 'dart:ui';
import 'package:flutter/material.dart';

class VianSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const VianSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2F24), Color(0xFF1F6D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),

          /// 🔥 LOGO
          _buildLogo(),

          const SizedBox(height: 30),

 Expanded(
  child: ListView(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    children: [
      _navItem(Icons.dashboard_rounded, 'Dashboard', 0),
      _navItem(Icons.receipt_long_rounded, 'Transactions', 1),
      _navItem(Icons.shopping_cart_rounded, 'Orders', 2),
      _navItem(Icons.inventory_2_rounded, 'Products', 3),
      _navItem(Icons.payments_rounded, 'Payments', 4),
      _navItem(Icons.bar_chart_rounded, 'Reports', 5),
      _navItem(Icons.confirmation_number_rounded, 'Queue Counter', 6),
      _navItem(Icons.settings_rounded, 'Settings', 7),
    ],
  ),
),
          /// 🔥 LOGOUT
          Padding(
            padding: const EdgeInsets.all(14),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= LOGO =================
  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.fill,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.storefront, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }

  /// ================= NAV ITEM =================
  Widget _navItem(IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
