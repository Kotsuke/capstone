// lib/features/upload/upload_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data'; // Untuk Uint8List (Image.memory)

import '../../../core/services/upload_service.dart';
import '../../../core/models/post.dart';
// Asumsi HomeScreen sudah diimpor jika diperlukan untuk findAncestorWidget (tapi kita hindari untuk menjaga kebersihan code)

class UploadScreen extends StatefulWidget {
  final int userId;
  final void Function() onUploadSuccess; // Callback dari HomeScreen

  const UploadScreen({
    super.key,
    required this.userId,
    required this.onUploadSuccess,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final UploadService _uploadService = UploadService();
  final ImagePicker _picker = ImagePicker();

  // --- STATE VARIABLES ---
  XFile? _image;
  Uint8List? _imageBytes; // Digunakan khusus untuk preview di Web
  bool _isLoading = false;
  String? _locationMessage;
  double? _lat;
  double? _long;
  // -----------------------

  // 1. Fungsi Ambil Foto (Kamera atau Galeri)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      if (kIsWeb) {
        // Jika di Web, baca bytes-nya
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _image = picked;
          _locationMessage = null;
        });
      } else {
        // Jika di Mobile, cukup simpan XFile
        setState(() {
          _imageBytes = null;
          _image = picked;
          _locationMessage = null;
        });
      }
    }
  }

  // 2. Fungsi Ambil Lokasi GPS (Dipanggil oleh _submitReport)
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

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

      // --- LOGIKA VALIDASI AI ---
      if (result.potholeCount == 0) {
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
      } else {
        // ✅ DETEKSI SUKSES
        if (!mounted) return;
        _showSuccessDialog(result);
      }
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
          _locationMessage = null;
        });
      }
    }
  }

  // 4. Fungsi Menampilkan Dialog Sukses
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
              // Panggil callback untuk pindah ke tab Feed
              widget.onUploadSuccess();
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
              // AREA PREVIEW GAMBAR (LOGIC ADAPTIF WEB/MOBILE)
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
                        child: kIsWeb && _imageBytes != null
                            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                            : Image.file(File(_image!.path), fit: BoxFit.cover),
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
