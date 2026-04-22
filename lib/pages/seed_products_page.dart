import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vian_admin/data/menu_seed_data.dart';

class SeedProductsPage extends StatefulWidget {
  const SeedProductsPage({super.key});

  @override
  State<SeedProductsPage> createState() => _SeedProductsPageState();
}

class _SeedProductsPageState extends State<SeedProductsPage> {
  bool _loading = false;
  String _message = '';

  Future<void> _uploadProducts() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final product in MenuSeedData.products) {
        final productName = (product['name'] ?? '').toString();
        final docId = _slugify(productName);
        final docRef = firestore.collection('products').doc(docId);

        batch.set(docRef, product, SetOptions(merge: true));
      }

      await batch.commit();

      setState(() {
        _message =
            'Success! ${MenuSeedData.products.length} products uploaded to Firestore.';
      });
    } catch (e) {
      setState(() {
        _message = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _uploadCategories() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final categories = [
        'Rice Bowl',
        'Café Bites',
        'Pasta',
        'Desserts',
        'Side Bites',
        'Coffee',
        "Vian's Special Coffee",
        'Non-Coffee',
        'Frappe',
      ];

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final docRef = firestore.collection('categories').doc(category);
        batch.set(
          docRef,
          {
            'name': category,
            'sortOrder': i + 1,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      setState(() {
        _message = 'Success! Categories uploaded.';
      });
    } catch (e) {
      setState(() {
        _message = 'Category upload failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _clearProducts() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      setState(() {
        _message = 'All products deleted.';
      });
    } catch (e) {
      setState(() {
        _message = 'Delete failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll("'", '')
        .replaceAll('/', ' ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Products'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'VIAN Café Product Seeder',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Products ready to upload: ${MenuSeedData.products.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _uploadCategories,
                  child: const Text('Upload Categories'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loading ? null : _uploadProducts,
                  child: const Text('Upload All Products'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _clearProducts,
                  child: const Text('Delete All Products'),
                ),
                const SizedBox(height: 24),
                if (_loading) const CircularProgressIndicator(),
                if (_message.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}