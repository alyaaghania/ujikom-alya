import 'package:flutter/material.dart';
import '../models/umkm_model.dart';
import '../services/umkm_service.dart';
import 'umkm_form_screen.dart';

/// Halaman ini menampilkan daftar semua data UMKM yang sudah didata,
/// dengan opsi untuk menambah (FAB), mengedit, dan menghapus data.
class UmkmListScreen extends StatelessWidget {
  UmkmListScreen({super.key});

  final UmkmService _umkmService = UmkmService();

  /// Menampilkan dialog konfirmasi sebelum menghapus data
  void _konfirmasiHapus(BuildContext context, UmkmModel umkm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "${umkm.namaUsaha}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _umkmService.deleteUmkm(umkm.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Data UMKM'),
      ),
      body: StreamBuilder<List<UmkmModel>>(
        stream: _umkmService.getUmkmList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final umkmList = snapshot.data ?? [];

          if (umkmList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada data UMKM',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tekan tombol + untuk menambahkan data baru',
                      style: TextStyle(fontSize: 13, color: Colors.black38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: umkmList.length,
            itemBuilder: (context, index) {
              final umkm = umkmList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  title: Text(
                    umkm.namaUsaha,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(umkm.kategori),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.blueGrey),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UmkmFormScreen(umkm: umkm),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _konfirmasiHapus(context, umkm),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UmkmFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}