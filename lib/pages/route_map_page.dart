import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/geoapify_service.dart';
import '../app_theme.dart';
import '../data/providers/supabase_provider.dart';
import '../data/providers/saved_route_provider.dart';
import '../models/saved_route.dart';
import 'saved_routes_page.dart';

import '../widgets/route/route_map_view.dart';
import '../widgets/route/route_info_panel.dart';
import '../widgets/route/route_waypoint_sheet.dart';

class RouteMapPage extends ConsumerStatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final List<RouteWaypointData>? preSavedWaypoints;
  final String? preSavedMode;

  const RouteMapPage({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    this.preSavedWaypoints,
    this.preSavedMode,
  });

  @override
  ConsumerState<RouteMapPage> createState() => _RouteMapPageState();
}

class RouteWaypoint {
  final String name;
  final LatLng point;
  RouteWaypoint(this.name, this.point);
}

class _RouteMapPageState extends ConsumerState<RouteMapPage> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  bool _isLoading = true;
  String? _errorMessage;
  LatLng? _currentPosition;
  RouteData? _routeData;
  String _travelMode = 'drive';
  final List<RouteWaypoint> _destinations = [];

  @override
  void initState() {
    super.initState();
    if (widget.preSavedMode != null) {
      _travelMode = widget.preSavedMode!;
    }

    if (widget.preSavedWaypoints != null && widget.preSavedWaypoints!.isNotEmpty) {
      for (var wp in widget.preSavedWaypoints!) {
        if (!wp.isOrigin) {
          _destinations.add(RouteWaypoint(wp.name, LatLng(wp.lat, wp.lng)));
        }
      }
    } else {
      _destinations.add(RouteWaypoint(
        widget.destinationName,
        LatLng(widget.destinationLat, widget.destinationLng),
      ));
    }
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi dinonaktifkan.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Izin lokasi ditolak.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
      }

      final position = await Geolocator.getCurrentPosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);
      if (mounted) setState(() => _currentPosition = currentLatLng);

      final allWaypoints = [currentLatLng, ..._destinations.map((d) => d.point)];
      final routeData = await _geoapifyService.getRoute(waypoints: allWaypoints, mode: _travelMode);
      if (mounted) setState(() { _routeData = routeData; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  void _showAddDestinationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => RouteWaypointSheet(
        currentLat: _currentPosition?.latitude ?? widget.destinationLat,
        currentLng: _currentPosition?.longitude ?? widget.destinationLng,
        onPlaceSelected: (name, lat, lng) {
          setState(() => _destinations.add(RouteWaypoint(name, LatLng(lat, lng))));
          _fetchRoute();
        },
      ),
    );
  }

  void _saveRoute() {
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login untuk menyimpan rute.')));
      return;
    }
    if (_currentPosition == null || _destinations.isEmpty) return;

    final defaultName = 'Rute ke ${_destinations.last.name}';
    final nameController = TextEditingController(text: defaultName);

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Simpan Rute'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Rute'),
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  setStateDialog(() => isSaving = true);
                  try {
                    final waypoints = <RouteWaypointData>[
                      RouteWaypointData(name: 'Lokasi Saya', lat: _currentPosition!.latitude, lng: _currentPosition!.longitude, isOrigin: true),
                      ..._destinations.map((d) => RouteWaypointData(name: d.name, lat: d.point.latitude, lng: d.point.longitude)),
                    ];
                    
                    final savedRoute = SavedRoute(
                      userId: user.id,
                      name: nameController.text.trim(),
                      mode: _travelMode,
                      waypoints: waypoints,
                      totalDistanceM: _routeData?.distanceMeters,
                      totalDurationS: _routeData?.timeSeconds,
                    );
                    
                    await ref.read(savedRoutesProvider.notifier).saveRoute(savedRoute);
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Rute berhasil disimpan!'),
                          action: SnackBarAction(
                            label: 'Lihat Semua',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SavedRoutesPage()),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    setStateDialog(() => isSaving = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startNavigation() async {
    if (_currentPosition == null || _destinations.isEmpty) return;
    final origin = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final destination = '${_destinations.last.point.latitude},${_destinations.last.point.longitude}';
    String waypointsStr = '';
    if (_destinations.length > 1) {
      final wps = _destinations.sublist(0, _destinations.length - 1).map((d) => '${d.point.latitude},${d.point.longitude}');
      waypointsStr = '&waypoints=${wps.join('|')}';
    }
    String gmapsMode = _travelMode == 'motorcycle' ? 'two-wheeler' : _travelMode == 'walk' ? 'walking' : 'driving';
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination$waypointsStr&travelmode=$gmapsMode');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka Google Maps')));
    }
  }

  void _onModeTap(String mode) {
    if (_travelMode == mode) return;
    setState(() => _travelMode = mode);
    _fetchRoute();
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _routeData?.points ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Rute Kuliner',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildBody(routePoints),
      ),
    );
  }

  Widget _buildBody(List<LatLng> routePoints) {
    if (_isLoading && routePoints.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Mencari rute terbaik...', style: GoogleFonts.publicSans(color: AppColors.onSurfaceVariant)),
          ]),
        ),
      );
    }

    if (_errorMessage != null && routePoints.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Gagal memuat rute', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchRoute,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Coba Lagi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      );
    }

    return Stack(children: [
      RouteMapView(
        routePoints: routePoints,
        currentPosition: _currentPosition,
        destinations: _destinations,
      ),

      if (_isLoading)
        Positioned(
          top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
          left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.medium),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                const SizedBox(width: 8),
                Text('Memperbarui rute...', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),

      RouteInfoPanel(
        routeData: _routeData,
        travelMode: _travelMode,
        onModeTap: _onModeTap,
        onSaveRoute: _saveRoute,
        onStartNavigation: _startNavigation,
        onAddDestination: _showAddDestinationModal,
        destinations: _destinations,
      ),
    ]);
  }
}
