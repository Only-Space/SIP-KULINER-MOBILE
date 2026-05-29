import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/geoapify_service.dart';
import '../../models/geoapify_place.dart';
import '../../core/errors/app_exception.dart';

class ExploreState {
  final List<GeoapifyPlace> places;
  final LatLng? userLocation;
  final String selectedCategory;
  final int radiusKm;
  final bool isLoading;
  final String? error;

  ExploreState({
    this.places = const [],
    this.userLocation,
    this.selectedCategory = 'Semua Kategori',
    this.radiusKm = 2,
    this.isLoading = false,
    this.error,
  });

  ExploreState copyWith({
    List<GeoapifyPlace>? places,
    LatLng? userLocation,
    String? selectedCategory,
    int? radiusKm,
    bool? isLoading,
    String? error,
  }) {
    return ExploreState(
      places: places ?? this.places,
      userLocation: userLocation ?? this.userLocation,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      radiusKm: radiusKm ?? this.radiusKm,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExploreNotifier extends Notifier<ExploreState> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  
  @override
  ExploreState build() {
    Future.microtask(_initFetch);
    return ExploreState();
  }

  Future<void> _initFetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pos = await _getUserLocation();
      final userLoc = LatLng(pos.latitude, pos.longitude);
      state = state.copyWith(userLocation: userLoc);
      await fetchPlaces();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw LocationException('Layanan lokasi dinonaktifkan.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Izin lokasi ditolak.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchPlaces() async {
    if (state.userLocation == null) return;
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final places = await _geoapifyService.searchPlaces(
        lat: state.userLocation!.latitude,
        lng: state.userLocation!.longitude,
        radiusKm: state.radiusKm.toDouble(),
        categoryQuery: state.selectedCategory == 'Semua Kategori' ? null : state.selectedCategory,
        limit: 50,
      );
      
      state = state.copyWith(places: places, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    fetchPlaces();
  }

  void setRadius(int km) {
    if (state.radiusKm == km) return;
    state = state.copyWith(radiusKm: km);
    fetchPlaces();
  }

  void updateLocation(LatLng newLocation) {
    state = state.copyWith(userLocation: newLocation);
    fetchPlaces();
  }
}

final exploreProvider = NotifierProvider<ExploreNotifier, ExploreState>(() {
  return ExploreNotifier();
});
