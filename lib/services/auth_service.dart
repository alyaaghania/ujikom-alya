import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Simpan data user yang sedang login (session sederhana)
  static Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      final db = await _db.database;

      final allUsers = await db.query('users');
      print('SEMUA USER: $allUsers');

      // Cek dulu apakah email terdaftar
      final emailResult = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
      );

      if (emailResult.isEmpty) {
        return 'Akun belum terdaftar. Silakan daftar terlebih dahulu.';
      }

      // Email ada, cek passwordnya
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.trim(), password],
      );

      if (result.isEmpty) {
        return 'Password salah.';
      }

      _currentUser = result.first;
      return null;
    } catch (e) {
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  // REGISTER
  Future<String?> register(String email, String password, String nama, String nip) async {
    try {
      final db = await _db.database;

      // Cek email sudah terdaftar atau belum
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
      );

      if (existing.isNotEmpty) {
        return 'Email sudah terdaftar. Silakan login.';
      }

      await db.insert('users', {
        'nama': nama.trim(),
        'email': email.trim(),
        'password': password,
        'nip': nip.trim(),
        'role': 'pegawai',
      });

      // Auto login setelah register
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim()],
      );
      _currentUser = result.first;

      return null;
    } catch (e) {
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    _currentUser = null;
  }

  // UPDATE NAMA
  Future<String?> updateNama(String namaBaru) async {
    try {
      final db = await _db.database;
      await db.update(
        'users',
        {'nama': namaBaru.trim()},
        where: 'id = ?',
        whereArgs: [_currentUser?['id']],
      );
      _currentUser = {..._currentUser!, 'nama': namaBaru.trim()};
      return null;
    } catch (e) {
      return 'Gagal mengubah nama: $e';
    }
  }

  // UPDATE PASSWORD
  Future<String?> updatePassword(String passwordLama, String passwordBaru) async {
    try {
      if (_currentUser?['password'] != passwordLama) {
        return 'Password lama tidak sesuai.';
      }
      final db = await _db.database;
      await db.update(
        'users',
        {'password': passwordBaru},
        where: 'id = ?',
        whereArgs: [_currentUser?['id']],
      );
      _currentUser = {..._currentUser!, 'password': passwordBaru};
      return null;
    } catch (e) {
      return 'Gagal mengubah password: $e';
    }
  }

  // HAPUS AKUN
  Future<String?> hapusAkun(String password) async {
    try {
      if (_currentUser?['password'] != password) {
        return 'Password tidak sesuai.';
      }
      final db = await _db.database;
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [_currentUser?['id']],
      );
      _currentUser = null;
      return null;
    } catch (e) {
      return 'Gagal menghapus akun: $e';
    }
  }

  // AMBIL ROLE
  String getRole() {
    return _currentUser?['role'] ?? 'pegawai';
  }

  // AMBIL NIP
  String getNIP() {
    return _currentUser?['nip'] ?? '-';
  }
}