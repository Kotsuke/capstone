// lib/features/upload/upload_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/models/post.dart';

class UploadScreen extends StatefulWidget {
  final int userId;

  const UploadScreen({super.key, required this.userId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final UploadService _uploadService = UploadService();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  bool _isLoading = false;
  String? _locationMessage;
  double? _lat;
  double? _long;

  // 1. Fungsi Ambil Foto (Kamera atau Galeri)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    setState(() {
      _image = picked;
      _locationMessage = null; // Reset status lokasi
    });
  }

  // 2. Fungsi Ambil Lokasi GPS
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS nyala
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Ambil lokasi saat ini
    return await Geolocator.getCurrentPosition();
  }

  // 3. Fungsi Upload Utama (dengan Validasi AI)
  void _submitReport() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _locationMessage = "Getting location...";
    });

    try {
      // Step A: Ambil Lokasi
      Position position = await _determinePosition();
      setState(() {
        _lat = position.latitude;
        _long = position.longitude;
        _locationMessage = "Analyzing image with AI...";
      });

      // Step B: Kirim ke Backend dan Proses AI
      Post result = await _uploadService.uploadDamageReport(
        imageFile: _image!,
        lat: _lat!,
        long: _long!,
        userId: widget.userId,
      );

      // --- LOGIKA VALIDASI AI (Re-take loop) ---
      if (result.potholeCount == 0) {
        // ❌ DETEKSI GAGAL: Minta user coba lagi
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Gagal: AI tidak mendeteksi Pothole. Mohon ambil foto yang lebih jelas atau sudut yang berbeda.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        // Biarkan _image tetap ada di preview
      } else {
        // ✅ DETEKSI SUKSES: Lanjut ke tampilan hasil
        if (!mounted) return;
        _showSuccessDialog(result);
      }
      // ------------------------------------------
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _locationMessage = null; // Clear message
        });
      }
    }
  }

  void _showSuccessDialog(Post post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Analysis Complete!",
          style: TextStyle(color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Severity: ${post.severity}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Potholes detected: ${post.potholeCount}"),
            const SizedBox(height: 10),
            Text("Caption: ${post.caption}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Kembali ke Home/Feed
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AREA PREVIEW GAMBAR
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: _image == null
                    ? const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // TOMBOL PILIH GAMBAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text("Camera"),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // INDIKATOR STATUS
              if (_locationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _locationMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),

              // TOMBOL SUBMIT
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (_image != null && !_isLoading)
                      ? _submitReport
                      : null,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "UPLOAD REPORT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
