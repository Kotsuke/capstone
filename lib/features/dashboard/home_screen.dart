// lib/features/dashboard/home_screen.dart

import 'package:flutter/material.dart';
import '../auth/login_screen.dart'; // Import LoginScreen untuk navigasi logout
import '../feed/feed_screen.dart';
import '../map/map_screen.dart';
import '../upload/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String fullName;

  const HomeScreen({super.key, required this.userId, required this.fullName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FeedScreen(),
      const MapScreen(),
      UploadScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Recent Reports';
      case 1:
        return 'Pothole Map';
      case 2:
        return 'New Damage Report';
      default:
        return 'Smart Infra Monitoring';
    }
  }

  // FUNGSI LOGOUT BARU
  void _logout() {
    // Di aplikasi nyata, ini tempat menghapus token/session lokal.
    // Di sini, kita hanya navigasi kembali ke LoginScreen dan menghapus semua riwayat.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          // Display User Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Hi, ${widget.fullName.split(' ')[0]}!',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // LOGOUT BUTTON
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Report',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
