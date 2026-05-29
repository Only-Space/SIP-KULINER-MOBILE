import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../errors/app_exception.dart';

class LocationPermissionHandler {
  static Future<void> checkAndRequestPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Layanan lokasi tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      final bool? openSettings = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Izin Lokasi Diperlukan'),
            content: const Text(
                'Izin lokasi telah ditolak permanen. Silakan aktifkan izin lokasi di pengaturan aplikasi untuk melanjutkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          );
        },
      );
      if (openSettings == true) {
        await Geolocator.openAppSettings();
      }
      throw LocationException('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
    }
  }
}
