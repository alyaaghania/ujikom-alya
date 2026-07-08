import 'package:geolocator/geolocator.dart';
import '../models/presensi_model.dart';
import 'database_helper.dart';
import 'auth_service.dart';

class PresensiService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif. Nyalakan GPS terlebih dahulu.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Buka pengaturan HP.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> simpanPresensi(PresensiModel presensi) async {
    final db = await _db.database;
    await db.insert('presensi', presensi.toMap());
  }

  // Cek presensi hari ini berdasarkan nama pegawai
  Future<PresensiModel?> getPresensiHariIni() async {
    final db = await _db.database;
    final nama = AuthService().currentUser?['nama'] ?? '';
    final now = DateTime.now();
    final tanggal =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final result = await db.query(
      'presensi',
      where: 'nama_pegawai = ? AND tanggal = ?',
      whereArgs: [nama, tanggal],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return PresensiModel.fromMap(result.first);
  }

  // Presensi milik sendiri
  Future<List<PresensiModel>> getPresensiSaya() async {
    final db = await _db.database;
    final nama = AuthService().currentUser?['nama'] ?? '';
    final result = await db.query(
      'presensi',
      where: 'nama_pegawai = ?',
      whereArgs: [nama],
      orderBy: 'id DESC',
    );
    return result.map((e) => PresensiModel.fromMap(e)).toList();
  }

  // Semua presensi (untuk admin)
  Future<List<PresensiModel>> getAllPresensi() async {
    final db = await _db.database;
    final result = await db.query('presensi', orderBy: 'id DESC');
    return result.map((e) => PresensiModel.fromMap(e)).toList();
  }

  Future<int> countPresensiHariIni() async {
    final db = await _db.database;
    final now = DateTime.now();
    final tanggal = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM presensi WHERE tanggal = ?",
      [tanggal],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  bool dalamJangkauanJember(double latitude, double longitude) {
    const pusatLat = -8.1724;
    const pusatLng = 113.7036;
    const radiusKm = 15.0;

    final jarak = Geolocator.distanceBetween(
      pusatLat, pusatLng,
      latitude, longitude,
    );

    return jarak <= radiusKm * 1000;
  }
}