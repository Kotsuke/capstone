// lib/core/services/upload_service.dart

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../models/post.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class UploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  /// Mengirim laporan kerusakan (Gambar, Lokasi, User ID) ke endpoint /api/upload.
  Future<Post> uploadDamageReport({
    required XFile imageFile, // File gambar yang diambil dari kamera/galeri
    required double lat,
    required double long,
    required int userId,
  }) async {
    try {
      // 1. Tentukan nama file
      String fileName = imageFile.path.split('/').last;

      // 2. Siapkan Multipart/Form Data
      FormData formData = FormData.fromMap({
        // Data Text/JSON
        'latitude': lat.toString(),
        'longitude': long.toString(),
        'user_id': userId.toString(),

        // File Gambar (Menggunakan MultipartFile)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          // Tentukan media type (penting untuk server Flask)
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // 3. Kirim Request POST
      final response = await _dio.post('/upload', data: formData);

      if (response.statusCode == 200) {
        // Backend Flask harus merespons dengan key 'data' yang berisi Post object
        return Post.fromJson(response.data['data']);
      }
      throw Exception('Upload failed: ${response.statusMessage}');
    } on DioException catch (e) {
      // Tangani error jaringan, timeout, atau error dari Flask
      throw Exception(
        'Connection error during upload. ${e.response?.data['error'] ?? 'Server error'}',
      );
    }
  }
}
