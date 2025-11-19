// lib/core/services/upload_service.dart

// lib/core/services/upload_service.dart

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
// >>> TAMBAHKAN BARIS INI:
import 'package:http_parser/http_parser.dart';
// <<<

import '../../config/app_config.dart';
import '../models/post.dart';
// ... (sisa kode)

class UploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  Future<Post> uploadDamageReport({
    required XFile imageFile,
    required double lat,
    required double long,
    required int userId,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;

      // ⚠️ LOGIKA ADAPTIF UNTUK MULTIPART FILE
      MultipartFile filePart;

      if (kIsWeb) {
        // --- JIKA WEB ---
        // Baca data bytes dari XFile
        final bytes = await imageFile.readAsBytes();
        filePart = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        );
      } else {
        // --- JIKA MOBILE/DESKTOP (dart:io tersedia) ---
        filePart = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        );
      }

      // Siapkan Multipart/Form Data
      FormData formData = FormData.fromMap({
        'latitude': lat.toString(),
        'longitude': long.toString(),
        'user_id': userId.toString(),
        'image': filePart, // Menggunakan variabel filePart yang sudah adaptif
      });

      // Kirim Request POST
      final response = await _dio.post('/upload', data: formData);

      if (response.statusCode == 200) {
        return Post.fromJson(response.data['data']);
      }
      throw Exception('Upload failed: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception(
        'Connection error during upload. ${e.response?.data['error'] ?? 'Server error'}',
      );
    }
  }
}
