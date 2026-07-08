import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/umkm_model.dart';
import '../services/umkm_service.dart';
import '../theme/app_colors.dart';

class AdminMapsScreen extends StatefulWidget {
  const AdminMapsScreen({super.key});

  @override
  State<AdminMapsScreen> createState() => _AdminMapsScreenState();
}

class _AdminMapsScreenState extends State<AdminMapsScreen> {
  final UmkmService _umkmService = UmkmService();
  List<UmkmModel> _umkmList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final data = await _umkmService.getAllUmkm();
    if (mounted) {
      setState(() {
        _umkmList = data;
        _isLoading = false;
      });
    }
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
          'Peta Sebaran UMKM',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _umkmList.isEmpty
              ? Center(
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
                        child: const Icon(Icons.map_outlined,
                            size: 36, color: AppColors.inkLight),
                      ),
                      const SizedBox(height: 14),
                      const Text('Belum ada data UMKM',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.inkLight)),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          _umkmList.first.latitude,
                          _umkmList.first.longitude,
                        ),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.ujikomalya.ujikom_alya',
                        ),
                        MarkerLayer(
                          markers: _umkmList.map((umkm) {
                            return Marker(
                              point: LatLng(umkm.latitude, umkm.longitude),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showUmkmInfo(umkm),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Color(0xFFA33C32),
                                  size: 40,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Info jumlah titik
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.green100, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_outlined,
                                size: 14, color: AppColors.green900),
                            const SizedBox(width: 6),
                            Text(
                              '${_umkmList.length} UMKM terdata',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.green900,
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

  void _showUmkmInfo(UmkmModel umkm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brown100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppColors.brown700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(umkm.namaUsaha,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.ink)),
                      Text(umkm.kategori,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.green900),
                const SizedBox(width: 6),
                Text(
                  '${umkm.latitude.toStringAsFixed(6)}, ${umkm.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.green900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.inkLight),
                const SizedBox(width: 6),
                Text(
                  'Diinput oleh: ${umkm.createdBy}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.inkLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}