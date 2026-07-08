import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'umkm_list_screen.dart';
import 'presensi_screen.dart';
import 'profile_screen.dart';
import 'umkm_form_screen.dart';
import '../services/umkm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  final UmkmService _umkmService = UmkmService();

  int _umkmHariIni = 0;
  int _umkmBulanIni = 0;
  int _umkmTahunIni = 0;

  @override
  void initState() {
    super.initState();
    _muatStatistik();
  }

  Future<void> _muatStatistik() async {
    final hari = await _umkmService.countUmkmHariIni();
    final bulan = await _umkmService.countUmkmBulanIni();
    final tahun = await _umkmService.countUmkmTahunIni();
    if (mounted) {
      setState(() {
        _umkmHariIni = hari;
        _umkmBulanIni = bulan;
        _umkmTahunIni = tahun;
      });
    }
  }

  Future<void> _logout() async {
    await authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openUmkmList() {
    // TODO: kalau UmkmListScreen sudah punya parameter filter periode,
    // kirim lewat constructor di sini.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UmkmListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final namaLengkap = user?['nama']?.toString() ?? 'Pegawai';
    final firstName = namaLengkap.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: AppColors.cream,
      drawer: _buildDrawer(context, firstName, initial, namaLengkap),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(firstName, initial),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data UMKM kamu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkLight,
                  ),
                ),
                const SizedBox(height: 10),
                _UmkmStatCard(
                  label: 'Hari ini',
                  value: _umkmHariIni,
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 10),
                _UmkmStatCard(
                  label: 'Bulan ini',
                  value: _umkmBulanIni,
                  icon: Icons.calendar_month_outlined,
                ),
                const SizedBox(height: 10),
                _UmkmStatCard(
                  label: 'Tahun ini',
                  value: _umkmTahunIni,
                  icon: Icons.bar_chart_outlined,
                ),
                const SizedBox(height: 14),

                // Tombol Input UMKM via Peta
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.green100, width: 0.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UmkmFormScreen()),
                      );
                      _muatStatistik();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_location_alt_outlined, size: 18, color: AppColors.green900),
                              SizedBox(width: 10),
                              Text(
                                'Input data UMKM melalui peta',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right, size: 18, color: AppColors.inkLight),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String firstName, String initial) {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
        color: AppColors.green700,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu, size: 18, color: Colors.white),
                ),
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Selamat bekerja',
                      style: TextStyle(fontSize: 12, color: AppColors.green50),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      firstName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.brown700,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, String firstName, String initial, String namaLengkap) {
    final user = authService.currentUser;

    return Drawer(
      backgroundColor: AppColors.cream,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.brown700,
                    child: Text(
                      initial,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.ink,
                          ),
                        ),
                        const Text(
                          'Pegawai lapangan',
                          style: TextStyle(fontSize: 12, color: AppColors.inkLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.green100),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.storefront_outlined,
              label: 'Data UMKM',
              subtitle: 'Lihat semua data UMKM yang diinput',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UmkmListScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.fingerprint,
              label: 'Presensi',
              subtitle: 'Presensi hari ini & riwayat presensi',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PresensiScreen(
                      namaPegawai: namaLengkap,
                    ),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profil',
              subtitle: 'Ubah data diri, email & kata sandi',
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
                if (mounted) setState(() {});
              },
            ),
            const Spacer(),
            const Divider(height: 1, color: AppColors.green100),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Keluar',
              labelColor: const Color(0xFFA33C32),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _UmkmStatCard extends StatelessWidget {
  final String label;
  final int? value;
  final IconData icon;

  const _UmkmStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brown100, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brown100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.brown700, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.inkLight),
                ),
                const SizedBox(height: 2),
                Text(
                  value != null ? '$value UMKM' : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: labelColor ?? AppColors.green900),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: labelColor ?? AppColors.ink,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(fontSize: 11, color: AppColors.inkLight))
          : null,
      onTap: onTap,
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 18);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height - 12,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 24,
      size.width, size.height - 4,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}