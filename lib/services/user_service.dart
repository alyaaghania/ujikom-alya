import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan data user ke Firestore saat register
  Future<void> simpanDataUser({
    required String uid,
    required String nama,
    required String email,
    required String nip,
    String role = 'pegawai',
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'nama': nama,
      'email': email,
      'nip': nip,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Ambil data user berdasarkan UID
  Future<Map<String, dynamic>?> getDataUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Ambil role user (admin/pegawai)
  Future<String> getRole(String uid) async {
    final data = await getDataUser(uid);
    return data?['role'] ?? 'pegawai';
  }

  // Ambil semua pegawai (untuk admin)
  Future<List<Map<String, dynamic>>> getAllPegawai() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'pegawai')
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'uid': doc.id}).toList();
  }

  // Ambil NIP user yang sedang login
  Future<String> getNIP() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final data = await getDataUser(uid);
    return data?['nip'] ?? '-';
  }
}