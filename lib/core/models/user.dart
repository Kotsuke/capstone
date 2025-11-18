// lib/core/models/user.dart

class User {
  final int id;
  final String username;
  final String email;
  final String fullName; // Field yang dirombak

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Fungsi ini memetakan key dari respons JSON Flask ke model Dart
    return User(
      // ID bisa datang sebagai 'user_id' atau 'id', kita cek keduanya
      id: json['user_id'] ?? json['id'] ?? 0,

      username: json['username'] ?? 'Anonymous',
      email: json['email'] ?? '',

      // MENGAMBIL FULL NAME DARI RESPONS BACKEND
      fullName: json['full_name'] ?? 'Pengguna',
    );
  }
}
