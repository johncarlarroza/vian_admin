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

  final List<String> categories = const [
    'Rice Bowl',
    'Café Bites',
    'Pasta',
    'Desserts',
    'Side Bites',
    'Coffee',
    "Vian's Special Coffee",
    'Non-Coffee',
    'Frappe',
    'Vian Freshers',
    'Guimaras Pizza by G7',
    'Vian Chicken Wings',
  ];

  Future<void> _uploadProducts() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final product in MenuSeedData.products) {
        final name = (product['name'] ?? '').toString();
        final docId = _slugify(name);
        final docRef = firestore.collection('products').doc(docId);

        final fixedProduct = Map<String, dynamic>.from(product);
        fixedProduct['id'] = docId;
        fixedProduct['categoryId'] =
            fixedProduct['categoryId'] ?? fixedProduct['category'] ?? '';
        fixedProduct['category'] =
            fixedProduct['category'] ?? fixedProduct['categoryId'] ?? '';

        batch.set(docRef, fixedProduct, SetOptions(merge: true));
      }

      await batch.commit();

      setState(() {
        _message =
            'Success! ${MenuSeedData.products.length} products uploaded.';
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
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final docRef = firestore.collection('categories').doc(category);

        batch.set(
          docRef,
          {
            'id': category,
            'name': category,
            'iconName': _iconForCategory(category),
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

  Future<void> _clearCategories() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      setState(() {
        _message = 'All categories deleted.';
      });
    } catch (e) {
      setState(() {
        _message = 'Delete categories failed: $e';
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

  String _iconForCategory(String category) {
    switch (category) {
      case 'Rice Bowl':
        return 'rice_bowl';
      case 'Café Bites':
        return 'restaurant';
      case 'Pasta':
        return 'dinner_dining';
      case 'Desserts':
        return 'cake';
      case 'Side Bites':
        return 'fastfood';
      case 'Coffee':
        return 'local_cafe';
      case "Vian's Special Coffee":
        return 'coffee';
      case 'Non-Coffee':
        return 'emoji_food_beverage';
      case 'Frappe':
        return 'icecream';
      case 'Vian Freshers':
        return 'local_drink';
      case 'Guimaras Pizza by G7':
        return 'local_pizza';
      case 'Vian Chicken Wings':
        return 'lunch_dining';
      default:
        return 'restaurant_menu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
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
                  'Products ready: ${MenuSeedData.products.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Categories ready: ${categories.length}',
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
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _clearCategories,
                  child: const Text('Delete All Categories'),
                ),
                const SizedBox(height: 24),
                if (_loading) const CircularProgressIndicator(),
                if (_message.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
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