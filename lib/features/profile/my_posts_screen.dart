import 'package:flutter/material.dart';
import 'package:capstone/core/models/post.dart';
import 'package:capstone/core/services/post_service.dart';
import 'package:capstone/config/app_config.dart';

class MyPostsScreen extends StatefulWidget {
  final int userId;

  const MyPostsScreen({super.key, required this.userId});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _myPostsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    setState(() {
      _myPostsFuture = _postService.fetchUserPosts(widget.userId);
    });
  }

  // Fungsi Hapus dengan Dialog Konfirmasi
  void _confirmDelete(int postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              try {
                await _postService.deletePost(postId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report deleted successfully')),
                );
                _refreshPosts(); // Refresh list setelah hapus
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: FutureBuilder<List<Post>>(
        future: _myPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('You haven\'t posted anything yet.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              // Fix URL gambar
              final fileName = post.imageUrl.split('/').last;
              final fixedUrl = '${AppConfig.baseImageUrl}$fileName';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fixedUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      headers: const {"ngrok-skip-browser-warning": "true"},
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  title: Text(
                    post.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${post.date} • ${post.severity}",
                    style: TextStyle(
                      color: post.severity == 'SERIUS'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(post.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
