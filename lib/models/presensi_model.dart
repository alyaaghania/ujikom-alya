import 'package:cloud_firestore/cloud_firestore.dart';

class PresensiModel {
  final String? id;
  final String namaPegawai;
  final String uidPegawai;
  final String tanggal;
  final String jamMasuk;
  final double latitude;
  final double longitude;
  final String? alamat;

  PresensiModel({
    this.id,
    required this.namaPegawai,
    required this.uidPegawai,
    required this.tanggal,
    required this.jamMasuk,
    required this.latitude,
    required this.longitude,
    this.alamat,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_pegawai': namaPegawai,
      'uid_pegawai': uidPegawai,
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'latitude': latitude,
      'longitude': longitude,
      'alamat': alamat,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory PresensiModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PresensiModel(
      id: doc.id,
      namaPegawai: data['nama_pegawai'] ?? '',
      uidPegawai: data['uid_pegawai'] ?? '',
      tanggal: data['tanggal'] ?? '',
      jamMasuk: data['jam_masuk'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      alamat: data['alamat'],
    );
  }
}