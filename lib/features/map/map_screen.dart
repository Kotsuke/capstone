// lib/features/map/map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/models/map_marker.dart';
import '../../../core/services/post_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PostService _postService = PostService();
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  bool _isLoading = true;

  // Koordinat default (misal di pusat Jawa)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-7.7956, 110.3695), // Yogyakarta/Central Java
    zoom: 8.0,
  );

  @override
  void initState() {
    super.initState();
    // Maps di Web membutuhkan API Key di index.html
    if (!kIsWeb) {
      _loadMapMarkers();
    }
  }

  // Menentukan warna marker berdasarkan hasil AI (Severity)
  BitmapDescriptor _getMarkerIcon(String severity) {
    if (severity == 'SERIUS') {
      // Merah untuk kerusakan parah
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else {
      // Kuning/Oranye untuk kerusakan tidak terlalu serius
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  Future<void> _loadMapMarkers() async {
    setState(() => _isLoading = true);
    try {
      final markersData = await _postService.fetchMapMarkers();

      _markers.clear();
      for (var data in markersData) {
        final markerId = MarkerId(data.id.toString());
        final marker = Marker(
          markerId: markerId,
          position: LatLng(data.latitude, data.longitude),
          icon: _getMarkerIcon(data.severity),
          infoWindow: InfoWindow(
            title: "Damage Report #${data.id}",
            snippet:
                "Severity: ${data.severity} | Location: (${data.latitude.toStringAsFixed(3)})",
          ),
        );
        _markers[markerId] = marker;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load map data: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Handling Web (karena google_maps_flutter tidak didukung langsung di Web)
    if (kIsWeb) {
      return const Center(
        child: Text(
          "Map Feature is not fully implemented for web build yet. Check README for setup.",
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              markers: Set<Marker>.of(_markers.values),
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) =>
                  _loadMapMarkers(), // Load data saat map dibuat
            ),
    );
  }
}
