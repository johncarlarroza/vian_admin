import 'package:cloud_firestore/cloud_firestore.dart';

class MenuSeedData {
  static List<Map<String, dynamic>> get products => [
        // =========================
        // RICE BOWL
        // =========================
        _variantProduct(
          name: 'Burger Steak',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 80,
            'withDrink': 89,
          },
          sortOrder: 1,
        ),
        _variantProduct(
          name: 'Chicken Ala King',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 95,
            'withDrink': 105,
          },
          sortOrder: 2,
        ),
        _variantProduct(
          name: 'Chicken Teriyaki',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 89,
            'withDrink': 99,
          },
          sortOrder: 3,
        ),
        _variantProduct(
          name: 'Chicken Katsu',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 95,
            'withDrink': 105,
          },
          sortOrder: 4,
        ),
        _variantProduct(
          name: 'Pork Adobo',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 80,
            'withDrink': 99,
          },
          sortOrder: 5,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Pork Chop',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 89,
            'withDrink': 99,
          },
          sortOrder: 6,
        ),
        _variantProduct(
          name: 'Pork Sisig',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 95,
            'withDrink': 105,
          },
          sortOrder: 7,
        ),
        _variantProduct(
          name: 'Garlic Pepper Beef',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 99,
            'withDrink': 109,
          },
          sortOrder: 8,
        ),
        _variantProduct(
          name: 'Grilled Pan Pork Belly',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 89,
            'withDrink': 99,
          },
          sortOrder: 9,
        ),
        _variantProduct(
          name: 'Pork Tapa',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 95,
            'withDrink': 105,
          },
          sortOrder: 10,
        ),
        _variantProduct(
          name: 'Hungarian Sausage & Rice',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 79,
            'withDrink': 89,
          },
          sortOrder: 11,
        ),
        _variantProduct(
          name: 'Lumpia & Rice',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 50,
            'withDrink': 60,
          },
          sortOrder: 12,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Nuggets & Rice',
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 60,
            'withDrink': 70,
          },
          sortOrder: 13,
          needsReview: true,
        ),
        _variantProduct(
          name: "Vian's Siomai Rice",
          category: 'Rice Bowl',
          prices: {
            'withoutDrink': 49,
            'withDrink': 59,
          },
          sortOrder: 14,
        ),

        // =========================
        // CAFE BITES
        // =========================
        _simpleProduct(
          name: 'Cheese Roll',
          category: 'Café Bites',
          price: 35,
          sortOrder: 101,
        ),
        _simpleProduct(
          name: 'Cheesy Garlic Hotdog Bun w/ Fries',
          category: 'Café Bites',
          price: 50,
          sortOrder: 102,
        ),
        _simpleProduct(
          name: 'Cinnamon Roll',
          category: 'Café Bites',
          price: 55,
          sortOrder: 103,
        ),
        _simpleProduct(
          name: 'Garlic Bread',
          category: 'Café Bites',
          price: 30,
          sortOrder: 104,
        ),
        _simpleProduct(
          name: 'Grilled Ham & Cheese Sandwich w/ Fries',
          category: 'Café Bites',
          price: 85,
          sortOrder: 105,
        ),
        _simpleProduct(
          name: 'Hamburger w/ Fries',
          category: 'Café Bites',
          price: 75,
          sortOrder: 106,
        ),
        _simpleProduct(
          name: 'Tuna Melt Bun',
          category: 'Café Bites',
          price: 70,
          sortOrder: 107,
        ),
        _simpleProduct(
          name: 'Shawerma Wrap',
          category: 'Café Bites',
          price: 79,
          sortOrder: 108,
        ),

        // =========================
        // PASTA
        // =========================
        _simpleProduct(
          name: 'Creamy Ground Pork Pasta',
          category: 'Pasta',
          price: 150,
          sortOrder: 201,
        ),
        _simpleProduct(
          name: 'Carbonara',
          category: 'Pasta',
          price: 135,
          sortOrder: 202,
        ),
        _simpleProduct(
          name: 'Pesto Pasta',
          category: 'Pasta',
          price: 115,
          sortOrder: 203,
          needsReview: true,
        ),
        _simpleProduct(
          name: 'Spaghetti',
          category: 'Pasta',
          price: 95,
          sortOrder: 204,
          needsReview: true,
        ),
        _simpleProduct(
          name: 'Tuna Pasta',
          category: 'Pasta',
          price: 110,
          sortOrder: 205,
        ),

        // =========================
        // DESSERTS
        // =========================
        _variantProduct(
          name: 'Egg Pie',
          category: 'Desserts',
          prices: {
            'slice': 65,
            'whole': 530,
          },
          sortOrder: 301,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Chocolate Cake',
          category: 'Desserts',
          prices: {
            'slice': 60,
            'whole': 390,
          },
          sortOrder: 302,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Yema Cake',
          category: 'Desserts',
          prices: {
            'slice': 60,
            'whole': 390,
          },
          sortOrder: 303,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Ube Yema',
          category: 'Desserts',
          prices: {
            'slice': 75,
            'whole': 450,
          },
          sortOrder: 304,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Lemon Chiffon',
          category: 'Desserts',
          prices: {
            'slice': 75,
            'whole': 485,
          },
          sortOrder: 305,
          needsReview: true,
        ),

        // =========================
        // SIDE BITES
        // =========================
        _simpleProduct(
          name: 'Cheese Sticks (6pcs)',
          category: 'Side Bites',
          price: 50,
          sortOrder: 401,
        ),
        _simpleProduct(
          name: 'Lumpia Shanghai (5pcs)',
          category: 'Side Bites',
          price: 50,
          sortOrder: 402,
        ),
        _simpleProduct(
          name: 'Nachos',
          category: 'Side Bites',
          price: 110,
          sortOrder: 403,
        ),
        _simpleProduct(
          name: 'Nuggets (5pcs)',
          category: 'Side Bites',
          price: 65,
          sortOrder: 404,
        ),
        _simpleProduct(
          name: "Vian's Siomai (5pcs)",
          category: 'Side Bites',
          price: 50,
          sortOrder: 405,
        ),
        _variantProduct(
          name: 'Fries',
          category: 'Side Bites',
          prices: {
            'bbq': 80,
            'cheese': 80,
            'sourCream': 80,
            'plain': 80,
          },
          sortOrder: 406,
        ),
        _variantProduct(
          name: 'Potato Wedges',
          category: 'Side Bites',
          prices: {
            'bbq': 50,
            'cheese': 50,
            'sourCream': 50,
            'plain': 50,
          },
          sortOrder: 407,
        ),

        // =========================
        // COFFEE
        // =========================
        _variantProduct(
          name: 'Americano',
          category: 'Coffee',
          prices: {
            'hot': 65,
            'iced12': 50,
            'iced16': 69,
          },
          sortOrder: 501,
        ),
        _variantProduct(
          name: 'Latte',
          category: 'Coffee',
          prices: {
            'hot': 85,
            'iced12': 55,
            'iced16': 95,
          },
          sortOrder: 502,
        ),
        _variantProduct(
          name: 'Cappuccino',
          category: 'Coffee',
          prices: {
            'hot': 95,
            'iced12': 95,
            'iced16': 95,
          },
          sortOrder: 503,
        ),
        _variantProduct(
          name: 'Caramel Macchiato',
          category: 'Coffee',
          prices: {
            'hot': 89,
            'iced12': 95,
            'iced16': 105,
          },
          sortOrder: 504,
        ),
        _variantProduct(
          name: 'Mocha',
          category: 'Coffee',
          prices: {
            'hot': 95,
            'iced12': 95,
            'iced16': 110,
          },
          sortOrder: 505,
        ),
        _variantProduct(
          name: 'Spanish Latte',
          category: 'Coffee',
          prices: {
            'hot': 95,
            'iced12': 95,
            'iced16': 105,
          },
          sortOrder: 506,
        ),
        _variantProduct(
          name: 'White Mocha',
          category: 'Coffee',
          prices: {
            'hot': 99,
            'iced12': 95,
            'iced16': 120,
          },
          sortOrder: 507,
        ),

        // =========================
        // VIAN'S SPECIAL COFFEE
        // =========================
        _variantProduct(
          name: 'Sea Salt Latte',
          category: "Vian's Special Coffee",
          prices: {
            'hot': 105,
            'iced12': 95,
            'iced16': 110,
          },
          sortOrder: 601,
        ),
        _variantProduct(
          name: 'Biscoff Latte',
          category: "Vian's Special Coffee",
          prices: {
            'iced12': 95,
            'iced16': 135,
          },
          sortOrder: 602,
        ),
        _variantProduct(
          name: 'Strawberry Latte',
          category: "Vian's Special Coffee",
          prices: {
            'hot': 65,
            'iced12': 120,
          },
          sortOrder: 603,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Tiramisu Latte',
          category: "Vian's Special Coffee",
          prices: {
            'hot': 75,
            'iced12': 130,
          },
          sortOrder: 604,
        ),
        _variantProduct(
          name: 'Dirty Matcha',
          category: "Vian's Special Coffee",
          prices: {
            'hot': 65,
            'iced12': 125,
          },
          sortOrder: 605,
        ),

        // =========================
        // NON-COFFEE
        // =========================
        _variantProduct(
          name: 'Chocolate',
          category: 'Non-Coffee',
          prices: {
            'hot': 89,
            'iced12': 95,
            'iced16': 99,
          },
          sortOrder: 701,
        ),
        _variantProduct(
          name: 'Matcha Latte',
          category: 'Non-Coffee',
          prices: {
            'hot': 99,
            'iced12': 95,
            'iced16': 115,
          },
          sortOrder: 702,
        ),
        _variantProduct(
          name: 'Sea Salt Matcha',
          category: 'Non-Coffee',
          prices: {
            'hot': 105,
            'iced12': 95,
            'iced16': 120,
          },
          sortOrder: 703,
        ),
        _variantProduct(
          name: 'Blueberry Milk',
          category: 'Non-Coffee',
          prices: {
            'hot': 0,
            'iced12': 85,
            'iced16': 110,
          },
          sortOrder: 704,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Choco Caramel',
          category: 'Non-Coffee',
          prices: {
            'hot': 0,
            'iced12': 95,
            'iced16': 110,
          },
          sortOrder: 705,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Green Kiwi Milk',
          category: 'Non-Coffee',
          prices: {
            'hot': 0,
            'iced12': 95,
            'iced16': 110,
          },
          sortOrder: 706,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Strawberry Milk',
          category: 'Non-Coffee',
          prices: {
            'hot': 0,
            'iced12': 95,
            'iced16': 125,
          },
          sortOrder: 707,
          needsReview: true,
        ),
        _variantProduct(
          name: 'Strawberry Matcha',
          category: 'Non-Coffee',
          prices: {
            'hot': 0,
            'iced12': 95,
            'iced16': 115,
          },
          sortOrder: 708,
          needsReview: true,
        ),

        // =========================
        // FRAPPE
        // =========================
        _simpleProduct(
          name: 'Coffee Based Frappe',
          category: 'Frappe',
          price: 70,
          sortOrder: 801,
        ),
        _simpleProduct(
          name: 'Latte Frappe',
          category: 'Frappe',
          price: 70,
          sortOrder: 802,
        ),
        _simpleProduct(
          name: 'Caramel Frappe',
          category: 'Frappe',
          price: 89,
          sortOrder: 803,
        ),
        _simpleProduct(
          name: 'Mocha Frappe',
          category: 'Frappe',
          price: 99,
          sortOrder: 804,
        ),
        _simpleProduct(
          name: 'White Mocha Frappe',
          category: 'Frappe',
          price: 99,
          sortOrder: 805,
        ),
        _simpleProduct(
          name: 'Blueberry Frappe',
          category: 'Frappe',
          price: 80,
          sortOrder: 806,
        ),
        _simpleProduct(
          name: 'Choco Frappe',
          category: 'Frappe',
          price: 80,
          sortOrder: 807,
        ),
        _simpleProduct(
          name: 'Matcha Frappe',
          category: 'Frappe',
          price: 90,
          sortOrder: 808,
        ),
        _simpleProduct(
          name: 'Strawberry Frappe',
          category: 'Frappe',
          price: 80,
          sortOrder: 809,
        ),
        _simpleProduct(
          name: 'Vanilla Frappe',
          category: 'Frappe',
          price: 79,
          sortOrder: 810,
        ),
      ];

  static Map<String, dynamic> _simpleProduct({
    required String name,
    required String category,
    required num price,
    required int sortOrder,
    bool needsReview = false,
  }) {
    return {
      'name': name,
      'category': category,
      'description': '',
      'basePrice': price.toDouble(),
      'prices': {
        'default': price.toDouble(),
      },
      'availableVariants': ['default'],
      'hasVariants': false,
      'isAvailable': true,
      'isBestSeller': false,
      'stockQty': 999,
      'imageUrl': _assetPathFor(name, category),
      'tags': <String>[],
      'displayType': _displayTypeFromCategory(category),
      'sortOrder': sortOrder,
      'needsReview': needsReview,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _variantProduct({
    required String name,
    required String category,
    required Map<String, num> prices,
    required int sortOrder,
    bool needsReview = false,
  }) {
    final normalizedPrices = <String, double>{};
    prices.forEach((key, value) {
      normalizedPrices[key] = value.toDouble();
    });

    final nonZeroPrices = normalizedPrices.values.where((e) => e > 0).toList();
    final basePrice =
        nonZeroPrices.isEmpty ? 0.0 : nonZeroPrices.reduce((a, b) => a < b ? a : b);

    return {
      'name': name,
      'category': category,
      'description': '',
      'basePrice': basePrice,
      'prices': normalizedPrices,
      'availableVariants': normalizedPrices.keys.toList(),
      'hasVariants': true,
      'isAvailable': true,
      'isBestSeller': false,
      'stockQty': 999,
      'imageUrl': _assetPathFor(name, category),
      'tags': <String>[],
      'displayType': _displayTypeFromCategory(category),
      'sortOrder': sortOrder,
      'needsReview': needsReview,
      'createdAt': FieldValue.serverTimestamp(),
    };
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

  static String _assetPathFor(String name, String category) {
    const manualMap = {
      // =========================
      // CAFE BITES
      // =========================
      'Cheese Roll': 'assets/Cafe Bites/Cheese Roll.jpg',
      'Cheesy Garlic Hotdog Bun w/ Fries':
          'assets/Cafe Bites/Cheesy Garlic Hotdog Bun w_ Fries.jpg',
      'Cinnamon Roll': 'assets/Cafe Bites/Cinnamon Roll.jpg',
      'Garlic Bread': 'assets/Cafe Bites/Garlic Bread.jpg',
      'Grilled Ham & Cheese Sandwich w/ Fries':
          'assets/Cafe Bites/Grilled Ham and Cheese Sandwich 2_ Fries.jpg',
      'Hamburger w/ Fries': 'assets/Cafe Bites/Hamburger w_ Fries.jpg',
      'Tuna Melt Bun': 'assets/Cafe Bites/Tuna Melt Bun.jpg',
      'Shawerma Wrap': 'assets/Cafe Bites/Shawarma Wrap.jpg',

      // =========================
      // COFFEE
      // =========================
      'Americano': 'assets/Coffee/Americano.jpg',
      'Cappuccino': 'assets/Coffee/Cappuccino.png',
      'Caramel Macchiato': 'assets/Coffee/Caramel Macchiato.jpg',
      'Latte': 'assets/Coffee/Latte.jpg',
      'Mocha': 'assets/Coffee/Mocha.jpg',
      'Spanish Latte': 'assets/Coffee/Spanish Latte.jpg',
      'White Mocha': 'assets/Coffee/White Mocha.jpg',

      // =========================
      // FRAPPE
      // =========================
      'Coffee Based Frappe': 'assets/Frappe/Coffee Based Frappe.jpg',
      'Latte Frappe': 'assets/Frappe/Latte Frappe.jpg',
      'Caramel Frappe': 'assets/Frappe/Caramel Frappe.jpg',
      'Mocha Frappe': 'assets/Frappe/Mocha Frappe.jpg',
      'White Mocha Frappe': 'assets/Frappe/White Mocha Frappe.jgp',
      'Blueberry Frappe': 'assets/Frappe/Blueberry Frappe.png',
      'Choco Frappe': 'assets/Frappe/Choco Frappe.png',
      'Matcha Frappe': 'assets/Frappe/Matcha Frappe.png',
      'Strawberry Frappe': 'assets/Frappe/Strawberry Frappe.png',
      'Vanilla Frappe': 'assets/Frappe/Vanilla Frappe.png',

      // =========================
      // NON COFFEE
      // =========================
      'Blueberry Milk': 'assets/Non Coffee/Blueberry Milk.jpg',
      'Choco Caramel': 'assets/Non Coffee/Choco-Caramel.jpg',
      'Chocolate': 'assets/Non Coffee/Chocolate.jpg',
      'Green Kiwi Milk': 'assets/Non Coffee/Green kiwi milk.jpg',
      'Matcha Latte': 'assets/Non Coffee/Matcha Latte.jpg',
      'Sea Salt Matcha': 'assets/Non Coffee/Sea salt matcha.jpg',
      'Strawberry Matcha': 'assets/Non Coffee/Strawberry Matcha.jpg',
      'Strawberry Milk': 'assets/Non Coffee/Strawberry Milk.jpg',

      // =========================
      // PASTA
      // =========================
      'Carbonara': 'assets/Pasta/Carbonara.webp',
      'Creamy Ground Pork Pasta': 'assets/Pasta/Creamy ground pork pasta.jpg',
      'Pesto Pasta': 'assets/Pasta/Pesto Pasta.jpg',
      'Spaghetti': 'assets/Pasta/Spaghetti.webp',
      'Tuna Pasta': 'assets/Pasta/Tuna Pasta.jpg',

      // =========================
      // PIZZA
      // =========================
      'All Meat Supreme': 'assets/Pizza/All meat supreme.jpg',
      'Classic Mango': 'assets/Pizza/Classic Mango.jpg',
      'Mango Hawaiian': 'assets/Pizza/Mango Hawaiian.jpg',
      'Margherita Pizza': 'assets/Pizza/Margherita Pizza.jpg',
      'Pepperoni': 'assets/Pizza/Pepperoni.jpg',

      // =========================
      // RICE BOWLS
      // =========================
      'Burger Steak': 'assets/Rice bowls/Burger Stake.jpg',
      'Chicken Ala King': 'assets/Rice bowls/Chicken Ala King.jpg',
      'Chicken Katsu': 'assets/Rice bowls/Chicken Calsu.jpg',
      'Chicken Teriyaki': 'assets/Rice bowls/Chicken Teriyaki.jpg',
      'Garlic Pepper Beef': 'assets/Rice bowls/Garlic Pepper Beef.jpg',
      'Grilled Pan Pork Belly': 'assets/Rice bowls/Grilled Pork Belly.jpg',
      'Hungarian Sausage & Rice':
          'assets/Rice bowls/Hungarian Sausage and Rice.jpg',
      'Lumpia & Rice': 'assets/Rice bowls/Lumpia & Rice.jpg',
      'Nuggets & Rice': 'assets/Rice bowls/Nuggets and Rice.jpg',
      'Pork Adobo': 'assets/Rice bowls/Pork Adobo.jpg',
      'Pork Chop': 'assets/Rice bowls/Pork Chop.jpg',
      'Pork Sisig': 'assets/Rice bowls/Pork Sisig.jpg',
      'Pork Tapa': 'assets/Rice bowls/Pork Tapa.jpg',
      "Vian's Siomai Rice": 'assets/Rice bowls/Siomai Rice.jpg',

      // =========================
      // SIDE BITES
      // =========================
      'Cheese Sticks (6pcs)': 'assets/Side Bites/Cheese sticks.jpg',
      'Lumpia Shanghai (5pcs)': 'assets/Side Bites/Lumpia Shanghai.jpg',
      'Nachos': 'assets/Side Bites/Nachos.jpg',
      'Nuggets (5pcs)': 'assets/Side Bites/Nuggets.jpg',
      "Vian's Siomai (5pcs)": 'assets/Side Bites/Siomai.jpg',
      'Fries': 'assets/Side Bites/Fries.jpg',
      'Potato Wedges': 'assets/Side Bites/Potato Wedges.jpg',

      // =========================
      // DESSERTS
      // =========================
      'Egg Pie': 'assets/Desserts/Egg Pie.png',
      'Chocolate Cake': 'assets/Desserts/Chocolate Cake.png',
      'Yema Cake': 'assets/Desserts/Yema Cake.png',
      'Ube Yema': 'assets/Desserts/Ube Yema.png',
      'Lemon Chiffon': 'assets/Desserts/Lemon Chiffon.png',

      // =========================
      // SPECIAL COFFEE
      // =========================
      'Biscoff Latte': 'assets/Special Coffee/Biscoff Latte.jpg',
      'Sea Salt Latte': 'assets/Speci2al Coffee/Sea Salt Latte.jpg',
      'Strawberry Latte': 'assets/Special Coffee/Strawberry Latte.jpg',
      'Tiramisu Latte': 'assets/Special Coffee/Tiramisu Latte.jpg',

      // =========================
      // OPTIONAL / CURRENTLY NO SHARED FILE MATCH
      // =========================
      'Dirty Matcha': 'assets/Non Coffee/Dirty Matcha.png',
    };

    return manualMap[name] ?? '';
  }
}