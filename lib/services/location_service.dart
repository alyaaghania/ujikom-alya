import 'package:geolocator/geolocator.dart';

/// Service ini menangani logic pengambilan lokasi GPS device,
/// termasuk pengecekan dan permintaan izin akses lokasi ke pengguna.
class LocationService {
  /// Mengambil posisi GPS saat ini.
  /// Melempar Exception dengan pesan yang jelas jika gagal,
  /// supaya bisa ditangkap dan ditampilkan ke pengguna.
  Future<Position> getCurrentLocation() async {
    // 1. Cek apakah GPS device dalam keadaan aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif. Mohon aktifkan GPS terlebih dahulu.');
    }

    // 2. Cek status izin akses lokasi
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Kalau belum pernah diizinkan, minta izin ke pengguna
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Mohon aktifkan lewat Settings.',
      );
    }

    // 3. Ambil posisi GPS saat ini
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}