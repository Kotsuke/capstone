// lib/core/services/post_service.dart

import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../models/map_marker.dart';
import '../models/post.dart';

class PostService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {
        // Header sakti untuk menembus warning page ngrok
        "ngrok-skip-browser-warning": "true",
      },
    ),
  );

  /// Mengambil semua post detail untuk tampilan Feed.
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get('/posts');

      // 🔍 DEBUG: Lihat data mentah di Terminal (Run tab)
      print("----- START DEBUG DATA -----");
      print("Status Code: ${response.statusCode}");
      print("Raw Data: ${response.data}");
      print("----- END DEBUG DATA -----");

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((json) {
          try {
            return Post.fromJson(json);
          } catch (e) {
            // 🔍 DEBUG: Tangkap item yang bikin error
            print("❌ ERROR PARSING JSON ITEM: $e");
            print("DATA YANG GAGAL: $json");
            throw e; // Lempar ulang agar FutureBuilder tahu
          }
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ Network Error: ${e.response?.data}');
      throw Exception('Failed to load feed. Network error.');
    } catch (e) {
      print('❌ Unknown Error: $e');
      rethrow;
    }
  }

  /// Mengambil data lightweight (Lat/Long/Severity) khusus untuk Map.
  Future<List<MapMarker>> fetchMapMarkers() async {
    try {
      final response = await _dio.get('/map_data');

      if (response.statusCode == 200 && response.data is List) {
        // Mapping list JSON menjadi List<MapMarker>
        return (response.data as List)
            .map((json) => MapMarker.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching map data: ${e.response?.data}');
      throw Exception('Failed to load map markers.');
    }
  }

  /// Mengirim Vote (UP atau DOWN) ke post tertentu.
  /// Mengembalikan jumlah vote terbaru dari server.
  Future<Map<String, int>> sendVote({
    required int postId,
    required int userId,
    required String voteType, // 'UP' atau 'DOWN'
  }) async {
    try {
      final response = await _dio.post(
        '/posts/$postId/vote',
        data: {'user_id': userId, 'vote_type': voteType},
      );

      if (response.statusCode == 200 &&
          response.data.containsKey('new_counts')) {
        // Backend Flask mengembalikan new_counts: {'up': X, 'down': Y}
        return {
          'up': response.data['new_counts']['up'] as int,
          'down': response.data['new_counts']['down'] as int,
        };
      }
      throw Exception('Voting failed: ${response.data['message']}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to send vote: ${e.response?.data['message'] ?? 'Network error'}',
      );
    }
  }
}
