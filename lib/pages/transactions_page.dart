import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'transaction_details_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String search = '';
  String filter = 'all'; // all | today

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7F6),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _filters(),
          const SizedBox(height: 16),
          Expanded(child: _transactionsList()),
        ],
      ),
    );
  }

  Widget _header() {
    return const Text(
      'Transactions',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1F2A24),
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) {
              setState(() {
                search = val.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search order / customer...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: filter,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'today', child: Text('Today')),
          ],
          onChanged: (val) {
            setState(() {
              filter = val!;
            });
          },
        ),
      ],
    );
  }

  Widget _transactionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final order = (data['orderNumber'] ?? '').toString().toLowerCase();
          final name = (data['customerName'] ?? '').toString().toLowerCase();
          final day = (data['day'] ?? '').toString();

          final todayKey = _todayKey();

          final matchesSearch = order.contains(search) || name.contains(search);
          final matchesFilter =
              filter == 'all' || (filter == 'today' && day == todayKey);

          return matchesSearch && matchesFilter;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No transactions found'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>;

            return _transactionCard(context, data);
          },
        );
      },
    );
  }

  Widget _transactionCard(BuildContext context, Map<String, dynamic> data) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailsPage(data: data),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.receipt, color: Color(0xFF1F6D44)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['orderNumber'] ?? '').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['customerName']} • ${data['paymentMethod']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${_toDouble(data['total']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F6D44),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (data['status'] ?? '').toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    final yyyy = now.year.toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }
}