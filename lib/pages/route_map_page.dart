import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
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
      // Load preSavedWaypoints, skipping the origin point so we can substitute it with the current location
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
      builder: (context) => _AddDestinationSheet(
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

    final boundsPoints = <LatLng>[];
    if (_currentPosition != null) boundsPoints.add(_currentPosition!);
    boundsPoints.addAll(_destinations.map((d) => d.point));
    boundsPoints.addAll(routePoints);
    final bounds = LatLngBounds.fromPoints(boundsPoints);
    final startPoint = routePoints.isNotEmpty ? routePoints.first : _currentPosition!;

    return Stack(children: [
      // ─── Peta ───────────────────────────────────────────────────
      FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.fromLTRB(40, 100, 40, 300)),
        ),
        children: [
          TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.example.sipkuliner'),
          PolylineLayer(polylines: [
            Polyline(points: routePoints, strokeWidth: 5.0, color: AppColors.accent, strokeCap: StrokeCap.round),
          ]),
          MarkerLayer(markers: [
            if (_currentPosition != null)
              Marker(
                point: startPoint, width: 44, height: 44,
                child: Container(
                  decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: AppShadows.medium),
                  child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                ),
              ),
            ..._destinations.asMap().entries.map((e) => Marker(
              point: e.value.point, width: 44, height: 44,
              child: Container(
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: AppShadows.medium),
                child: Center(
                  child: Text('${e.key + 1}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
            )),
          ]),
        ],
      ),

      // Loading chip overlay
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

      // ─── Bottom Sheet Persistent ────────────────────────────────
      DraggableScrollableSheet(
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
                Row(children: [
                  _ModePill(icon: Icons.directions_car_rounded, label: 'Mobil', mode: 'drive', selectedMode: _travelMode, onTap: _onModeTap),
                  const SizedBox(width: 8),
                  _ModePill(icon: Icons.two_wheeler_rounded, label: 'Motor', mode: 'motorcycle', selectedMode: _travelMode, onTap: _onModeTap),
                  const SizedBox(width: 8),
                  _ModePill(icon: Icons.directions_walk_rounded, label: 'Jalan', mode: 'walk', selectedMode: _travelMode, onTap: _onModeTap),
                ]),

                const SizedBox(height: 20),

                // Stats row
                if (_routeData != null) ...[
                  Row(children: [
                    _StatItem(icon: Icons.timer_rounded, value: _formatTime(_routeData!.timeSeconds), label: 'Estimasi', color: AppColors.success),
                    const SizedBox(width: 24),
                    _StatItem(icon: Icons.straighten_rounded, value: _formatDistance(_routeData!.distanceMeters), label: 'Jarak', color: AppColors.accent),
                  ]),
                  const SizedBox(height: 20),
                ],

                // Daftar tujuan
                if (_destinations.isNotEmpty) ...[
                  Text('Tujuan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  ..._destinations.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
                    onPressed: _showAddDestinationModal,
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
                    onPressed: _routeData != null ? _saveRoute : null,
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
                      onPressed: _routeData != null ? _startNavigation : null,
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
      ),
    ]);
  }

  void _onModeTap(String mode) {
    if (_travelMode == mode) return;
    setState(() => _travelMode = mode);
    _fetchRoute();
  }
}

// ─── Mode Pill ─────────────────────────────────────────────────────────────

class _ModePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String mode;
  final String selectedMode;
  final ValueChanged<String> onTap;

  const _ModePill({required this.icon, required this.label, required this.mode, required this.selectedMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == selectedMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.chipActiveGradient : null,
            color: isSelected ? null : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.publicSans(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : AppColors.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}

// ─── Stat Item ─────────────────────────────────────────────────────────────

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

// ─── Add Destination Sheet ─────────────────────────────────────────────────

class _AddDestinationSheet extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final Function(String name, double lat, double lng) onPlaceSelected;

  const _AddDestinationSheet({required this.currentLat, required this.currentLng, required this.onPlaceSelected});

  @override
  State<_AddDestinationSheet> createState() => _AddDestinationSheetState();
}

class _AddDestinationSheetState extends State<_AddDestinationSheet> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final results = await _geoapifyService.searchPlaces(lat: widget.currentLat, lng: widget.currentLng, radiusKm: 50, categoryQuery: query, limit: 10);
      if (mounted) setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencari: $e')));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(children: [
        Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tambah Tujuan Berikutnya', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Cari tempat kuliner...',
                hintStyle: GoogleFonts.publicSans(color: AppColors.outlineVariant),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: IconButton(icon: const Icon(Icons.search_rounded, color: AppColors.primary), onPressed: _search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.outlineVariant)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _searchResults.isEmpty
                  ? Center(child: Text('Ketik untuk mencari tujuan baru', style: GoogleFonts.publicSans(color: AppColors.outlineVariant)))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return ListTile(
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 20),
                          ),
                          title: Text(place.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          subtitle: Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onPlaceSelected(place.name, place.latitude, place.longitude);
                          },
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
