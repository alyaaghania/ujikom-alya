import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/presensi_model.dart';
import '../services/presensi_service.dart';
import '../theme/app_colors.dart';

class RiwayatPresensiAdminScreen extends StatefulWidget {
  const RiwayatPresensiAdminScreen({super.key});

  @override
  State<RiwayatPresensiAdminScreen> createState() => _RiwayatPresensiAdminScreenState();
}

class _RiwayatPresensiAdminScreenState extends State<RiwayatPresensiAdminScreen> {
  final PresensiService _service = PresensiService();
  List<PresensiModel> _semuaPresensi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAllPresensi();
      if (mounted) {
        setState(() {
          _semuaPresensi = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  void _showPresensiMaps(PresensiModel presensi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.brown700,
                    child: Text(
                      presensi.namaPegawai.isNotEmpty
                          ? presensi.namaPegawai[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          presensi.namaPegawai,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.ink),
                        ),
                        Text(
                          '${presensi.tanggal}  •  ${presensi.jamMasuk}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.green100),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20)),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        LatLng(presensi.latitude, presensi.longitude),
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ujikomalya.ujikom_alya',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: LatLng(presensi.latitude, presensi.longitude),
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
          ],
        ),
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
        title: const Text(
          'Presensi semua siswa',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _muatData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _semuaPresensi.isEmpty
                ? _buildEmpty()
                : _buildList(),
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
            child: const Icon(Icons.people_outline,
                size: 36, color: AppColors.inkLight),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada data presensi siswa',
            style: TextStyle(fontSize: 14, color: AppColors.inkLight),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
  final Map<String, List<PresensiModel>> grouped = {};
  for (final p in _semuaPresensi) {
    grouped.putIfAbsent(p.tanggal, () => []).add(p);
  }
  final tanggalList = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: tanggalList.length,
    itemBuilder: (context, i) {
      final tanggal = tanggalList[i];
      final presensiPerTanggal = grouped[tanggal]!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header tanggal ──
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tanggal,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Divider(color: AppColors.green100)),
              ],
            ),
          ),

          // ── List presensi per tanggal ──
          ...presensiPerTanggal.map((presensi) {
            final initial = presensi.namaPegawai.isNotEmpty
                ? presensi.namaPegawai[0].toUpperCase()
                : 'P';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.green100, width: 0.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showPresensiMaps(presensi),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.brown700,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    presensi.namaPegawai,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 11, color: AppColors.inkLight),
                        const SizedBox(width: 4),
                        Text(
                          presensi.jamMasuk,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkLight),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.map_outlined,
                    size: 16,
                    color: AppColors.green900,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    },
  );
}
}