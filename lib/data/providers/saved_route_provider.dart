import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/saved_route_service.dart';
import '../../models/saved_route.dart';
import 'supabase_provider.dart';

final savedRouteServiceProvider = Provider<SavedRouteService>((ref) {
  return SavedRouteService();
});

class SavedRoutesNotifier extends AsyncNotifier<List<SavedRoute>> {
  @override
  Future<List<SavedRoute>> build() async {
    return _fetchRoutes();
  }

  Future<List<SavedRoute>> _fetchRoutes() async {
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return [];
    final service = ref.read(savedRouteServiceProvider);
    return service.getSavedRoutes(user.id);
  }

  Future<void> saveRoute(SavedRoute route) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savedRouteServiceProvider);
      await service.saveRoute(route);
      return _fetchRoutes();
    });
  }

  Future<void> deleteRoute(String routeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savedRouteServiceProvider);
      await service.deleteRoute(routeId);
      return _fetchRoutes();
    });
  }
}

final savedRoutesProvider = AsyncNotifierProvider<SavedRoutesNotifier, List<SavedRoute>>(() {
  return SavedRoutesNotifier();
});
