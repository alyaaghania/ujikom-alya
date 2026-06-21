import '../models/umkm_model.dart';
import 'database_helper.dart';

/// Service ini menangani semua operasi CRUD untuk data UMKM,
/// tersimpan di database SQLite lokal (di HP/device itu sendiri).
/// Tidak butuh internet, WiFi, atau server apapun.
class UmkmService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> addUmkm(UmkmModel umkm) async {
    final db = await _dbHelper.database;
    await db.insert('umkm', umkm.toMap());
  }

  Future<List<UmkmModel>> getUmkmList() async {
    final db = await _dbHelper.database;
    final maps = await db.query('umkm', orderBy: 'id DESC');
    return maps.map((map) => UmkmModel.fromMap(map)).toList();
  }

  Future<void> updateUmkm(int id, UmkmModel umkm) async {
    final db = await _dbHelper.database;
    await db.update('umkm', umkm.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUmkm(int id) async {
    final db = await _dbHelper.database;
    await db.delete('umkm', where: 'id = ?', whereArgs: [id]);
  }
}