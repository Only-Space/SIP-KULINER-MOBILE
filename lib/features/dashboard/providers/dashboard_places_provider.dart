import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../models/food_item.dart';
import '../../../../data/services/geoapify_service.dart';
import '../../../../data/providers/supabase_provider.dart';
import '../../../../core/utils/location_permission_handler.dart';
import '../../../../core/errors/app_exception.dart';
import 'package:flutter/material.dart';

class DashboardPlacesState {
  final int selectedCategory;
  final String searchQuery;
  final List<FoodItem> places;
  final bool isLoading;
  final AppException? error;

  DashboardPlacesState({
    this.selectedCategory = 0,
    this.searchQuery = '',
    this.places = const [],
    this.isLoading = true,
    this.error,
  });

  DashboardPlacesState copyWith({
    int? selectedCategory,
    String? searchQuery,
    List<FoodItem>? places,
    bool? isLoading,
    AppException? error,
  }) {
    return DashboardPlacesState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardPlacesNotifier extends Notifier<DashboardPlacesState> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  final List<String> categories = const [
    'Semua Kategori', 'Jajanan Bali', 'Nasi Campur',
    'Sate & Panggang', 'Minuman Segar', 'Oleh-Oleh',
  ];

  @override
  DashboardPlacesState build() {
    return DashboardPlacesState();
  }

  Future<void> fetchPlaces(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await LocationPermissionHandler.checkAndRequestPermission(context);
      Position position = await Geolocator.getCurrentPosition();
      
      double radiusKm = 5.0;
      final session = ref.read(supabaseProvider).auth.currentSession;
      if (session != null) {
        final prefs = await ref.read(supabaseProvider).from('preferences').select('max_radius_km').eq('user_id', session.user.id).maybeSingle();
        if (prefs != null && prefs['max_radius_km'] != null) {
          radiusKm = (prefs['max_radius_km'] as num).toDouble();
        }
      }

      final String query = categories[state.selectedCategory];
      
      final results = await _geoapifyService.searchPlaces(
        lat: position.latitude,
        lng: position.longitude,
        radiusKm: radiusKm,
        categoryQuery: query,
        searchQuery: state.searchQuery,
      );

      state = state.copyWith(
        places: results.map((e) => e.toFoodItem()).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: parseException(e),
        isLoading: false,
      );
    }
  }

  void setCategory(BuildContext context, int index) {
    if (state.selectedCategory == index) return;
    state = state.copyWith(selectedCategory: index);
    fetchPlaces(context);
  }

  void setSearchQuery(BuildContext context, String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    fetchPlaces(context);
  }
}

final dashboardPlacesProvider = NotifierProvider<DashboardPlacesNotifier, DashboardPlacesState>(
  () => DashboardPlacesNotifier(),
);
