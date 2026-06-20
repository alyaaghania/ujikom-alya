import 'package:firebase_auth/firebase_auth.dart';

/// Service ini bertugas menjadi "jembatan" antara UI (tampilan)
/// dengan Firebase Authentication.
/// Semua logic login, register, dan logout dikumpulkan di sini
/// supaya kode di halaman (screen) tetap rapi dan fokus ke tampilan saja.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mengembalikan user yang sedang login saat ini (null kalau belum login)
  User? get currentUser => _auth.currentUser;

  /// Stream untuk memantau perubahan status login secara real-time.
  /// Berguna nanti untuk menentukan apakah user diarahkan ke halaman
  /// Login atau halaman Home.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Proses LOGIN menggunakan email & password.
  /// Mengembalikan null jika berhasil, atau pesan error (String) jika gagal.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // null artinya tidak ada error, berhasil login
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  /// Proses REGISTER (membuat akun baru) menggunakan email & password.
  /// Mengembalikan null jika berhasil, atau pesan error (String) jika gagal.
  Future<String?> register(String email, String password, String nama) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Simpan nama pegawai sebagai "display name" di akun Firebase
      await credential.user?.updateDisplayName(nama.trim());

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  /// Proses LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Mengubah kode error teknis dari Firebase menjadi pesan
  /// yang mudah dipahami pengguna (dalam Bahasa Indonesia).
  String _mapErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
        return 'Email belum terdaftar. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah, minimal 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}