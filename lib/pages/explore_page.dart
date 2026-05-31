import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../core/widgets/cached_image.dart';
import '../core/widgets/skeleton_loader.dart';
import '../data/providers/explore_provider.dart';
import '../models/geoapify_place.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  GeoapifyPlace? _selectedPlace;
  
  final _categories = const [
    'Semua Kategori', 'Jajanan Bali', 'Nasi Campur',
    'Sate & Panggang', 'Minuman Segar', 'Oleh-Oleh',
  ];

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final exploreState = ref.watch(exploreProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          _buildMap(exploreState),
          _buildTopFilters(exploreState),
          if (_selectedPlace != null) _buildBottomSheet(),
          if (exploreState.isLoading && exploreState.places.isEmpty)
            const Center(child: SkeletonLoader(width: double.infinity, height: double.infinity)),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _selectedPlace != null ? 150.0 : 16.0),
        child: FloatingActionButton(
          onPressed: () {
            if (exploreState.userLocation != null) {
              _mapController.move(exploreState.userLocation!, 15.0);
            } else {
              ref.read(exploreProvider.notifier).fetchPlaces();
            }
          },
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          child: const Icon(Icons.my_location_rounded),
        ),
      ),
    );
  }

  Widget _buildMap(ExploreState state) {
    if (state.userLocation == null && !state.isLoading) {
      return const Center(child: Text('Gagal mendapatkan lokasi.'));
    }

    final initialLocation = state.userLocation ?? const LatLng(-8.6705, 115.2126); // Default to Denpasar

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialLocation,
        initialZoom: 14.0,
        onTap: (_, __) {
          if (_selectedPlace != null) {
            setState(() => _selectedPlace = null);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.example.sipkuliner',
        ),
        if (state.userLocation != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: state.userLocation!,
                color: AppColors.primary.withValues(alpha: 0.15),
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                borderStrokeWidth: 2,
                useRadiusInMeter: true,
                radius: state.radiusKm * 1000.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (state.userLocation != null)
              Marker(
                point: state.userLocation!,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                ),
              ),
            ...state.places.map((place) => _buildMarker(place)),
          ],
        ),
      ],
    );
  }

  Marker _buildMarker(GeoapifyPlace place) {
    final isSelected = _selectedPlace?.id == place.id;
    
    // Warna pin berdasarkan kategori sederhana
    Color pinColor = AppColors.secondary;
    if (place.categoryName.toLowerCase().contains('kafe')) {
      pinColor = AppColors.primary;
    } else if (place.categoryName.toLowerCase().contains('cepat saji')) {
      pinColor = AppColors.error;
    }

    return Marker(
      point: LatLng(place.latitude, place.longitude),
      width: isSelected ? 48 : 36,
      height: isSelected ? 48 : 36,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPlace = place);
          _mapController.move(LatLng(place.latitude, place.longitude), _mapController.camera.zoom);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isSelected ? 6 : 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : pinColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: isSelected ? 20 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopFilters(ExploreState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radius Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == state.selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat, style: GoogleFonts.publicSans(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                            selected: isSelected,
                            onSelected: (_) => ref.read(exploreProvider.notifier).setCategory(cat),
                            backgroundColor: AppColors.surface,
                            selectedColor: AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
                            side: BorderSide(color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.5)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: PopupMenuButton<int>(
                    icon: const Icon(Icons.radar_rounded, color: AppColors.primary),
                    tooltip: 'Radius Pencarian',
                    position: PopupMenuPosition.under,
                    onSelected: (km) => ref.read(exploreProvider.notifier).setRadius(km),
                    itemBuilder: (context) => [
                      _buildRadiusItem(1, state.radiusKm),
                      _buildRadiusItem(2, state.radiusKm),
                      _buildRadiusItem(5, state.radiusKm),
                      _buildRadiusItem(10, state.radiusKm),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildRadiusItem(int value, int currentValue) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$value km'),
          if (value == currentValue) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final place = _selectedPlace!;
    
    // Kita gunakan konversi ke FoodItem untuk UI agar konsisten dengan place detail
    final foodItem = place.toFoodItem();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedImage(
                  imageUrl: foodItem.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      foodItem.name,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      foodItem.tags.isNotEmpty ? foodItem.tags.first : 'Tempat Makan',
                      style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${foodItem.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Text('(${foodItem.reviews})', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.outlineVariant)),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/detail', arguments: place.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Detail', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
