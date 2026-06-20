import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/umkm_model.dart';

/// Service ini menangani semua operasi CRUD (Create, Read, Update, Delete)
/// untuk data UMKM yang tersimpan di Firestore collection 'umkm'.
class UmkmService {
  final CollectionReference _umkmCollection = FirebaseFirestore.instance
      .collection('umkm');

  /// READ: Mengambil semua data UMKM secara real-time (stream).
  /// Diurutkan dari yang terbaru diinput.
  Stream<List<UmkmModel>> getUmkmList() {
    return _umkmCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UmkmModel.fromDocument(doc)).toList());
  }

  /// CREATE: Menambahkan data UMKM baru
  Future<void> addUmkm(UmkmModel umkm) async {
    await _umkmCollection.add(umkm.toMap());
  }

  /// UPDATE: Mengubah data UMKM yang sudah ada (berdasarkan id dokumen)
  Future<void> updateUmkm(String id, UmkmModel umkm) async {
    await _umkmCollection.doc(id).update(umkm.toMap());
  }

  /// DELETE: Menghapus data UMKM berdasarkan id dokumen
  Future<void> deleteUmkm(String id) async {
    await _umkmCollection.doc(id).delete();
  }
}