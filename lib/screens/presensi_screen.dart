import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/presensi_model.dart';
import '../services/presensi_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class PresensiScreen extends StatefulWidget {
  final String namaPegawai;

  const PresensiScreen({super.key, required this.namaPegawai});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen>
    with SingleTickerProviderStateMixin {
  final PresensiService _service = PresensiService();
  late TabController _tabController;

  bool _isLoading = false;
  bool _isCheckingStatus = true;
  bool _isLoadingLokasi = true;
  bool _sudahAbsen = false;
  Position? _posisi;
  Position? _posisiLive;
  String _statusText = 'Belum absen hari ini';

  List<PresensiModel> _riwayat = [];
  bool _isLoadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cekStatusPresensiHariIni();
    _loadRiwayat();
    _ambilLokasiLive();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _ambilLokasiLive() async {
    setState(() => _isLoadingLokasi = true);
    try {
      final posisi = await _service.getCurrentLocation();
      if (mounted) {
        setState(() {
          _posisiLive = posisi;
          _isLoadingLokasi = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLokasi = false);
    }
  }

  Future<void> _cekStatusPresensiHariIni() async {
    setState(() => _isCheckingStatus = true);
    try {
      final presensiHariIni = await _service.getPresensiHariIni();
      if (presensiHariIni != null) {
        setState(() {
          _sudahAbsen = true;
          _statusText = 'Absen berhasil pukul ${presensiHariIni.jamMasuk}';
          _posisi = Position(
            latitude: presensiHariIni.latitude,
            longitude: presensiHariIni.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  Future<void> _loadRiwayat() async {
    final data = await _service.getPresensiSaya();
    if (mounted) {
      setState(() {
        _riwayat = data;
        _isLoadingRiwayat = false;
      });
    }
  }

  Future<void> _absen() async {
    setState(() => _isLoading = true);
    try {
      final posisi = await _service.getCurrentLocation();

      if (!_service.dalamJangkauanJember(posisi.latitude, posisi.longitude)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda berada di luar jangkauan area Jember. Presensi tidak dapat dilakukan.'),
              backgroundColor: Color(0xFFA33C32),
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final now = DateTime.now();
      final tanggal =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final jam =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final presensi = PresensiModel(
        namaPegawai: widget.namaPegawai,
        tanggal: tanggal,
        jamMasuk: jam,
        latitude: posisi.latitude,
        longitude: posisi.longitude,
        alamat: 'Lat: ${posisi.latitude}, Long: ${posisi.longitude}',
      );

      await _service.simpanPresensi(presensi);
      setState(() {
        _posisi = posisi;
        _posisiLive = posisi;
        _sudahAbsen = true;
        _statusText = 'Absen berhasil pukul $jam';
      });
      _loadRiwayat();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi berhasil disimpan!'),
            backgroundColor: AppColors.green700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: const Color(0xFFA33C32)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posisiTampil = _sudahAbsen ? _posisi : _posisiLive;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
        title: const Text('Presensi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 2.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.fingerprint, size: 20), text: 'Absen'),
            Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Profil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB ABSEN ──
          _isCheckingStatus
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _sudahAbsen ? AppColors.green50 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.green100, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _sudahAbsen ? AppColors.green100 : AppColors.green50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _sudahAbsen ? Icons.check_circle_outline : Icons.fingerprint,
                                size: 34,
                                color: _sudahAbsen ? AppColors.green900 : AppColors.inkLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AuthService().currentUser?['nama'] ?? widget.namaPegawai,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusText,
                              style: TextStyle(
                                fontSize: 13,
                                color: _sudahAbsen ? AppColors.green900 : AppColors.inkLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoadingLokasi && posisiTampil == null
                          ? Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.green100, width: 0.5),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 10),
                                    Text('Mengambil lokasi...',
                                        style: TextStyle(fontSize: 13, color: AppColors.inkLight)),
                                  ],
                                ),
                              ),
                            )
                          : posisiTampil != null
                              ? Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SizedBox(
                                        height: 200,
                                        child: FlutterMap(
                                          options: MapOptions(
                                            initialCenter: LatLng(posisiTampil.latitude, posisiTampil.longitude),
                                            initialZoom: 16,
                                            interactionOptions: const InteractionOptions(
                                              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                                            ),
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              userAgentPackageName: 'com.ujikomalya.ujikom_alya',
                                            ),
                                            MarkerLayer(markers: [
                                              Marker(
                                                point: LatLng(posisiTampil.latitude, posisiTampil.longitude),
                                                width: 40,
                                                height: 40,
                                                child: const Icon(Icons.location_pin, color: Color(0xFFA33C32), size: 40),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.green50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.green100, width: 0.5),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.green900),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${posisiTampil.latitude.toStringAsFixed(6)}, ${posisiTampil.longitude.toStringAsFixed(6)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.green900,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.green50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.green100, width: 0.5),
                                  ),
                                  child: const Center(
                                    child: Text('Lokasi tidak tersedia',
                                        style: TextStyle(fontSize: 13, color: AppColors.inkLight)),
                                  ),
                                ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: (_isLoading || _sudahAbsen) ? null : _absen,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.my_location, size: 18),
                          label: Text(
                            _isLoading ? 'Mengambil lokasi...' : _sudahAbsen ? 'Sudah Absen Hari Ini' : 'Absen Sekarang',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _sudahAbsen ? AppColors.green900 : AppColors.green700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            disabledBackgroundColor: AppColors.green900,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      if (_sudahAbsen) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Kamu sudah absen hari ini. Sampai jumpa besok!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.inkLight),
                        ),
                      ],
                    ],
                  ),
                ),

          // ── TAB PROFIL ──
          _ProfileTab(
            namaPegawai: widget.namaPegawai,
            onNamaUpdated: _onNamaUpdated,  // ← tambah ini
          ),
        ],
      ),
    );
  }
  void _onNamaUpdated() {
    setState(() {});
  }
}

