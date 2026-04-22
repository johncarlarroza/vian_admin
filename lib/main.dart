import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vian_admin/login.dart';
import 'package:vian_admin/pages/seed_products_page.dart';

import 'firebase_options.dart';
import 'basepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VianApp());
}

class VianApp extends StatelessWidget {
  const VianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIAN Café Admin',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        colorScheme: ColorScheme.fromSeed(  
          seedColor: const Color(0xFF1F6D44),
        ),
      ),
      home: const LoginPage(),
    );
  }
}