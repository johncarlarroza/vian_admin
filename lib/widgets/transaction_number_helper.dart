import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionNumberHelper {
  static String todayDateKey() {
    final now = DateTime.now();

    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final yyyy = now.year.toString();

    return '$mm$dd$yyyy';
  }

  static String todayFilterKey() {
    final now = DateTime.now();

    final yyyy = now.year.toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');

    return '$yyyy-$mm-$dd';
  }

  static Future<String> generateTransactionNumber() async {
    final firestore = FirebaseFirestore.instance;
    final dateKey = todayDateKey();

    final counterRef =
        firestore.collection('transaction_counters').doc(dateKey);

    return firestore.runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int nextNumber = 1;

      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final lastNumber = data['lastNumber'];

        nextNumber = lastNumber is int
            ? lastNumber + 1
            : (int.tryParse(lastNumber.toString()) ?? 0) + 1;
      }

      transaction.set(
        counterRef,
        {
          'dateKey': dateKey,
          'lastNumber': nextNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return '$dateKey-${nextNumber.toString().padLeft(3, '0')}';
    });
  }
}