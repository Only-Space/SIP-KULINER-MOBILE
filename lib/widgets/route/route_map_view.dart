import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../pages/route_map_page.dart';

class RouteMapView extends StatelessWidget {
  final List<LatLng> routePoints;
  final LatLng? currentPosition;
  final List<RouteWaypoint> destinations;

  const RouteMapView({
    super.key,
    required this.routePoints,
    required this.currentPosition,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final boundsPoints = <LatLng>[];
    if (currentPosition != null) boundsPoints.add(currentPosition!);
    boundsPoints.addAll(destinations.map((d) => d.point));
    boundsPoints.addAll(routePoints);
    
    final bounds = boundsPoints.isNotEmpty 
        ? LatLngBounds.fromPoints(boundsPoints)
        : LatLngBounds(const LatLng(0, 0), const LatLng(0, 0)); // fallback
        
    final startPoint = routePoints.isNotEmpty ? routePoints.first : currentPosition;

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds, 
          padding: const EdgeInsets.fromLTRB(40, 100, 40, 300),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', 
          userAgentPackageName: 'com.example.sipkuliner',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints, 
              strokeWidth: 5.0, 
              color: AppColors.accent, 
              strokeCap: StrokeCap.round,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (currentPosition != null && startPoint != null)
              Marker(
                point: startPoint, 
                width: 44, 
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: Colors.white, width: 3), 
                    boxShadow: AppShadows.medium,
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                ),
              ),
            ...destinations.asMap().entries.map((e) => Marker(
              point: e.value.point, 
              width: 44, 
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white, width: 2), 
                  boxShadow: AppShadows.medium,
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}', 
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }
}
