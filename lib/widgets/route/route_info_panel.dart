import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../data/services/geoapify_service.dart';
import '../../pages/route_map_page.dart'; // To get RouteWaypoint
import 'route_transport_pills.dart';

class RouteInfoPanel extends StatelessWidget {
  final RouteData? routeData;
  final String travelMode;
  final ValueChanged<String> onModeTap;
  final VoidCallback? onSaveRoute;
  final VoidCallback? onStartNavigation;
  final VoidCallback onAddDestination;
  final List<RouteWaypoint> destinations;

  const RouteInfoPanel({
    super.key,
    this.routeData,
    required this.travelMode,
    required this.onModeTap,
    this.onSaveRoute,
    this.onStartNavigation,
    required this.onAddDestination,
    required this.destinations,
  });

  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds dtk';
    final mins = seconds ~/ 60;
    if (mins < 60) return '$mins mnt';
    final hours = mins ~/ 60;
    return '$hours j ${mins % 60} m';
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.15,
      maxChildSize: 0.65,
      snap: true,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppShadows.strong,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Mode pills
              RouteTransportPills(
                selectedMode: travelMode,
                onChanged: onModeTap,
              ),

              const SizedBox(height: 20),

              // Stats row
              if (routeData != null) ...[
                Row(children: [
                  _StatItem(icon: Icons.timer_rounded, value: _formatTime(routeData!.timeSeconds), label: 'Estimasi', color: AppColors.success),
                  const SizedBox(width: 24),
                  _StatItem(icon: Icons.straighten_rounded, value: _formatDistance(routeData!.distanceMeters), label: 'Jarak', color: AppColors.accent),
                ]),
                const SizedBox(height: 20),
              ],

              // Daftar tujuan
              if (destinations.isNotEmpty) ...[
                Text('Tujuan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                ...destinations.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(child: Text('${e.key + 1}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value.name, style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                )),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(children: [
                OutlinedButton(
                  onPressed: onAddDestination,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.add_location_alt_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onSaveRoute,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.bookmark_outline_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStartNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 18),
                    label: Text('Mulai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface, height: 1)),
        Text(label, style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
      ]),
    ]);
  }
}
