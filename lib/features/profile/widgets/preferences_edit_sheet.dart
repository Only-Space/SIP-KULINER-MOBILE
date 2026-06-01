import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';
import 'package:usada_rare/features/dashboard/providers/ai_recommendation_provider.dart';
import 'package:usada_rare/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:usada_rare/models/user_preferences.dart';
import 'package:usada_rare/features/profile/widgets/preferences_form.dart';

class PreferencesEditSheet extends ConsumerWidget {
  final UserPreferences initialPrefs;

  const PreferencesEditSheet({super.key, required this.initialPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ubah preferensi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              PreferencesForm(
                initialData: initialPrefs,
                submitLabel: 'Perbarui preferensi',
                showSkipButton: false,
                onSubmit: (prefs) async {
                  final supabase = ref.read(supabaseProvider);
                  final user = supabase.auth.currentUser;
                  if (user != null) {
                    await supabase.from('preferences').upsert({
                      'user_id': user.id,
                      'favorite_foods': prefs.favoriteFoods,
                      'avoid_foods': prefs.avoidFoods,
                      'daily_budget': prefs.dailyBudget,
                      'max_radius_km': prefs.maxRadiusKm,
                      'updated_at': DateTime.now().toUtc().toIso8601String(),
                    }, onConflict: 'user_id');

                    ref.invalidate(preferencesProvider);
                    ref.invalidate(aiRecommendationProvider);

                    if (initialPrefs.dailyBudget != prefs.dailyBudget) {
                      ref.read(mealPlanProvider.notifier).regenerate();
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preferensi berhasil diperbarui')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
