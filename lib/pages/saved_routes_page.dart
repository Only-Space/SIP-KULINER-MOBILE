import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../data/providers/saved_route_provider.dart';
import '../models/saved_route.dart';
import 'route_map_page.dart';
import 'package:intl/intl.dart';

class SavedRoutesPage extends ConsumerWidget {
  const SavedRoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(savedRoutesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Rute Tersimpan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: routesAsync.when(
        data: (routes) {
          if (routes.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return _SavedRouteCard(route: route);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Gagal memuat rute tersimpan: $error', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(savedRoutesProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Rute',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Jelajahi berbagai tempat kuliner menarik dan simpan rutenya agar mudah diakses kembali kapan saja!',
              textAlign: TextAlign.center,
              style: GoogleFonts.publicSans(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedRouteCard extends ConsumerWidget {
  final SavedRoute route;

  const _SavedRouteCard({required this.route});

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'walk':
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'motorcycle':
      case 'two-wheeler':
        return Icons.two_wheeler_rounded;
      case 'drive':
      case 'driving':
      case 'car':
      default:
        return Icons.directions_car_rounded;
    }
  }

  String _formatDistance(int? meters) {
    if (meters == null) return '-';
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatTime(int? seconds) {
    if (seconds == null) return '-';
    if (seconds < 60) return '$seconds dtk';
    final mins = seconds ~/ 60;
    if (mins < 60) return '$mins mnt';
    final hours = mins ~/ 60;
    return '$hours j ${mins % 60} m';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rute?'),
        content: Text('Anda yakin ingin menghapus rute "${route.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (route.id != null) {
                ref.read(savedRoutesProvider.notifier).deleteRoute(route.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _openRoute(BuildContext context) {
    if (route.waypoints.isEmpty) return;
    
    // Titik terakhir selalu dianggap destinasi akhir di UI kita
    final destination = route.waypoints.last;
    
    // Menyusun pre-saved waypoints untuk dipass ke RouteMapPage
    // Note: RouteMapPage logic default-nya akan mengambil current_location lagi sebagai origin.
    // Kita bisa passing preSavedWaypoints ke sana.

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteMapPage(
          destinationLat: destination.lat,
          destinationLng: destination.lng,
          destinationName: destination.name,
          preSavedWaypoints: route.waypoints,
          preSavedMode: route.mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final dateStr = route.createdAt != null ? dateFormat.format(route.createdAt!.toLocal()) : '';
    final stopCount = route.waypoints.length > 2 ? route.waypoints.length - 1 : 1; // Exclude origin

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => _openRoute(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getModeIcon(route.mode), color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$stopCount Tujuan',
                          style: GoogleFonts.publicSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    onPressed: () => _confirmDelete(context, ref),
                    tooltip: 'Hapus Rute',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.straighten_rounded, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(route.totalDistanceM),
                    style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer_outlined, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(route.totalDurationS),
                    style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.outlineVariant),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
