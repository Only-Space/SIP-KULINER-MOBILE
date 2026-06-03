import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';
import 'package:usada_rare/models/meal_plan.dart';
import 'package:usada_rare/models/geoapify_place.dart';
import 'package:usada_rare/services/meal_plan_service.dart';
import 'package:usada_rare/data/services/geoapify_service.dart';
import 'package:geolocator/geolocator.dart';

/// Flag key untuk one-shot cache clear saat prompt v2 di-deploy.
const _kMealPlanV2ClearedKey = 'meal_plan_v2_cleared';

/// Flag key untuk one-shot cache clear saat budget enforcement di-deploy.
const _kBudgetEnforcedV1Key = 'budget_enforced_v1';

final mealPlanLoadingMessageProvider = NotifierProvider<MealPlanLoadingNotifier, String>(() => MealPlanLoadingNotifier());

class MealPlanLoadingNotifier extends Notifier<String> {
  @override
  String build() => 'AI sedang menyusun menu 30 hari untukmu...';
  
  set state(String value) => super.state = value;
}

final mealPlanProvider = AsyncNotifierProvider<MealPlanNotifier, MealPlan?>(MealPlanNotifier.new);

class MealPlanNotifier extends AsyncNotifier<MealPlan?> {
  final MealPlanService _service = MealPlanService();

  @override
  Future<MealPlan?> build() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final prefs = await ref.watch(preferencesProvider.future);

    // ── ONE-SHOT CACHE CLEAR: hapus cache lama saat prompt v2 pertama kali di-deploy ──
    try {
      final sp = await SharedPreferences.getInstance();
      final alreadyCleared = sp.getBool(_kMealPlanV2ClearedKey) ?? false;
      if (!alreadyCleared) {
        debugPrint('[MEAL_PLAN_PROVIDER] Prompt v2 terdeteksi — menghapus cache lama.');
        await supabase.from('meal_plan_cache').delete().eq('user_id', userId);
        await sp.setBool(_kMealPlanV2ClearedKey, true);
        await sp.setBool(_kBudgetEnforcedV1Key, true); // lewati check berikutnya
        return _generateAndCache(prefs, userId);
      }
    } catch (e) {
      debugPrint('[MEAL_PLAN_PROVIDER] One-shot clear v2 gagal (non-fatal): $e');
    }

    // ── ONE-SHOT CACHE CLEAR: hapus cache lama saat budget enforcement di-deploy ──
    try {
      final sp = await SharedPreferences.getInstance();
      final budgetEnforced = sp.getBool(_kBudgetEnforcedV1Key) ?? false;
      if (!budgetEnforced) {
        debugPrint('[MEAL_PLAN_PROVIDER] Budget enforcement v1 terdeteksi — menghapus cache lama.');
        await supabase.from('meal_plan_cache').delete().eq('user_id', userId);
        await sp.setBool(_kBudgetEnforcedV1Key, true);
        return _generateAndCache(prefs, userId);
      }
    } catch (e) {
      debugPrint('[MEAL_PLAN_PROVIDER] One-shot clear budget_enforced_v1 gagal (non-fatal): $e');
    }

    // Cek cache
    try {
      final cacheRes = await supabase
          .from('meal_plan_cache')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (cacheRes != null) {
        try {
          final expiresAt = DateTime.parse(cacheRes['expires_at'] as String);
          final budgetSnapshot = cacheRes['budget_snapshot'] as int;

          if (DateTime.now().isBefore(expiresAt) && budgetSnapshot == prefs.dailyBudget) {
            debugPrint('[MEAL_PLAN_PROVIDER] Cache valid & budget tidak berubah. Menggunakan cache.');
            return MealPlan.fromJson(cacheRes['plan_json'] as Map<String, dynamic>);
          }
        } catch (e) {
          debugPrint('[MEAL_PLAN_PROVIDER] Cache corrupt, hapus dan regenerate: $e');
          await supabase.from('meal_plan_cache').delete().eq('user_id', userId);
        }
      }
    } catch (e) {
      debugPrint('[MEAL_PLAN_PROVIDER] Gagal membaca cache: $e');
    }

