import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';
import 'package:usada_rare/features/profile/widgets/preferences_form.dart';

class PreferencesOnboardingSheet extends ConsumerWidget {
  const PreferencesOnboardingSheet({super.key});

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
                'Bantu kami mengenalmu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Agar rekomendasi makanan lebih tepat untukmu',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              PreferencesForm(
                initialData: null,
                submitLabel: 'Simpan preferensi',
                showSkipButton: true,
                onSkip: () async {
                  final supabase = ref.read(supabaseProvider);
                  final user = supabase.auth.currentUser;
                  if (user != null) {
                    await supabase.from('preferences').upsert({
                      'user_id': user.id,
                      'favorite_foods': [],
                      'avoid_foods': [],
                      'daily_budget': 50000,
                      'max_radius_km': 5.0,
                      'updated_at': DateTime.now().toUtc().toIso8601String(),
                    }, onConflict: 'user_id');
                    ref.invalidate(preferencesProvider);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                },
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
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/dashboard');
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
