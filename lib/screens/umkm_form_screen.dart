import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/umkm_model.dart';
import '../services/umkm_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class UmkmFormScreen extends StatefulWidget {
  final UmkmModel? umkm;

  const UmkmFormScreen({super.key, this.umkm});

  @override
  State<UmkmFormScreen> createState() => _UmkmFormScreenState();
}

class _UmkmFormScreenState extends State<UmkmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController();

  final UmkmService _umkmService = UmkmService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.umkm != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _namaController.text = widget.umkm!.namaUsaha;
      _kategoriController.text = widget.umkm!.kategori;
      _latitude = widget.umkm!.latitude;
      _longitude = widget.umkm!.longitude;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  Future<void> _ambilLokasi() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil diambil!'),
            backgroundColor: AppColors.green700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFA33C32),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon ambil lokasi GPS terlebih dahulu'),
          backgroundColor: Color(0xFFA33C32),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final email = _authService.currentUser?['email'] ?? 'unknown';
      final umkmData = UmkmModel(
        namaUsaha: _namaController.text.trim(),
        kategori: _kategoriController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        createdBy: email,
        createdAt: DateTime.now(),
      );

      if (_isEditMode) {
        await _umkmService.updateUmkm(widget.umkm!.id!, umkmData);
      } else {
        await _umkmService.addUmkm(umkmData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Data berhasil diperbarui!'
                : 'Data berhasil disimpan!'),
            backgroundColor: AppColors.green700,
            duration: const Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: const Color(0xFFA33C32),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool adaLokasi = _latitude != null && _longitude != null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditMode ? 'Edit Data UMKM' : 'Tambah Data UMKM',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Usaha
              _buildLabel('Nama Usaha'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration(
                    label: 'Nama Usaha', icon: Icons.storefront_outlined),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama usaha tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              // Kategori
              _buildLabel('Kategori Usaha'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kategoriController,
                decoration: _inputDecoration(
                  label: 'Kategori Usaha',
                  icon: Icons.category_outlined,
                ).copyWith(
                  hintText: 'Contoh: Kuliner, Jasa, Perdagangan',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.inkLight),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Kategori tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 22),

              // Lokasi
              _buildLabel('Lokasi UMKM'),
              const SizedBox(height: 10),

              // Tombol ambil lokasi
              OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _ambilLokasi,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.green700),
                      )
                    : Icon(
                        adaLokasi ? Icons.refresh : Icons.my_location,
                        size: 18,
                      ),
                label: Text(
                  adaLokasi ? 'Ambil Ulang Lokasi GPS' : 'Ambil Lokasi GPS Saat Ini',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.green700),
                  foregroundColor: AppColors.green700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Peta / placeholder
              if (adaLokasi) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(_latitude!, _longitude!),
                        initialZoom: 16,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.pinchZoom |
                              InteractiveFlag.drag,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.ujikomalya.ujikom_alya',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(_latitude!, _longitude!),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: Color(0xFFA33C32), size: 40),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.green100, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.green900),
                      const SizedBox(width: 8),
                      Text(
                        '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.green900,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ] else
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.green50,
                    border: Border.all(color: AppColors.green100, width: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.map_outlined,
                          size: 28, color: AppColors.inkLight),
                      SizedBox(height: 6),
                      Text('Lokasi belum diambil',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.inkLight)),
                    ],
                  ),
                ),
              const SizedBox(height: 28),

              // Tombol simpan
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEditMode ? 'Simpan Perubahan' : 'Simpan Data UMKM',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.inkLight),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.inkLight),
      prefixIcon: Icon(icon, size: 20, color: AppColors.green700),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green700, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA33C32)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA33C32), width: 1.5),
      ),
    );
  }
}