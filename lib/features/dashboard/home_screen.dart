// lib/features/dashboard/home_screen.dart

import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
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

  // FUNGSI BARU: Untuk pindah tab
  void switchToFeed() {
    setState(() {
      _selectedIndex = 0; // Pindah ke tab Feed (Index 0)
    });
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      const FeedScreen(),
      const MapScreen(),
      // Meneruskan callback switchToFeed ke UploadScreen
      UploadScreen(
        userId: widget.userId,
        onUploadSuccess: switchToFeed, // <<< CALLBACK DITAMBAHKAN
      ),
    ];
  }
  // ... (sisa kode _onItemTapped, _appBarTitle, _logout tetap sama)

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

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
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
