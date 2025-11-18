// lib/main.dart

import 'package:flutter/material.dart';
import '../../../features/auth/login_screen.dart'; // Import LoginScreen

void main() {
  // Pastikan binding Flutter sudah diinisialisasi untuk plugin (kamera/lokasi)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Infrastructure Monitoring',
      debugShowCheckedModeBanner: false,

      // Tema Aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Set warna sekunder (merah) untuk aksen dan tombol
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(secondary: Colors.redAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),

      // Halaman Awal
      home: const LoginScreen(),
    );
  }
}
