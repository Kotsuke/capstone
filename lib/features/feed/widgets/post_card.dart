// lib/features/feed/widgets/post_card.dart

import 'package:flutter/material.dart';
import '../../../core/models/post.dart';
import '../../../core/services/post_service.dart';
import '../../../config/app_config.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final int currentUserId; // ID user yang sedang login
  final VoidCallback onVote; // Callback untuk refresh data di FeedScreen

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onVote,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  bool _isVoting = false;

  // State lokal untuk tampilan vote cepat
  late int _upvotes;
  late int _downvotes;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dari model awal
    _upvotes = widget.post.upvotes;
    _downvotes = widget.post.downvotes;
  }

  IconData _getSeverityIcon(String severity) {
    return severity == 'SERIUS'
        ? Icons.warning_amber
        : Icons.check_circle_outline;
  }

  Color _getSeverityColor(String severity) {
    return severity == 'SERIUS' ? Colors.red.shade700 : Colors.green;
  }

  // FUNGSI UTAMA VOTE: Mengirim request ke Flask dan mengupdate UI
  void _sendVote(String voteType) async {
    if (_isVoting) return;

    setState(() {
      _isVoting = true;
    });

    try {
      final newCounts = await _postService.sendVote(
        postId: widget.post.id,
        userId: widget.currentUserId,
        voteType: voteType,
      );

      // Update state lokal dengan jumlah vote terbaru dari server
      setState(() {
        _upvotes = newCounts['up'] ?? 0;
        _downvotes = newCounts['down'] ?? 0;
        // Panggil callback untuk me-refresh data di FeedScreen
        widget.onVote();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // URL gambar disatukan dari base URL Flask dan image path
    final imageUrl = widget.post.imageUrl;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (USER & SEVERITY LABEL)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.uploadedBy, // Menampilkan Full Name
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.post.date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                // Display Severity Label (Hasil AI)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(
                      widget.post.severity,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getSeverityIcon(widget.post.severity),
                        color: _getSeverityColor(widget.post.severity),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.severity,
                        style: TextStyle(
                          color: _getSeverityColor(widget.post.severity),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. GAMBAR KERUSAKAN (DARI FLASK)
          Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.red[100],
                child: const Center(
                  child: Text("Failed to load image from server"),
                ),
              );
            },
          ),

          // 3. FOOTER (CAPTION & VOTE BUTTONS)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // TOMBOL THUMBS UP
                    TextButton.icon(
                      onPressed: _isVoting ? null : () => _sendVote('UP'),
                      icon: _isVoting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.thumb_up_alt_outlined, size: 18),
                      label: Text(_upvotes.toString()),
                    ),
                    // TOMBOL THUMBS DOWN
                    TextButton.icon(
                      onPressed: _isVoting ? null : () => _sendVote('DOWN'),
                      icon: _isVoting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.thumb_down_alt_outlined, size: 18),
                      label: Text(_downvotes.toString()),
                    ),
                    const Spacer(),
                    Text(
                      'Potholes: ${widget.post.potholeCount}',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
