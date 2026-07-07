import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vian_admin/login.dart';
import 'package:vian_admin/pages/orders_page.dart';
import 'package:vian_admin/pages/payments_page.dart';
import 'package:vian_admin/pages/products_page.dart';
import 'package:vian_admin/pages/reports_page.dart';
import 'package:vian_admin/pages/settingspage.dart';
import 'package:vian_admin/pages/transactions_page.dart';
import 'package:vian_admin/sidebar.dart';
import 'package:vian_admin/pages/queue.dart';

import 'dashboard_page.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int selectedIndex = 0;

  StreamSubscription<QuerySnapshot>? _newOrderSub;

  bool _initialOrdersLoaded = false;
  bool _dialogShowing = false;
  String? _latestKnownOrderId;

  final List<_AdminNotification> _notifications = [];

  static const List<String> _pageTitles = [
    'Dashboard',
    'Transactions',
    'Orders',
    'Products',
    'Payments',
    'Reports',
    'Queue Counter',
    'Settings',
  ];

  static const List<String> _pageSubtitles = [
    'Overview of your café performance and activity.',
    'Monitor all transaction records and details.',
    'Manage customer orders and update statuses.',
    'Control your menu items, stock, and availability.',
    'Track payment methods, statuses, and revenue.',
    'View analytics, charts, and export business reports.',
    'Manage queue numbers and fullscreen counter display.',
    'Manage admin preferences and system information.',
  ];

  final List<Widget> pages = const [
    DashboardPage(),
    TransactionsPage(),
    OrdersPage(),
    ProductsPage(),
    PaymentsPage(),
    ReportsPage(),
    QueuePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _listenForNewOrders();
  }

  @override
  void dispose() {
    _newOrderSub?.cancel();
    super.dispose();
  }

  void _listenForNewOrders() {
    _newOrderSub = FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted || snapshot.docs.isEmpty) return;

        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = data['createdAt'];

        if (createdAt == null) return;

        if (!_initialOrdersLoaded) {
          _initialOrdersLoaded = true;
          _latestKnownOrderId = doc.id;
          return;
        }

        if (_latestKnownOrderId == doc.id) return;

        _latestKnownOrderId = doc.id;

        final notif = _AdminNotification(
          docId: doc.id,
          orderNumber: (data['orderNumber'] ?? '-').toString(),
          customerName: (data['customerName'] ?? 'Walk-in Customer').toString(),
          paymentMethod: (data['paymentMethod'] ?? '-').toString(),
          total: _toDouble(data['total']),
          createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
          isRead: false,
        );

        setState(() {
          final alreadyExists = _notifications.any((n) => n.docId == notif.docId);
          if (!alreadyExists) {
            _notifications.insert(0, notif);
          }
        });

        _showNewOrderPopup(notif);
      },
      onError: (error) {
        debugPrint('New order notification error: $error');
      },
    );
  }

  void _showNewOrderPopup(_AdminNotification notif) {
    if (!mounted || _dialogShowing) return;

    _dialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF1F6D44),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'New Order Received',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _popupRow('Order No.', notif.orderNumber),
              _popupRow('Customer', notif.customerName),
              _popupRow('Payment Method', notif.paymentMethod.toUpperCase()),
              _popupRow('Total', '₱${notif.total.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              const Text(
                'You can visit this notification again using the notification bell.',
                style: TextStyle(
                  color: Color(0xFF6E7C74),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Later'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _openNotification(notif);
              },
              icon: const Icon(Icons.shopping_cart_rounded),
              label: const Text('View Order'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F6D44),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      _dialogShowing = false;
    });
  }

  void _openNotification(_AdminNotification notif) {
    setState(() {
      selectedIndex = 2;

      final index = _notifications.indexWhere((n) => n.docId == notif.docId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllNotificationsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  Widget _popupRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6E7C74),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1F2A24),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                _newOrderSub?.cancel();

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
                    child: IndexedStack(
                      index: selectedIndex,
                      children: pages,
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
                _buildNotificationBell(),
                const SizedBox(width: 12),
                _buildAdminBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final hasUnread = unreadCount > 0;

    return PopupMenuButton<String>(
      tooltip: 'Notifications',
      offset: const Offset(0, 54),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onOpened: () {
        if (_notifications.isNotEmpty) {
          _markAllNotificationsRead();
        }
      },
      onSelected: (value) {
        if (value == 'orders') {
          setState(() => selectedIndex = 2);
          return;
        }

        if (value == 'clear') {
          _clearNotifications();
          return;
        }

        final notif = _notifications.firstWhere(
          (n) => n.docId == value,
          orElse: () => _notifications.first,
        );

        _openNotification(notif);
      },
      itemBuilder: (context) {
        if (_notifications.isEmpty) {
          return [
            const PopupMenuItem<String>(
              enabled: false,
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF1F6D44),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'No new orders',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ];
        }

        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFD9A441),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_notifications.length} order notification(s)',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          ..._notifications.take(6).map((notif) {
            return PopupMenuItem<String>(
              value: notif.docId,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    notif.isRead
                        ? Icons.shopping_cart_outlined
                        : Icons.shopping_cart_rounded,
                    color: notif.isRead
                        ? const Color(0xFF6E7C74)
                        : const Color(0xFF1F6D44),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.orderNumber,
                          style: TextStyle(
                            fontWeight:
                                notif.isRead ? FontWeight.w700 : FontWeight.w900,
                            color: const Color(0xFF1F2A24),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${notif.customerName} • ₱${notif.total.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6E7C74),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(notif.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9AA8A0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'orders',
            child: Row(
              children: [
                Icon(Icons.shopping_cart_rounded),
                SizedBox(width: 10),
                Text('Go to Orders'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'clear',
            child: Row(
              children: [
                Icon(
                  Icons.delete_sweep_rounded,
                  color: Color(0xFFD05C5C),
                ),
                SizedBox(width: 10),
                Text('Clear Notifications'),
              ],
            ),
          ),
        ];
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasUnread
                  ? const Color(0xFFFFF5E8)
                  : const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFDDE9E1)),
            ),
            child: Icon(
              hasUnread
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: hasUnread
                  ? const Color(0xFFD9A441)
                  : const Color(0xFF1F6D44),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD05C5C),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
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
              'V',
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

  static String _formatDateTime(DateTime dt) {
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year.toString();

    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$month/$day/$year • $hour:$minute $period';
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _AdminNotification {
  final String docId;
  final String orderNumber;
  final String customerName;
  final String paymentMethod;
  final double total;
  final DateTime createdAt;
  final bool isRead;

  const _AdminNotification({
    required this.docId,
    required this.orderNumber,
    required this.customerName,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
    required this.isRead,
  });

  _AdminNotification copyWith({
    String? docId,
    String? orderNumber,
    String? customerName,
    String? paymentMethod,
    double? total,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return _AdminNotification(
      docId: docId ?? this.docId,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}