import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  Future<String?> register(String email, String password, String nama, String nip) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(nama.trim());

      // Simpan data user ke Firestore
      await UserService().simpanDataUser(
        uid: credential.user!.uid,
        nama: nama.trim(),
        email: email.trim(),
        nip: nip.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> updateNama(String namaBaru) async {
    try {
      await _auth.currentUser?.updateDisplayName(namaBaru.trim());
      return null;
    } catch (e) {
      return 'Gagal mengubah nama: $e';
    }
  }

  Future<String?> updatePassword(String passwordLama, String passwordBaru) async {
    try {
      final user = _auth.currentUser;
      final email = user?.email ?? '';
      final credential = EmailAuthProvider.credential(
        email: email,
        password: passwordLama,
      );
      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(passwordBaru);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    } catch (e) {
      return 'Gagal mengubah password: $e';
    }
  }

  Future<String?> hapusAkun(String password) async {
    try {
      final user = _auth.currentUser;
      final email = user?.email ?? '';
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user?.reauthenticateWithCredential(credential);
      await user?.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    } catch (e) {
      return 'Gagal menghapus akun: $e';
    }
  }

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