class PresensiModel {
  final int? id;
  final String namaPegawai;
  final String tanggal;
  final String jamMasuk;
  final double latitude;
  final double longitude;
  final String? alamat;

  PresensiModel({
    this.id,
    required this.namaPegawai,
    required this.tanggal,
    required this.jamMasuk,
    required this.latitude,
    required this.longitude,
    this.alamat,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_pegawai': namaPegawai,
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'latitude': latitude,
      'longitude': longitude,
      'alamat': alamat,
    };
  }

  factory PresensiModel.fromMap(Map<String, dynamic> map) {
    return PresensiModel(
      id: map['id'],
      namaPegawai: map['nama_pegawai'] ?? '',
      tanggal: map['tanggal'] ?? '',
      jamMasuk: map['jam_masuk'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      alamat: map['alamat'],
    );
  }
}