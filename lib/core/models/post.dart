// lib/core/models/post.dart

class Post {
  final int id;
  final int userId;
  final String uploadedBy; // Full Name/Username pengirim
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String severity; // SERIUS atau TIDAK_SERIUS
  final int potholeCount; // Hasil deteksi AI
  final String caption; // Caption otomatis dari AI
  final int upvotes; // Jumlah Thumbs Up
  final int downvotes; // Jumlah Thumbs Down
  final String date;

  Post({
    required this.id,
    required this.userId,
    required this.uploadedBy,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.potholeCount,
    required this.caption,
    required this.upvotes,
    required this.downvotes,
    required this.date,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Memproses nested data votes dan memastikan konversi tipe data
    final votes = json['votes'] as Map<String, dynamic>?;

    return Post(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      // Mengambil nama user (full_name) yang disiapkan di Flask
      uploadedBy: json['uploaded_by'] as String? ?? 'Unknown User',

      // Menggunakan toDouble() karena MySQL NUMERIC/DECIMAL di-parse sebagai double di Dart
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['long'] as num).toDouble(),

      imageUrl: json['image_url'] as String,
      severity: json['severity'] as String,
      potholeCount: json['pothole_count'] as int,
      caption: json['caption'] as String? ?? '',

      // Memproses Votes
      upvotes: votes?['up'] as int? ?? 0,
      downvotes: votes?['down'] as int? ?? 0,

      date: json['date'] as String,
    );
  }
}
