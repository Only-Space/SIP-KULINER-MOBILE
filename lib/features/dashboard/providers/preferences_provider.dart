import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/supabase_provider.dart';
import '../../../../models/user_preferences.dart';

/// Mengambil preferensi pengguna dari tabel `preferences` di Supabase.
///
/// Kolom yang dibaca:
///   - `favorite_foods`  → `text[]`
///   - `avoid_foods`     → `text[]`
///   - `max_radius_km`   → `float8`
///   - `daily_budget`    → `int4`
///
/// Jika baris belum ada untuk user yang sedang login,
/// mengembalikan [UserPreferences] dengan nilai default.
final preferencesProvider = FutureProvider<UserPreferences>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  // Jika belum login, kembalikan preferensi default
  if (userId == null) return const UserPreferences();

  try {
    final row = await supabase
        .from('preferences')
        .select('favorite_foods, avoid_foods, max_radius_km, daily_budget')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return const UserPreferences();

    return UserPreferences(
      favoriteFoods: List<String>.from(row['favorite_foods'] ?? []),
      avoidFoods: List<String>.from(row['avoid_foods'] ?? []),
      maxRadiusKm: (row['max_radius_km'] as num?)?.toDouble() ?? 5.0,
      dailyBudget: (row['daily_budget'] as num?)?.toInt() ?? 50000,
    );
  } catch (e) {
    // Jika tabel belum ada atau error jaringan, fallback ke default
    return const UserPreferences();
  }
});
