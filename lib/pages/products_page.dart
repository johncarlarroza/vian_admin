import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vian_admin/widgets/admin_ui.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String search = '';
  String selectedCategory = 'All';

  final List<String> categoryOptions = const [
    'All',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminUi.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  _buildFilters(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildProductsList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products Management',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AdminUi.textDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage VIAN Café menu items, stock, pricing, and availability.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AdminUi.textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AdminActionButton(
            label: 'Add Product',
            icon: Icons.add,
            onPressed: () => _openProductDialog(),
            primary: true,
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
              hintText: 'Search product name...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AdminUi.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AdminUi.borderColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdminUi.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categoryOptions
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value ?? 'All';
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('sortOrder')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load products.',
              style: TextStyle(
                color: AdminUi.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
final category =
    (data['categoryId'] ?? data['category'] ?? '').toString();
          final matchesSearch = search.isEmpty || name.contains(search);
          final matchesCategory =
              selectedCategory == 'All' || category == selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        if (docs.isEmpty) {
          return const AdminGlassCard(
            child: Center(
              child: Text(
                'No products found.',
                style: TextStyle(
                  color: AdminUi.textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildProductCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildProductCard(String docId, Map<String, dynamic> data) {
    final name = (data['name'] ?? '').toString();
    final category = (data['category'] ?? '').toString();
    final isAvailable = (data['isAvailable'] ?? true) == true;
    final isBestSeller = (data['isBestSeller'] ?? false) == true;
    final stockQty = _toInt(data['stockQty']);
    final basePrice = _toDouble(data['basePrice']);
    final hasVariants = (data['hasVariants'] ?? false) == true;
    final prices = Map<String, dynamic>.from(data['prices'] ?? {});
    final needsReview = (data['needsReview'] ?? false) == true;
    final imageUrl = (data['imageUrl'] ?? '').toString();

    return AdminGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminProductImage(
                imageUrl: imageUrl,
                size: 58,
                radius: 16,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AdminUi.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _pill(category, const Color(0xFFF1F5F4), AdminUi.textSoft),
                        _pill(
                          isAvailable ? 'Available' : 'Unavailable',
                          isAvailable
                              ? const Color(0xFFEAF6EF)
                              : const Color(0xFFFFEFEF),
                          isAvailable ? AdminUi.primaryGreen : AdminUi.danger,
                        ),
                        if (isBestSeller)
                          _pill(
                            'Best Seller',
                            const Color(0xFFFFF5E8),
                            AdminUi.gold,
                          ),
                        if (needsReview)
                          _pill(
                            'Needs Review',
                            const Color(0xFFFFF3CD),
                            const Color(0xFF8A6D1D),
                          ),
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
                    '₱${basePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AdminUi.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: $stockQty',
                    style: const TextStyle(
                      color: AdminUi.textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasVariants) _buildVariantsSection(prices),
          if (hasVariants) const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AdminActionButton(
                  label: 'Update Stock',
                  icon: Icons.inventory_2_rounded,
                  onPressed: () => _openStockDialog(docId, data),
                ),
                AdminActionButton(
                  label: 'Edit Product',
                  icon: Icons.edit_rounded,
                  onPressed: () => _openProductDialog(docId: docId, data: data),
                ),
                AdminActionButton(
                  label: isAvailable ? 'Disable' : 'Enable',
                  icon: isAvailable
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  onPressed: () => _toggleAvailability(docId, isAvailable),
                  primary: true,
                  color: isAvailable ? AdminUi.danger : AdminUi.primaryGreen,
                ),
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleBestSeller(docId, isBestSeller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isBestSeller ? AdminUi.gold : AdminUi.textSoft,
                      side: BorderSide(
                        color: (isBestSeller
                                ? AdminUi.gold
                                : AdminUi.borderColor)
                            .withOpacity(0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      isBestSeller
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isBestSeller ? 'Best Seller' : 'Feature',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsSection(Map<String, dynamic> prices) {
    final entries = prices.entries.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminUi.borderColor),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdminUi.borderColor),
            ),
            child: Text(
              '${_prettyVariant(entry.key)} • ₱${_toDouble(entry.value).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AdminUi.textDark,
              ),
            ),
          );
        }).toList(),
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

  Future<void> _toggleAvailability(String docId, bool currentValue) async {
    await FirebaseFirestore.instance.collection('products').doc(docId).update({
      'isAvailable': !currentValue,
    });
  }

  Future<void> _toggleBestSeller(String docId, bool currentValue) async {
    await FirebaseFirestore.instance.collection('products').doc(docId).update({
      'isBestSeller': !currentValue,
    });
  }

  Future<void> _openStockDialog(String docId, Map<String, dynamic> data) async {
    final controller =
        TextEditingController(text: _toInt(data['stockQty']).toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Stock'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Stock Quantity',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final stock = int.tryParse(controller.text.trim()) ?? 0;
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(docId)
                    .update({'stockQty': stock});

                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProductDialog({
    String? docId,
    Map<String, dynamic>? data,
  }) async {
    final isEdit = docId != null && data != null;

    final nameController =
        TextEditingController(text: (data?['name'] ?? '').toString());
    final descriptionController =
        TextEditingController(text: (data?['description'] ?? '').toString());
    final stockController =
        TextEditingController(text: _toInt(data?['stockQty']).toString());
    final sortOrderController =
        TextEditingController(text: _toInt(data?['sortOrder']).toString());
    final imageUrlController =
        TextEditingController(text: (data?['imageUrl'] ?? '').toString());

    String category = (data?['category'] ?? 'Coffee').toString();
    bool isAvailable = (data?['isAvailable'] ?? true) == true;
    bool isBestSeller = (data?['isBestSeller'] ?? false) == true;
    bool hasVariants = (data?['hasVariants'] ?? false) == true;
    bool needsReview = (data?['needsReview'] ?? false) == true;

    final prices = Map<String, dynamic>.from(data?['prices'] ?? {});
    final basePriceController = TextEditingController(
      text: _toDouble(data?['basePrice']).toStringAsFixed(0),
    );

    final hotController =
        TextEditingController(text: prices['hot']?.toString() ?? '');
    final iced12Controller =
        TextEditingController(text: prices['iced12']?.toString() ?? '');
    final iced16Controller =
        TextEditingController(text: prices['iced16']?.toString() ?? '');
    final defaultController =
        TextEditingController(text: prices['default']?.toString() ?? '');
    final withDrinkController =
        TextEditingController(text: prices['withDrink']?.toString() ?? '');
    final withoutDrinkController =
        TextEditingController(text: prices['withoutDrink']?.toString() ?? '');
    final sliceController =
        TextEditingController(text: prices['slice']?.toString() ?? '');
    final wholeController =
        TextEditingController(text: prices['whole']?.toString() ?? '');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Product' : 'Add Product',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Product Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        items: categoryOptions
                            .where((e) => e != 'All')
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            category = value ?? 'Coffee';
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Stock Qty'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: sortOrderController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Sort Order'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Has Variants'),
                        value: hasVariants,
                        onChanged: (value) {
                          setModalState(() {
                            hasVariants = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Available'),
                        value: isAvailable,
                        onChanged: (value) {
                          setModalState(() {
                            isAvailable = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Best Seller'),
                        value: isBestSeller,
                        onChanged: (value) {
                          setModalState(() {
                            isBestSeller = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Needs Review'),
                        value: needsReview,
                        onChanged: (value) {
                          setModalState(() {
                            needsReview = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (!hasVariants) ...[
                        TextField(
                          controller: basePriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base Price / Default Price',
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Variant Prices',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: hotController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Hot'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: iced12Controller,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Iced 12oz'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: iced16Controller,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Iced 16oz'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: withDrinkController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'With Drink'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: withoutDrinkController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Without Drink',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sliceController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Slice'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: wholeController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Whole'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: defaultController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Default'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            AdminActionButton(
                              label: isEdit ? 'Update Product' : 'Add Product',
                              icon: Icons.save_rounded,
                              onPressed: () async {
                                final productName = nameController.text.trim();
                                if (productName.isEmpty) return;

                                final Map<String, double> normalizedPrices = {};

                                if (!hasVariants) {
                                  final price =
                                      double.tryParse(basePriceController.text.trim()) ??
                                          0;
                                  normalizedPrices['default'] = price;
                                } else {
                                  void addIfValid(String key, String value) {
                                    final parsed = double.tryParse(value.trim());
                                    if (parsed != null && value.trim().isNotEmpty) {
                                      normalizedPrices[key] = parsed;
                                    }
                                  }

                                  addIfValid('hot', hotController.text);
                                  addIfValid('iced12', iced12Controller.text);
                                  addIfValid('iced16', iced16Controller.text);
                                  addIfValid('withDrink', withDrinkController.text);
                                  addIfValid('withoutDrink', withoutDrinkController.text);
                                  addIfValid('slice', sliceController.text);
                                  addIfValid('whole', wholeController.text);
                                  addIfValid('default', defaultController.text);

                                  if (normalizedPrices.isEmpty) {
                                    normalizedPrices['default'] = 0;
                                  }
                                }

                                final nonZeroPrices = normalizedPrices.values
                                    .where((e) => e > 0)
                                    .toList();
                                final basePrice = nonZeroPrices.isEmpty
                                    ? 0.0
                                    : nonZeroPrices.reduce((a, b) => a < b ? a : b);

                                final payload = {
                                  'name': productName,
                                  'category': category,
                                  'description': descriptionController.text.trim(),
                                  'basePrice': basePrice,
                                  'prices': normalizedPrices,
                                  'availableVariants': normalizedPrices.keys.toList(),
                                  'hasVariants': hasVariants,
                                  'isAvailable': isAvailable,
                                  'isBestSeller': isBestSeller,
                                  'stockQty':
                                      int.tryParse(stockController.text.trim()) ?? 0,
                                  'imageUrl': imageUrlController.text.trim(),
                                  'tags': const <String>[],
                                  'displayType': _displayTypeFromCategory(category),
                                  'sortOrder':
                                      int.tryParse(sortOrderController.text.trim()) ?? 0,
                                  'needsReview': needsReview,
                                };

                                final collection =
                                    FirebaseFirestore.instance.collection('products');

                                if (isEdit) {
                                  await collection.doc(docId).update(payload);
                                } else {
                                  await collection.add({
                                    ...payload,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                                }

                                if (mounted) Navigator.pop(context);
                              },
                              primary: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _displayTypeFromCategory(String category) {
    switch (category) {
      case 'Coffee':
      case "Vian's Special Coffee":
      case 'Non-Coffee':
      case 'Frappe':
        return 'drink';
      default:
        return 'food';
    }
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
        return value;
    }
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