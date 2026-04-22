import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkText = Color(0xFF1F2A24);
  static const Color softText = Color(0xFF6E7C74);
  static const Color borderColor = Color(0xFFDDE9E1);
  static const Color danger = Color(0xFFD05C5C);
  static const Color gold = Color(0xFFD9A441);
  static const Color blue = Color(0xFF4B78D1);

  String search = '';
  String selectedMethod = 'all';
  String selectedPaymentStatus = 'all';

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
            return const Center(
              child: Text(
                'Failed to load payments.',
                style: TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final filteredDocs = docs.where(_matchesFilters).toList();
          final stats = _buildStats(docs);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _buildStatsRow(stats),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filteredDocs.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _buildPaymentCard(doc.id, data),
                                  );
                                },
                              ),
                      ),
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

  bool _matchesFilters(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final orderNumber =
        (data['orderNumber'] ?? '').toString().toLowerCase();
    final customerName =
        (data['customerName'] ?? '').toString().toLowerCase();
    final paymentMethod =
        (data['paymentMethod'] ?? '').toString().toLowerCase();
    final paymentStatus =
        (data['paymentStatus'] ?? '').toString().toLowerCase();

    final matchesSearch = search.isEmpty ||
        orderNumber.contains(search) ||
        customerName.contains(search);

    final matchesMethod =
        selectedMethod == 'all' || paymentMethod == selectedMethod;

    final matchesStatus = selectedPaymentStatus == 'all' ||
        paymentStatus == selectedPaymentStatus;

    return matchesSearch && matchesMethod && matchesStatus;
  }

  Map<String, dynamic> _buildStats(List<QueryDocumentSnapshot> docs) {
    double totalRevenue = 0;
    double cashTotal = 0;
    double gcashTotal = 0;
    int unpaidCount = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final total = _toDouble(data['total']);
      final method = (data['paymentMethod'] ?? '').toString().toLowerCase();
      final status = (data['paymentStatus'] ?? '').toString().toLowerCase();

      if (status == 'paid') {
        totalRevenue += total;
      }

      if (method == 'cash' && status == 'paid') {
        cashTotal += total;
      }

      if (method == 'gcash' && status == 'paid') {
        gcashTotal += total;
      }

      if (status != 'paid') {
        unpaidCount++;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'cashTotal': cashTotal,
      'gcashTotal': gcashTotal,
      'unpaidCount': unpaidCount,
    };
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments Management',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Monitor paid and unpaid transactions, payment methods, and total revenue.',
            style: TextStyle(
              fontSize: 13,
              color: softText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total Revenue',
            '₱${_toDouble(stats['totalRevenue']).toStringAsFixed(2)}',
            Icons.account_balance_wallet_rounded,
            primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Cash',
            '₱${_toDouble(stats['cashTotal']).toStringAsFixed(2)}',
            Icons.money_rounded,
            gold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'GCash',
            '₱${_toDouble(stats['gcashTotal']).toStringAsFixed(2)}',
            Icons.qr_code_rounded,
            blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Unpaid',
            '${_toInt(stats['unpaidCount'])}',
            Icons.warning_amber_rounded,
            danger,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
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
                    color: softText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (value) {
              setState(() {
                search = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search order number or customer...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _dropdownFilter(
            value: selectedMethod,
            items: const ['all', 'cash', 'gcash'],
            labelBuilder: (value) {
              if (value == 'all') return 'All Methods';
              return value.toUpperCase();
            },
            onChanged: (value) {
              setState(() {
                selectedMethod = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _dropdownFilter(
            value: selectedPaymentStatus,
            items: const ['all', 'paid', 'unpaid', 'pending'],
            labelBuilder: (value) {
              if (value == 'all') return 'All Payment Status';
              return _capitalize(value);
            },
            onChanged: (value) {
              setState(() {
                selectedPaymentStatus = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _dropdownFilter({
    required String value,
    required List<String> items,
    required String Function(String) labelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: const Center(
        child: Text(
          'No payment records found.',
          style: TextStyle(
            color: softText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(String docId, Map<String, dynamic> data) {
    final orderNumber = (data['orderNumber'] ?? '-').toString();
    final customerName =
        (data['customerName'] ?? 'Walk-in Customer').toString();
    final paymentMethod = (data['paymentMethod'] ?? '-').toString();
    final paymentStatus = (data['paymentStatus'] ?? 'unpaid').toString();
    final total = _toDouble(data['total']);
    final orderStatus = (data['status'] ?? '-').toString();
    final createdAt = data['createdAt'];
    final dateTime =
        createdAt is Timestamp ? createdAt.toDate() : null;

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: softText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _paymentMethodPill(paymentMethod),
                        _paymentStatusPill(paymentStatus),
                        _orderStatusPill(orderStatus),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateTime == null ? 'No date' : _formatDateTime(dateTime),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: softText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => _openPaymentDetails(docId, data),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(170, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SizedBox(
                height: 46,
                child: FilledButton.icon(
                  onPressed: paymentStatus.toLowerCase() == 'paid'
                      ? null
                      : () => _markAsPaid(docId),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    minimumSize: const Size(170, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    paymentStatus.toLowerCase() == 'paid'
                        ? 'Already Paid'
                        : 'Mark as Paid',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bgColor, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _paymentMethodPill(String method) {
    final m = method.toLowerCase();
    if (m == 'cash') {
      return _pill('CASH', const Color(0xFFFFF5E8), gold);
    }
    if (m == 'gcash') {
      return _pill('GCASH', const Color(0xFFEFF4FF), blue);
    }
    return _pill(method.toUpperCase(), const Color(0xFFF1F3F4), softText);
  }

  Widget _paymentStatusPill(String status) {
    final s = status.toLowerCase();
    if (s == 'paid') {
      return _pill('Paid', const Color(0xFFEAF6EF), primaryGreen);
    }
    if (s == 'unpaid') {
      return _pill('Unpaid', const Color(0xFFFFEFEF), danger);
    }
    if (s == 'pending') {
      return _pill('Pending', const Color(0xFFFFF5E8), gold);
    }
    return _pill(_capitalize(status), const Color(0xFFF1F3F4), softText);
  }

  Widget _orderStatusPill(String status) {
    final s = status.toLowerCase();
    if (s == 'completed') {
      return _pill('Order Completed', const Color(0xFFEAF6EF), primaryGreen);
    }
    if (s == 'pending') {
      return _pill('Order Pending', const Color(0xFFFFF5E8), gold);
    }
    if (s == 'preparing') {
      return _pill('Preparing', const Color(0xFFEFF4FF), blue);
    }
    if (s == 'cancelled') {
      return _pill('Cancelled', const Color(0xFFFFEFEF), danger);
    }
    return _pill(_capitalize(status), const Color(0xFFF1F3F4), softText);
  }

  Future<void> _markAsPaid(String docId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(docId)
        .update({
      'paymentStatus': 'paid',
    });
  }

  Future<void> _openPaymentDetails(
    String docId,
    Map<String, dynamic> data,
  ) async {
    final items = (data['items'] as List?) ?? [];
    final createdAt = data['createdAt'];
    final DateTime? dateTime =
        createdAt is Timestamp ? createdAt.toDate() : null;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (data['orderNumber'] ?? '-').toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                          ),
                        ),
                      ),
                      _paymentStatusPill(
                        (data['paymentStatus'] ?? 'unpaid').toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateTime == null
                        ? 'No date available'
                        : _formatDateTime(dateTime),
                    style: const TextStyle(
                      color: softText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _detailSection(
                    title: 'Payment Information',
                    child: Column(
                      children: [
                        _detailRow(
                          'Customer',
                          (data['customerName'] ?? 'Walk-in Customer').toString(),
                        ),
                        _detailRow(
                          'Payment Method',
                          (data['paymentMethod'] ?? '-').toString().toUpperCase(),
                        ),
                        _detailRow(
                          'Payment Status',
                          (data['paymentStatus'] ?? '-').toString(),
                        ),
                        _detailRow(
                          'Order Status',
                          (data['status'] ?? '-').toString(),
                        ),
                        _detailRow(
                          'Order Type',
                          _prettyOrderType((data['orderType'] ?? '').toString()),
                        ),
                        _detailRow(
                          'Transaction ID',
                          (data['transactionId'] ?? docId).toString(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailSection(
                    title: 'Ordered Items',
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No items found.',
                              style: TextStyle(
                                color: softText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ...items.map((item) {
                                final map = item as Map;
                                final name =
                                    (map['name'] ?? 'Unknown Item').toString();
                                final variant =
                                    (map['variant'] ?? '').toString();
                                final quantity = _toInt(map['quantity']);
                                final unitPrice = _toDouble(map['unitPrice']);
                                final subtotal = _toDouble(map['subtotal']);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAF9),
                                    borderRadius: BorderRadius.circular(16),
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
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '₱${subtotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _pill(
                                            'Variant: ${_prettyVariant(variant)}',
                                            const Color(0xFFEAF6EF),
                                            primaryGreen,
                                          ),
                                          _pill(
                                            'Qty: $quantity',
                                            const Color(0xFFF1F5F4),
                                            softText,
                                          ),
                                          _pill(
                                            '₱${unitPrice.toStringAsFixed(2)} each',
                                            const Color(0xFFEFF4FF),
                                            blue,
                                          ),
                                        ],
                                      ),
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
                                    '₱${_toDouble(data['total']).toStringAsFixed(2)}',
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
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: (data['paymentStatus'] ?? '')
                                    .toString()
                                    .toLowerCase() ==
                                'paid'
                            ? null
                            : () async {
                                await _markAsPaid(docId);
                                if (mounted) Navigator.pop(context);
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Mark as Paid'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static String _prettyOrderType(String value) {
    if (value == 'dine_in') return 'Dine-In';
    if (value == 'takeout') return 'Takeout';
    return value.isEmpty ? '-' : value;
  }

  static String _prettyVariant(String value) {
    switch (value) {
      case 'hot':
        return 'Hot';
      case 'iced12':
        return 'Iced 12oz';
      case 'iced16':
        return 'Iced 16oz';
      case 'withDrink':
        return 'With Drink';
      case 'withoutDrink':
        return 'Without Drink';
      case 'slice':
        return 'Slice';
      case 'whole':
        return 'Whole';
      case 'default':
        return 'Default';
      case 'bbq':
        return 'BBQ';
      case 'cheese':
        return 'Cheese';
      case 'sourCream':
        return 'Sour Cream';
      case 'plain':
        return 'Plain';
      default:
        return value.isEmpty ? '-' : value;
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
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}