import 'package:cloud_firestore/cloud_firestore.dart';

/// Model ini merepresentasikan satu data UMKM.
/// Dipakai untuk mengubah data dari Firestore (format Map)
/// menjadi objek Dart yang mudah dipakai di UI, dan sebaliknya.
class UmkmModel {
  final String? id; // id dokumen Firestore (null kalau belum disimpan)
  final String namaUsaha;
  final String kategori;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime? createdAt;

  UmkmModel({
    this.id,
    required this.namaUsaha,
    required this.kategori,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    this.createdAt,
  });

  /// Mengubah objek ini menjadi Map, supaya bisa disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama_usaha': namaUsaha,
      'kategori': kategori,
      'latitude': latitude,
      'longitude': longitude,
      'created_by': createdBy,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Membuat objek UmkmModel dari dokumen Firestore
  factory UmkmModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UmkmModel(
      id: doc.id,
      namaUsaha: data['nama_usaha'] ?? '',
      kategori: data['kategori'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      createdBy: data['created_by'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}