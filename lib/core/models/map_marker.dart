// lib/core/models/map_marker.dart

class MapMarker {
  final int id;
  final double latitude;
  final double longitude;
  final String severity; // SERIUS atau TIDAK_SERIUS

  MapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.severity,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    // Model ini memetakan data dari endpoint /api/map_data
    return MapMarker(
      id: json['id'] as int,

      // Menggunakan toDouble() untuk memastikan konversi dari tipe num (MySQL DECIMAL/NUMERIC)
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['long'] as num).toDouble(),

      severity: json['severity'] as String,
    );
  }
}