    // Generate baru jika cache tidak ada, kedaluwarsa, atau budget berubah
    return _generateAndCache(prefs, userId);
  }

  Future<MealPlan?> _generateAndCache(preferences, String userId) async {
    debugPrint('[MEAL_PLAN_PROVIDER] Generating baru...');
    ref.read(mealPlanLoadingMessageProvider.notifier).state = 'Mencari warung sekitar...';

    List<GeoapifyPlace> places = [];
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final geoService = GeoapifyService();
      places = await geoService.searchPlaces(
        lat: position.latitude,
        lng: position.longitude,
        radiusKm: preferences.maxRadiusKm,
        limit: 30,
      );
    } catch (e) {
      debugPrint('[MEAL_PLAN_PROVIDER] Gagal mendapatkan lokasi/tempat: $e');
    }

    if (places.isEmpty) {
      const fallbackNames = [
        'Warung Nasi Bali', 'Depot Bu Made', 'RM Ayam Betutu Khas Bali',
        'Warung Soto Bali', 'Kedai Nasi Jingo', 'Warung Lawar Bali',
        'Depot Bebek Bengil', 'RM Nasi Campur Bali', 'Warung Mie Ayam Pak Wayan',
        'Depot Sate Lilit Bali',
      ];
      places = fallbackNames.map((name) => GeoapifyPlace(
        id: 'fallback_${name.hashCode}',
        name: name,
        latitude: -8.65,
        longitude: 115.22,
        address: 'Bali',
        categoryName: 'Rumah Makan',
        distance: 0,
      )).toList();
    }

    ref.read(mealPlanLoadingMessageProvider.notifier).state = 'Bersiap...';

    final newPlan = await _service.generateMealPlan(
      preferences: preferences,
      nearbyPlaces: places,
      onProgress: (msg) {
        ref.read(mealPlanLoadingMessageProvider.notifier).state = msg;
      }
    );
    
    // Simpan ke cache
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('meal_plan_cache').upsert({
        'user_id': userId,
        'plan_json': newPlan.toJson(),
        'budget_snapshot': preferences.dailyBudget,
        'generated_at': DateTime.now().toUtc().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String(),
      });
      debugPrint('[MEAL_PLAN_PROVIDER] Berhasil menyimpan ke cache');
    } catch (e) {
      debugPrint('[MEAL_PLAN_PROVIDER] Gagal menyimpan ke cache: $e');
    }
    
    return newPlan;
  }

  Future<void> regenerate() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();

    try {
      await supabase.from('meal_plan_cache').delete().eq('user_id', userId);

      final prefs = await ref.read(preferencesProvider.future);
      final newPlan = await _generateAndCache(prefs, userId);

      state = AsyncValue.data(newPlan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Hapus cache Supabase lalu generate ulang meal plan.
  /// Dipanggil dari SettingsPage ("Reset rencana makan") dan MealPlanPage FAB.
  ///
  /// PENTING: gunakan state = loading + _generateAndCache() langsung,
  /// BUKAN ref.invalidateSelf() — invalidateSelf() men-trigger build() ulang
  /// sehingga _generateAndCache() dipanggil dua kali secara paralel.
  Future<void> clearCacheAndRegenerate() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();

    try {
      await supabase.from('meal_plan_cache').delete().eq('user_id', userId);
      debugPrint('[MEAL_PLAN_PROVIDER] Cache dihapus via clearCacheAndRegenerate.');

      final prefs = await ref.read(preferencesProvider.future);
      final newPlan = await _generateAndCache(prefs, userId);

      state = AsyncValue.data(newPlan);
    } catch (e, st) {
      debugPrint('[MEAL_PLAN_PROVIDER] Gagal clearCacheAndRegenerate: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
