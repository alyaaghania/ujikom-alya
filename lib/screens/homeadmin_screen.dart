import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/umkm_service.dart';
import '../services/presensi_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'adminriwayat_presensi_screen.dart';
import 'admin_maps_screen.dart';
import 'pegawai_list_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final UmkmService _umkmService = UmkmService();
  final PresensiService _presensiService = PresensiService();

  List<Map<String, dynamic>> _pegawaiList = [];
  bool _isLoading = true;

  int _presensiHariIni = 0;
  int _umkmHariIni = 0;
  int _totalUmkm = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final pegawai = await _userService.getAllPegawai();
    final presensi = await _presensiService.countPresensiHariIni();
    final umkmHari = await _umkmService.countUmkmHariIniAdmin();
    final umkmTotal = await _umkmService.countTotalUmkm();
    if (mounted) {
      setState(() {
        _pegawaiList = pegawai;
        _presensiHariIni = presensi;
        _umkmHariIni = umkmHari;
        _totalUmkm = umkmTotal;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan hari ini',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildStatGrid(),
                        const SizedBox(height: 18),
                        _buildMapsButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
        color: AppColors.green700,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang',
                  style: TextStyle(fontSize: 12, color: AppColors.green50),
                ),
                SizedBox(height: 2),
                Text(
                  'Halo, Admin',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // InkWell(
                //   borderRadius: BorderRadius.circular(10),
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const RiwayatPresensiAdminScreen(),
                //     ),
                //   ),
                //   child: Container(
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.16),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: const Icon(Icons.history, size: 16, color: Colors.white),
                //   ),
                // ),
                // const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 15, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildStatGrid() {
    final stats = [
      _StatData(
        icon: Icons.people_outline,
        value: _pegawaiList.length.toString(),
        label: 'Daftar akun siswa',
        accent: AppColors.green900,
        border: AppColors.green100,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PegawaiListScreen(),
            ),
          );
        },
      ),
      _StatData(
        icon: Icons.fingerprint,
        value: _presensiHariIni.toString(),
        label: 'Presensi siswa hari ini',
        accent: AppColors.green900,
        border: AppColors.green100,
      ),
      // _StatData(
      //   icon: Icons.storefront_outlined,
      //   value: _umkmHariIni.toString(),
      //   label: 'Data UMKM masuk hari ini',
      //   accent: AppColors.brown700,
      //   border: AppColors.brown100,
      // ),
      // _StatData(
      //   icon: Icons.dataset_outlined,
      //   value: _totalUmkm.toString(),
      //   label: 'Total UMKM terdata',
      //   accent: AppColors.brown700,
      //   border: AppColors.brown100,
      // ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: stats.map((s) => _StatCard(data: s)).toList(),
    );
  }

  Widget _buildMapsButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RiwayatPresensiAdminScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.green50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.green100, width: 0.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.map_outlined, size: 18, color: AppColors.green900),
                SizedBox(width: 10),
                Text(
                  'Lihat riwayat presensi siswa',
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
    );
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color border;
  final VoidCallback? onTap;

  _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.border,
    this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: data.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, size: 18, color: data.accent),
            const Spacer(),
            Text(
              data.value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.inkLight,
              ),
            ),
          ],
        ),
      ),
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