// ══════════════════════════════════════════════
// CLASS _ProfileTab — DI LUAR _PresensiScreenState
// ══════════════════════════════════════════════

class _ProfileTab extends StatefulWidget {
  final String namaPegawai;
  final VoidCallback? onNamaUpdated;
  const _ProfileTab({required this.namaPegawai, this.onNamaUpdated});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
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
    if (error == null) widget.onNamaUpdated?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Nama berhasil diubah!'),
        backgroundColor: error == null ? AppColors.green700 : const Color(0xFFA33C32),
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
        backgroundColor: error == null ? AppColors.green700 : const Color(0xFFA33C32),
      ),
    );
  }

  Future<void> _hapusAkun() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akun',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan password untuk konfirmasi:',
                style: TextStyle(fontSize: 13, color: AppColors.inkLight)),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordHapusController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(fontSize: 13, color: AppColors.inkLight),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.green100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.green700, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.inkLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA33C32),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;
    setState(() => _isLoading = true);
    final error = await _authService.hapusAkun(_passwordHapusController.text);
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
        SnackBar(content: Text(error), backgroundColor: const Color(0xFFA33C32)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final nama = user?['nama']?.toString() ?? '-';
    final email = user?['email']?.toString() ?? '-';
    final nisn = user?['nip']?.toString() ?? '-';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'P';

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.green100, width: 0.5),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.brown700,
                  child: Text(
                    initial,
                    style: const TextStyle(
                        fontSize: 26, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Text(nama,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkLight)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.green100, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge_outlined, size: 14, color: AppColors.green900),
                      const SizedBox(width: 6),
                      Text('NISN: $nisn',   // ← sudah benar pakai $nisn
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.green900, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Ubah Nama',
            icon: Icons.person_outline,
            children: [
              _buildTextField(controller: _namaController, label: 'Nama baru', icon: Icons.person_outline),
              const SizedBox(height: 12),
              _buildButton(label: 'Simpan Nama', onPressed: _updateNama),
            ],
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            title: 'Ubah Password',
            icon: Icons.lock_outline,
            children: [
              _buildTextField(
                controller: _passwordLamaController,
                label: 'Password lama',
                icon: Icons.lock_outline,
                obscure: _obscureOld,
                toggleObscure: () => setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _passwordBaruController,
                label: 'Password baru',
                icon: Icons.lock_outline,
                obscure: _obscureNew,
                toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 12),
              _buildButton(label: 'Simpan Password', onPressed: _updatePassword),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _hapusAkun,
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.w500)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: const BorderSide(color: Color(0xFFA33C32)),
              foregroundColor: const Color(0xFFA33C32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink)),
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
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.inkLight),
        prefixIcon: Icon(icon, size: 18, color: AppColors.green700),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.inkLight,
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green700, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}