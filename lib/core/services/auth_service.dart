// lib/core/services/auth_service.dart

import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../models/user.dart';

class AuthService {
  // Inisialisasi Dio dengan Base URL dari AppConfig
  // Base URL sudah diset ke http://10.0.2.2:5000/api
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  /// Mengirim data registrasi ke endpoint /api/register
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String fullName, // Tambahan field full_name
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      if (response.statusCode == 201) {
        // Jika sukses (201 Created), kembalikan data user yang terdaftar
        // Response.data['user_id'] dan response.data['full_name']
        return User.fromJson(response.data);
      }
      // Seharusnya error 201 tidak terjadi jika backend sudah menangani 409/400
      throw Exception('Registration failed.');
    } on DioException catch (e) {
      // Tangani error dari server (misalnya 409 Conflict, 400 Bad Request)
      // Kita ambil pesan error dari body respons JSON Flask
      throw Exception(
        e.response?.data['error'] ??
            'Network error occurred during registration.',
      );
    }
  }

  /// Mengirim kredensial login ke endpoint /api/login
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          // Flask menerima identifier di field 'username', baik itu username atau email
          'username': identifier,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Jika login sukses, kita kembalikan User object
        return User.fromJson(response.data);
      }
      throw Exception('Login failed.');
    } on DioException catch (e) {
      // Tangani error 401 Unauthorized atau error lainnya
      throw Exception(
        e.response?.data['error'] ?? 'Network error occurred during login.',
      );
    }
  }
}
