// lib/features/dashboard/home_screen.dart

import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../feed/feed_screen.dart';
import '../map/map_screen.dart';
import '../upload/upload_screen.dart';
// Import screen history yang baru kita buat
import '../profile/my_posts_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String fullName;

  const HomeScreen({super.key, required this.userId, required this.fullName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 1. GLOBAL KEY: Kunci rahasia agar HomeScreen bisa "menyuruh" FeedScreen refresh
  // Pastikan kamu sudah mengubah '_FeedScreenState' menjadi 'FeedScreenState' (Public) di feed_screen.dart
  final GlobalKey<FeedScreenState> _feedKey = GlobalKey<FeedScreenState>();

  late final List<Widget> _screens;

  // FUNGSI PINDAH TAB + REFRESH OTOMATIS
  void switchToFeed() {
    setState(() {
      _selectedIndex = 0; // Pindah ke tab Feed (Index 0)
    });

    // Paksa Feed untuk refresh data terbaru dari server setelah upload sukses
    Future.delayed(const Duration(milliseconds: 100), () {
      _feedKey.currentState?.refreshFeed();
    });
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      // 2. PASANG KEY KE FEEDSCREEN
      FeedScreen(key: _feedKey, userId: widget.userId),
      const MapScreen(),
      UploadScreen(userId: widget.userId, onUploadSuccess: switchToFeed),
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
          // --- 3. TOMBOL HISTORY / MY POSTS (BARU) ---
          IconButton(
            icon: const Icon(Icons.history), // Ikon Jam/History
            tooltip: 'My Reports',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyPostsScreen(userId: widget.userId),
                ),
              );
            },
          ),

          // NAMA USER
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

          // TOMBOL LOGOUT
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
