import 'package:sqflite/sqflite.dart';
import '../models/umkm_model.dart';
import 'database_helper.dart';
import 'auth_service.dart';

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

  Future<int> countUmkmHariIni() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final email = AuthService().currentUser?['email'] ?? '';
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM umkm WHERE substr(created_at, 1, 10) = ? AND created_by = ?",
      [today, email],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> countUmkmHariIniAdmin() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Debug: lihat semua data umkm
    final allData = await db.query('umkm');
    print('=== SEMUA DATA UMKM ===');
    for (var d in allData) {
      print('created_at: ${d['created_at']}, nama: ${d['nama_usaha']}');
    }
    print('Today: $today');
    print('=======================');

    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM umkm WHERE substr(created_at, 1, 10) = ?",
      [today],
    );
    print('Count hari ini: ${result.first['count']}');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> countUmkmBulanIni() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final email = AuthService().currentUser?['email'] ?? '';
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM umkm WHERE substr(created_at, 1, 7) = ? AND created_by = ?",
      [yearMonth, email],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> countUmkmTahunIni() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final email = AuthService().currentUser?['email'] ?? '';
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM umkm WHERE substr(created_at, 1, 4) = ? AND created_by = ?",
      ['${now.year}', email],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> countTotalUmkm() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM umkm");
    return (result.first['count'] as int?) ?? 0;
  }

  Future<List<UmkmModel>> getAllUmkm() async {
    final db = await _dbHelper.database;
    final maps = await db.query('umkm', orderBy: 'id DESC');
    return maps.map((map) => UmkmModel.fromMap(map)).toList();
  }
}