import 'package:flutter/material.dart';
import '../models/umkm_model.dart';
import '../services/umkm_service.dart';
import 'umkm_form_screen.dart';

class UmkmListScreen extends StatefulWidget {
  const UmkmListScreen({super.key});

  @override
  State<UmkmListScreen> createState() => _UmkmListScreenState();
}

class _UmkmListScreenState extends State<UmkmListScreen> {
  final UmkmService _umkmService = UmkmService();
  List<UmkmModel> _umkmList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _isLoading = true);
    final data = await _umkmService.getUmkmList();
    if (mounted) {
      setState(() {
        _umkmList = data;
        _isLoading = false;
      });
    }
  }

  void _konfirmasiHapus(UmkmModel umkm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: Text('Apakah Anda yakin ingin menghapus data "${umkm.namaUsaha}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _umkmService.deleteUmkm(umkm.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
                );
                _muatData();
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
      body: RefreshIndicator(
        onRefresh: _muatData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _umkmList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Belum ada data UMKM', style: TextStyle(fontSize: 16, color: Colors.black54)),
                          const SizedBox(height: 4),
                          const Text('Tekan tombol + untuk menambahkan data baru',
                              style: TextStyle(fontSize: 13, color: Colors.black38), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _umkmList.length,
                    itemBuilder: (context, index) {
                      final umkm = _umkmList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.storefront_outlined, color: Color(0xFF1565C0)),
                          ),
                          title: Text(umkm.namaUsaha, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(umkm.kategori),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => UmkmFormScreen(umkm: umkm)),
                                  );
                                  _muatData();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _konfirmasiHapus(umkm),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const UmkmFormScreen()));
          _muatData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}