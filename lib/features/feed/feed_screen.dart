// lib/features/feed/feed_screen.dart

import 'package:flutter/material.dart';
// Ganti semua import agar menggunakan package:nama_proyek/path/ke/file
import '../../../core/models/post.dart';

import '../../../core/services/post_service.dart';

import '../dashboard/home_screen.dart'; // Import HomeScreen yang benar

import 'widgets/post_card.dart'; // Import PostCard yang benar // Import PostCard yang benar

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _postsFuture;

  // Mendapatkan ID user yang sedang login dari context (menggunakan findAncestorWidgetOfExactType)
  int get _currentUserId {
    // Cari parent HomeScreen di widget tree
    // Kita pastikanHomeScreen diimpor dan digunakan sebagai container utama
    final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
    // Jika HomeScreen ditemukan, ambil userId-nya. Default ke 0 jika tidak ditemukan.
    return homeScreen?.userId ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    return await _postService.fetchPosts();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _postsFuture = _fetchPosts();
    });

    // Optional: tunggu sedikit biar animasi refresh smooth
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ Peringatan: Akses _currentUserId di luar FutureBuilder
    final currentUserId = _currentUserId;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load feed: ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final posts = snapshot.data;

            // 3. Empty State
            if (posts == null || posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No reports found. Be the first to upload one!'),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _refreshFeed,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            // 4. Data Loaded State
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  post: post,
                  currentUserId: currentUserId,
                  onVote: _refreshFeed, // Panggil refresh setelah vote
                );
              },
            );
          },
        ),
      ),
    );
  }
}
