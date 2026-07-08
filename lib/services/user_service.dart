import 'database_helper.dart';

class UserService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Ambil semua pegawai (role = pegawai)
  Future<List<Map<String, dynamic>>> getAllPegawai() async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['pegawai'],
      orderBy: 'nama ASC',
    );
    return result;
  }

  // delete pegawai
  Future<void> deletePegawai(int id) async {
    final db = await _db.database;

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}