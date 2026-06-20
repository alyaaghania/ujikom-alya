import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Halaman ini adalah halaman sementara/placeholder setelah login berhasil.
/// Nanti halaman ini akan kita kembangkan menjadi halaman utama (dashboard)
/// dengan menu Presensi, Data UMKM, Maps, dan Profile.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('SiUMKM BPS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Login berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Selamat datang, ${user?.displayName ?? user?.email ?? "Pegawai"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Halaman ini akan dikembangkan menjadi dashboard utama '
                '(Presensi, Data UMKM, Maps, dan Profile).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}