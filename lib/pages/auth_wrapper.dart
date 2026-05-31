import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/pages/dashboard_page.dart';
import 'package:usada_rare/pages/login_pages.dart';
import 'package:usada_rare/features/profile/pages/onboarding_preferences_page.dart';
import 'package:usada_rare/core/widgets/skeleton_loader.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) {
        final session = authState.session;
        if (session == null) {
          return const LoginPages();
        }

        // Jika terautentikasi, periksa preferensi di tabel preferences
        return FutureBuilder(
          future: ref
              .read(supabaseProvider)
              .from('preferences')
              .select()
              .eq('user_id', session.user.id)
              .maybeSingle(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: SkeletonLoader(width: 60, height: 60, borderRadius: 30)),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Terjadi kesalahan: ${snapshot.error}'),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              // Jika data preferensi belum ada
              return const OnboardingPreferencesPage();
            } else {
              // Jika data preferensi sudah ada
              return const DashboardPage();
            }
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: SkeletonLoader(width: 60, height: 60, borderRadius: 30)),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
