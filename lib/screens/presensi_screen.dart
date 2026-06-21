import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/presensi_model.dart';
import '../services/presensi_service.dart';

class PresensiScreen extends StatefulWidget {
  final String namaPegawai;

  const PresensiScreen({super.key, required this.namaPegawai});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final PresensiService _service = PresensiService();

  bool _isLoading = false;
  bool _isCheckingStatus = true;
  bool _sudahAbsen = false;
  Position? _posisi;
  String _statusText = 'Belum absen hari ini';

  @override
  void initState() {
    super.initState();
    _cekStatusPresensiHariIni();
  }

  /// Dipanggil saat halaman pertama dibuka, untuk mengecek
  /// apakah pegawai ini sudah absen hari ini atau belum.
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
    } catch (e) {
      // Jika gagal cek status, biarkan saja tombol tetap aktif
      // supaya pegawai tidak terblokir karena masalah koneksi sesaat
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  Future<void> _absen() async {
    setState(() => _isLoading = true);

    try {
      final posisi = await _service.getCurrentLocation();

      final now = DateTime.now();
      final tanggal =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final jam =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final presensi = PresensiModel(
        namaPegawai: widget.namaPegawai,
        uidPegawai: FirebaseAuth.instance.currentUser?.uid ?? '',
        tanggal: tanggal,
        jamMasuk: jam,
        latitude: posisi.latitude,
        longitude: posisi.longitude,
        alamat: 'Lat: ${posisi.latitude}, Long: ${posisi.longitude}',
      );

      await _service.simpanPresensi(presensi);

      setState(() {
        _posisi = posisi;
        _sudahAbsen = true;
        _statusText = 'Absen berhasil pukul $jam';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _isCheckingStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    _sudahAbsen ? Icons.check_circle : Icons.location_off,
                    size: 80,
                    color: _sudahAbsen ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.namaPegawai,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 16,
                      color: _sudahAbsen ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_posisi != null) ...[
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              LatLng(_posisi!.latitude, _posisi!.longitude),
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
                            userAgentPackageName:
                                'com.ujikomalya.ujikom_alya',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                    _posisi!.latitude, _posisi!.longitude),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Koordinat Lokasi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Lat: ${_posisi!.latitude.toStringAsFixed(6)}'),
                          Text(
                              'Long: ${_posisi!.longitude.toStringAsFixed(6)}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed:
                          (_isLoading || _sudahAbsen) ? null : _absen,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.location_on),
                      label: Text(
                        _isLoading
                            ? 'Mengambil lokasi...'
                            : _sudahAbsen
                                ? 'Sudah Absen'
                                : 'Absen Sekarang',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _sudahAbsen ? Colors.green : Colors.grey,
                        disabledForegroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_sudahAbsen) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Anda sudah absen hari ini. Silakan kembali besok.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}