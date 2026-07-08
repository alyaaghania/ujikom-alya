import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
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
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _namaController.text = _authService.currentUser?['nama'] ?? '';
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
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Nama berhasil diubah!'),
        backgroundColor:
            error == null ? AppColors.green700 : const Color(0xFFA33C32),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (_passwordBaruController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru minimal 6 karakter!'),
          backgroundColor: AppColors.brown700,
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
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Password berhasil diubah!'),
        backgroundColor:
            error == null ? AppColors.green700 : const Color(0xFFA33C32),
      ),
    );
  }

  Future<void> _hapusAkun() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akun',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan password untuk konfirmasi:',
              style: TextStyle(fontSize: 13, color: AppColors.inkLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordHapusController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                    fontSize: 13, color: AppColors.inkLight),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.green100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.green700, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.inkLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
        SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFA33C32)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final nama = user?['nama']?.toString() ?? '-';
    final email = user?['email']?.toString() ?? '-';
    final nip = user?['nip']?.toString() ?? '-';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: AppColors.green700,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppColors.green700,
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.brown700,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.green50),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Badge NIP
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.green50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: AppColors.green100, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.badge_outlined,
                                    size: 14, color: AppColors.green900),
                                const SizedBox(width: 6),
                                Text(
                                  'NIP: $nip',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.green900,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Ubah Nama
                        _buildSectionCard(
                          title: 'Ubah Nama',
                          icon: Icons.person_outline,
                          children: [
                            _buildTextField(
                              controller: _namaController,
                              label: 'Nama baru',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 12),
                            _buildButton(
                              label: 'Simpan Nama',
                              onPressed: _updateNama,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Ubah Password
                        _buildSectionCard(
                          title: 'Ubah Password',
                          icon: Icons.lock_outline,
                          children: [
                            _buildTextField(
                              controller: _passwordLamaController,
                              label: 'Password lama',
                              icon: Icons.lock_outline,
                              obscure: _obscureOld,
                              toggleObscure: () =>
                                  setState(() => _obscureOld = !_obscureOld),
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _passwordBaruController,
                              label: 'Password baru',
                              icon: Icons.lock_outline,
                              obscure: _obscureNew,
                              toggleObscure: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                            const SizedBox(height: 12),
                            _buildButton(
                              label: 'Simpan Password',
                              onPressed: _updatePassword,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Hapus akun
                        OutlinedButton.icon(
                          onPressed: _hapusAkun,
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('Hapus Akun',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(
                                color: Color(0xFFA33C32)),
                            foregroundColor: const Color(0xFFA33C32),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.green900),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.green100),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(fontSize: 13, color: AppColors.inkLight),
        prefixIcon: Icon(icon, size: 18, color: AppColors.green700),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.inkLight,
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.cream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.green700, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}