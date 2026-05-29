import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/services/geoapify_service.dart';
import '../app_theme.dart';

class RouteMapPage extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationName;

  const RouteMapPage({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
  });

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class RouteWaypoint {
  final String name;
  final LatLng point;
  RouteWaypoint(this.name, this.point);
}

class _RouteMapPageState extends State<RouteMapPage> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  bool _isLoading = true;
  String? _errorMessage;
  LatLng? _currentPosition;
  RouteData? _routeData;
  String _travelMode = 'drive'; // drive, motorcycle, walk
  final List<RouteWaypoint> _destinations = [];

  @override
  void initState() {
    super.initState();
    _destinations.add(RouteWaypoint(widget.destinationName, LatLng(widget.destinationLat, widget.destinationLng)));
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 1. Dapatkan lokasi saat ini
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi dinonaktifkan.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.');
      }

      final position = await Geolocator.getCurrentPosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _currentPosition = currentLatLng;
        });
      }

      // 2. Gabungkan lokasi saat ini dengan semua tujuan
      final List<LatLng> allWaypoints = [currentLatLng, ..._destinations.map((d) => d.point)];

      // 3. Dapatkan rute dari Geoapify
      final routeData = await _geoapifyService.getRoute(
        waypoints: allWaypoints,
        mode: _travelMode,
      );

      if (mounted) {
        setState(() {
          _routeData = routeData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showAddDestinationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _AddDestinationSheet(
        currentLat: _currentPosition?.latitude ?? widget.destinationLat,
        currentLng: _currentPosition?.longitude ?? widget.destinationLng,
        onPlaceSelected: (placeName, lat, lng) {
          setState(() {
            _destinations.add(RouteWaypoint(placeName, LatLng(lat, lng)));
          });
          _fetchRoute();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Kuliner'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDestinationModal,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Tambah Tujuan'),
      ),
    );
  }

  void _startNavigation() async {
    if (_currentPosition == null || _destinations.isEmpty) return;
    
    // Buka Google Maps Navigation
    // https://www.google.com/maps/dir/?api=1&origin=lat,lng&destination=lat,lng&waypoints=lat,lng|lat,lng&travelmode=driving
    
    final origin = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final destination = '${_destinations.last.point.latitude},${_destinations.last.point.longitude}';
    
    String waypointsStr = '';
    if (_destinations.length > 1) {
      final wps = _destinations.sublist(0, _destinations.length - 1).map((d) => '${d.point.latitude},${d.point.longitude}');
      waypointsStr = '&waypoints=${wps.join('|')}';
    }

    String gmapsMode = 'driving';
    if (_travelMode == 'motorcycle') gmapsMode = 'two-wheeler';
    if (_travelMode == 'walk') gmapsMode = 'walking';

    final url = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination$waypointsStr&travelmode=$gmapsMode';
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka Google Maps')));
      }
    }
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds dtk';
    final mins = seconds ~/ 60;
    if (mins < 60) return '$mins mnt';
    final hours = mins ~/ 60;
    final remainingMins = mins % 60;
    return '$hours jam $remainingMins mnt';
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Widget _buildBody() {
    final routePoints = _routeData?.points ?? [];

    if (_isLoading && routePoints.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mencari rute terbaik...'),
          ],
        ),
      );
    }

    if (_errorMessage != null && routePoints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat rute:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchRoute,
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    final List<LatLng> boundsPoints = [];
    if (_currentPosition != null) boundsPoints.add(_currentPosition!);
    boundsPoints.addAll(_destinations.map((d) => d.point));
    boundsPoints.addAll(routePoints);

    final bounds = LatLngBounds.fromPoints(boundsPoints);

    // Titik awal yang dipaskan (snapped) ke tengah jalan dari routePoints
    final LatLng startPoint = routePoints.isNotEmpty ? routePoints.first : _currentPosition!;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50.0),
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
                  color: Colors.blue,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (_currentPosition != null)
                  Marker(
                    point: startPoint,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
                ..._destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dest = entry.value;
                  return Marker(
                    point: dest.point,
                    width: 50,
                    height: 50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const Icon(Icons.location_on, color: Colors.red, size: 24),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        
        // Panel Informasi di Bawah
        Positioned(
          bottom: 80, // Supaya di atas FAB
          left: 16,
          right: 16,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModeButton(Icons.directions_car, 'Mobil', 'drive'),
                      _buildModeButton(Icons.two_wheeler, 'Motor', 'motorcycle'),
                      _buildModeButton(Icons.directions_walk, 'Jalan', 'walk'),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_routeData != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatTime(_routeData!.timeSeconds),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(
                              _formatDistance(_routeData!.distanceMeters),
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _startNavigation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.navigation),
                          label: const Text('Mulai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        if (_isLoading)
          Positioned(
            top: 16,
            left: 0, right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Memperbarui rute...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModeButton(IconData icon, String label, String mode) {
    final isSelected = _travelMode == mode;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _travelMode = mode;
          });
          _fetchRoute();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _AddDestinationSheet extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final Function(String name, double lat, double lng) onPlaceSelected;

  const _AddDestinationSheet({
    required this.currentLat,
    required this.currentLng,
    required this.onPlaceSelected,
  });

  @override
  State<_AddDestinationSheet> createState() => _AddDestinationSheetState();
}

class _AddDestinationSheetState extends State<_AddDestinationSheet> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = []; // We will use GeoapifyPlace

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final results = await _geoapifyService.searchPlaces(
        lat: widget.currentLat,
        lng: widget.currentLng,
        radiusKm: 50,
        categoryQuery: query,
        limit: 10,
      );
      if (mounted) setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencari: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Tambah Tujuan Kuliner Berikutnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tempat (misal: Sate, Kopi, dsb)',
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? const Center(child: Text('Ketik untuk mencari tujuan baru'))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.restaurant, color: Colors.orange),
                              title: Text(place.name),
                              subtitle: Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                Navigator.pop(context);
                                widget.onPlaceSelected(place.name, place.latitude, place.longitude);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
