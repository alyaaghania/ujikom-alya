/// Model ini merepresentasikan satu data UMKM untuk database SQLite.
class UmkmModel {
  final int? id; // id auto-increment dari SQLite (null kalau belum disimpan)
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

  Map<String, dynamic> toMap() {
    return {
      'nama_usaha': namaUsaha,
      'kategori': kategori,
      'latitude': latitude,
      'longitude': longitude,
      'created_by': createdBy,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory UmkmModel.fromMap(Map<String, dynamic> map) {
    return UmkmModel(
      id: map['id'] as int?,
      namaUsaha: map['nama_usaha'] ?? '',
      kategori: map['kategori'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      createdBy: map['created_by'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }
}