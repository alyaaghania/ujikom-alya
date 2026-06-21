import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _namaController = TextEditingController();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _passwordHapusController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text =
        _authService.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _passwordHapusController.dispose();
    super.dispose();
  }

  Future<void> _updateNama() async {
    setState(() => _isLoading = true);
    final error = await _authService.updateNama(_namaController.text);

    // Reload user dari Firebase supaya nama & avatar terupdate
    await _authService.currentUser?.reload();

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      setState(() {}); // refresh tampilan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama berhasil diubah!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordBaruController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru minimal 6 karakter!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final error = await _authService.updatePassword(
      _passwordLamaController.text,
      _passwordBaruController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      _passwordLamaController.clear();
      _passwordBaruController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _hapusAkun() async {
    // Konfirmasi dulu sebelum hapus
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Akun akan dihapus permanen dan tidak bisa dikembalikan. Masukkan password untuk konfirmasi:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordHapusController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    setState(() => _isLoading = true);
    final error =
        await _authService.hapusAkun(_passwordHapusController.text);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info akun
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF1565C0),
                          child: Text(
                            (user?.displayName ?? 'P')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.displayName ?? '-',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '-',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Edit nama
                  const Text(
                    'Ubah Nama',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama baru',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateNama,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan Nama'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Ganti password
                  const Text(
                    'Ubah Password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordLamaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password lama',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordBaruController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password baru',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan Password'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Hapus akun
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _hapusAkun,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Hapus Akun',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}