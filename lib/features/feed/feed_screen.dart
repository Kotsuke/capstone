// lib/features/feed/feed_screen.dart

import 'package:flutter/material.dart';
import '../../../core/models/post.dart';
import '../../../core/services/post_service.dart';
// HAPUS import home_screen.dart, kita tidak butuh lagi!
import '../../../features/feed/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  final int userId;

  // Tambahkan Key di sini
  const FeedScreen({super.key, required this.userId});

  @override
  // HAPUS TANDA UNDERSCORE '_' PADA NAMA STATE
  FeedScreenState createState() => FeedScreenState();
}

// HAPUS TANDA UNDERSCORE '_' DISINI JUGA (JADI PUBLIC)
class FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    return await _postService.fetchPosts();
  }

  // GANTI NAMA FUNGSI JADI PUBLIC (Hapus _) AGAR BISA DIPANGGIL DARI LUAR
  Future<void> refreshFeed() async {
    setState(() {
      _postsFuture = _fetchPosts();
    });
    await _postsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshFeed, // Panggil fungsi public tadi
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // ... (KODE DI DALAM SINI SAMA PERSIS, TIDAK ADA YG BERUBAH)
            // ... Pastikan bagian ListView.builder memanggil post_card dengan benar
            // ...
            // CONTOH BAGIAN YANG SAMA:
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final posts = snapshot.data;
            if (posts == null || posts.isEmpty) {
              return const Center(child: Text('No reports found.'));
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  currentUserId: widget.userId,
                  onVote: refreshFeed, // Callback refresh
                );
              },
            );
          },
        ),
      ),
    );
  }
}
