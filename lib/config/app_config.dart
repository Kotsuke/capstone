// lib/config/app_config.dart

class AppConfig {
  // ⚠️ PENTING: Ganti URL ini sesuai dengan perangkat yang kamu gunakan untuk testing!

  // ---------------------------------------------------------------------
  // URL UTAMA API (Berakhir di /api)
  // ---------------------------------------------------------------------

  // Standar yang direkomendasikan untuk pengembangan di EMULATOR ANDROID:
  static const String baseUrl =
      'https://unexchangeable-unstern-robt.ngrok-free.dev/api';

  /* * JIKA MENGGUNAKAN PERANGKAT/LINGKUNGAN LAIN, GANTI BASE URL DI ATAS MENJADI:
  * * 1. iOS Simulator: 'http://localhost:5000/api'
  * 2. Physical Device / Web Test: 'http://[IP_KOMPUTER_KAMU]:5000/api' 
  * (Contoh: 'http://192.168.1.10:5000/api')
  */

  // ---------------------------------------------------------------------
  // URL GAMBAR STATIS (Untuk loading foto yang sudah di-upload)
  // ---------------------------------------------------------------------

  // Harus sama dengan host di atas, dan menuju folder 'uploads' di Flask.
  static const String baseImageUrl =
      'https://unexchangeable-unstern-robt.ngrok-free.dev/uploads/';

  /* * Jika kamu mengubah baseUrl, pastikan baseImageUrl juga diubah.
  */
}
