import 'package:flutter/material.dart';
import '../models/umkm_model.dart';
import '../services/umkm_service.dart';
import '../theme/app_colors.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text(
            'Apakah kamu yakin ingin menghapus data "${umkm.namaUsaha}"?',
            style: const TextStyle(fontSize: 13, color: AppColors.inkLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.inkLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _umkmService.deleteUmkm(umkm.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    backgroundColor: AppColors.green700,
                  ),
                );
                _muatData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA33C32),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Data UMKM',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
      body: RefreshIndicator(
        onRefresh: _muatData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _umkmList.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _umkmList.length,
                    itemBuilder: (context, index) {
                      final umkm = _umkmList[index];
                      return _buildCard(umkm);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brown700,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const UmkmFormScreen()));
          _muatData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 36, color: AppColors.inkLight),
          ),
          const SizedBox(height: 14),
          const Text('Belum ada data UMKM',
              style: TextStyle(fontSize: 14, color: AppColors.inkLight)),
          const SizedBox(height: 4),
          const Text(
            'Tekan tombol + untuk menambahkan data baru',
            style: TextStyle(fontSize: 12, color: AppColors.inkLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(UmkmModel umkm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green100, width: 0.5),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.brown100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.storefront_outlined,
              color: AppColors.brown700, size: 20),
        ),
        title: Text(
          umkm.namaUsaha,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            umkm.kategori,
            style:
                const TextStyle(fontSize: 12, color: AppColors.inkLight),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionIcon(
              icon: Icons.edit_outlined,
              color: AppColors.green900,
              bgColor: AppColors.green50,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UmkmFormScreen(umkm: umkm)),
                );
                _muatData();
              },
            ),
            const SizedBox(width: 6),
            _ActionIcon(
              icon: Icons.delete_outline,
              color: const Color(0xFFA33C32),
              bgColor: const Color(0xFFF3E5E3),
              onTap: () => _konfirmasiHapus(umkm),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}