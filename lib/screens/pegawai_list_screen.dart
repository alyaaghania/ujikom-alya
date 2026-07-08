import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class PegawaiListScreen extends StatefulWidget {
  const PegawaiListScreen({super.key});

  @override
  State<PegawaiListScreen> createState() => _PegawaiListScreenState();
}

class _PegawaiListScreenState extends State<PegawaiListScreen> {
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _pegawai = [];

  @override
  void initState() {
    super.initState();
    _loadPegawai();
  }

  Future<void> _loadPegawai() async {
    final data = await _userService.getAllPegawai();

    if (mounted) {
      setState(() {
        _pegawai = data;
      });
    }
  }

  Future<void> _hapusPegawai(int id) async {
    await _userService.deletePegawai(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dihapus'),
          backgroundColor: AppColors.green700,
        ),
      );
    }

    await _loadPegawai();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Akun Siswa',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: _pegawai.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data siswa',
                style: TextStyle(
                  color: AppColors.inkLight,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: _pegawai.length,
              itemBuilder: (context, index) {
                final pegawai = _pegawai[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.green100,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.green900,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pegawai['nama'] ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              pegawai['email'] ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.inkLight,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              'NISN: ${pegawai['nip'] ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.inkLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFA33C32),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: const Text('Hapus Akun'),
                              content: Text(
                                'Yakin ingin menghapus akun ${pegawai['nama']}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: AppColors.inkLight,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFA33C32),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _hapusPegawai(pegawai['id']);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}