import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkText = Color(0xFF1F2A24);
  static const Color softText = Color(0xFF6E7C74);
  static const Color borderColor = Color(0xFFDDE9E1);
  static const Color gold = Color(0xFFD9A441);
  static const Color danger = Color(0xFFD05C5C);
  static const Color blue = Color(0xFF4B78D1);

  Future<void> _updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance.collection('transactions').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QueueFullScreenPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Queue Counter',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage customer orders from Preparing to Ready to Serve.',
                      style: TextStyle(
                        color: softText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openFullScreen(context),
                icon: const Icon(Icons.fullscreen_rounded),
                label: const Text('Fullscreen'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load queue.'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final preparing = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? '').toString().toLowerCase() ==
                      'preparing';
                }).toList();

                final ready = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = (data['status'] ?? '').toString().toLowerCase();
                  return status == 'ready_to_serve' || status == 'ready';
                }).toList();

                return Row(
                  children: [
                    Expanded(
                      child: _queueColumn(
                        title: 'Preparing',
                        icon: Icons.local_cafe_rounded,
                        color: gold,
                        docs: preparing,
                        emptyText: 'No preparing orders.',
                        actionLabel: 'Ready to Serve',
                        actionIcon: Icons.room_service_rounded,
                        onAction: (docId) =>
                            _updateStatus(docId, 'ready_to_serve'),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _queueColumn(
                        title: 'Ready to Serve',
                        icon: Icons.check_circle_rounded,
                        color: primaryGreen,
                        docs: ready,
                        emptyText: 'No ready orders.',
                        actionLabel: 'Complete',
                        actionIcon: Icons.done_all_rounded,
                        onAction: (docId) =>
                            _updateStatus(docId, 'completed'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _queueColumn({
    required String title,
    required IconData icon,
    required Color color,
    required List<QueryDocumentSnapshot> docs,
    required String emptyText,
    required String actionLabel,
    required IconData actionIcon,
    required Function(String docId) onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${docs.length}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: docs.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(
                        color: softText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return _orderCard(
                        docId: doc.id,
                        data: data,
                        color: color,
                        actionLabel: actionLabel,
                        actionIcon: actionIcon,
                        onAction: onAction,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard({
    required String docId,
    required Map<String, dynamic> data,
    required Color color,
    required String actionLabel,
    required IconData actionIcon,
    required Function(String docId) onAction,
  }) {
    final orderNumber = (data['orderNumber'] ?? '-').toString();
    final customerName =
        (data['customerName'] ?? 'Walk-in Customer').toString();
    final orderType = (data['orderType'] ?? '').toString();
    final paymentStatus = (data['paymentStatus'] ?? 'pending').toString();
    final items = (data['items'] as List?) ?? [];
    final total = _toDouble(data['total']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderNumber,
            style: const TextStyle(
              fontSize: 22,
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(_prettyOrderType(orderType), const Color(0xFFEFF4FF), blue),
              _pill(
                paymentStatus.toUpperCase(),
                paymentStatus.toLowerCase() == 'paid'
                    ? const Color(0xFFEAF6EF)
                    : const Color(0xFFFFF5E8),
                paymentStatus.toLowerCase() == 'paid' ? primaryGreen : gold,
              ),
              _pill('₱${total.toStringAsFixed(2)}', const Color(0xFFEAF6EF),
                  primaryGreen),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isNotEmpty)
            Column(
              children: items.map((item) {
                final map = item as Map;
                final name = (map['name'] ?? 'Item').toString();
                final qty = _toInt(map['quantity']);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        'x$qty',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: () => onAction(docId),
              icon: Icon(actionIcon, size: 18),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
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
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  static String _prettyOrderType(String value) {
    if (value == 'dine_in') return 'Dine-In';
    if (value == 'takeout') return 'Takeout';
    return value.isEmpty ? '-' : value;
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

class QueueFullScreenPage extends StatelessWidget {
  const QueueFullScreenPage({super.key});

  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color gold = Color(0xFFD9A441);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2F24),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          final preparing = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? '').toString().toLowerCase() ==
                'preparing';
          }).toList();

          final ready = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? '').toString().toLowerCase();
            return status == 'ready_to_serve' || status == 'ready';
          }).toList();

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 110,
                    alignment: Alignment.center,
                    child: const Text(
                      'VIAN CAFÉ QUEUE DISPLAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _displayColumn(
                            title: 'PREPARING',
                            color: gold,
                            docs: preparing,
                          ),
                        ),
                        Container(width: 2, color: Colors.white24),
                        Expanded(
                          child: _displayColumn(
                            title: 'READY TO SERVE',
                            color: const Color(0xFF7CFFAA),
                            docs: ready,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_fullscreen_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _displayColumn({
    required String title,
    required Color color,
    required List<QueryDocumentSnapshot> docs,
  }) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: docs.isEmpty
                ? const Center(
                    child: Text(
                      '---',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 70,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final orderNumber =
                          (data['orderNumber'] ?? '-').toString();

                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: FittedBox(
                          child: Text(
                            orderNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}