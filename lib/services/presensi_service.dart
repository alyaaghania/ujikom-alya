import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/presensi_model.dart';

class PresensiService {
  final CollectionReference _presensiCollection =
      FirebaseFirestore.instance.collection('presensi');

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
    await _presensiCollection.add(presensi.toMap());
  }

  /// Cek apakah pegawai yang sedang login SUDAH absen hari ini.
  /// Mengembalikan data presensi hari ini jika sudah ada, atau null jika belum.
  Future<PresensiModel?> getPresensiHariIni() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();
    final tanggalHariIni =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final snapshot = await _presensiCollection
        .where('uid_pegawai', isEqualTo: uid)
        .where('tanggal', isEqualTo: tanggalHariIni)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PresensiModel.fromDocument(snapshot.docs.first);
  }

  /// History presensi MILIK SENDIRI (untuk pegawai)
  Future<List<PresensiModel>> getPresensiSaya() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final snapshot = await _presensiCollection
        .where('uid_pegawai', isEqualTo: uid)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => PresensiModel.fromDocument(doc)).toList();
  }

  /// SEMUA presensi dari SEMUA pegawai (khusus admin)
  Future<List<PresensiModel>> getAllPresensi() async {
    final snapshot = await _presensiCollection
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => PresensiModel.fromDocument(doc)).toList();
  }
}