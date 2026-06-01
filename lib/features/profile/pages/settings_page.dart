import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';
import 'package:usada_rare/features/profile/widgets/preferences_edit_sheet.dart';

// Dummy provider to satisfy the compilation and logic for the missing mealPlanProvider
// TODO: Replace with the actual mealPlanProvider when implemented
final dummyMealPlanProvider = NotifierProvider<DummyMealPlanNotifier, bool>(() => DummyMealPlanNotifier());

class DummyMealPlanNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void regenerate() => state = true;
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);
    final isMealPlanGenerated = ref.watch(dummyMealPlanProvider); // Replace with actual mealPlan check

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.surface,
      body: ListView(
        children: [
          // ── Preferensi Makan ──────────────────────────────────────────────────
          _buildSectionHeader('Preferensi Makan'),
          ListTile(
            title: const Text('Ubah preferensi makanan'),
            subtitle: const Text('Makanan favorit, pantangan, budget harian'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              prefsAsync.whenData((prefs) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PreferencesEditSheet(initialPrefs: prefs),
                );
              });
            },
          ),
          const Divider(height: 1),

          // ── Rencana Makan ─────────────────────────────────────────────────────
          _buildSectionHeader('Rencana Makan'),
          ListTile(
            title: const Text('Budget bulanan'),
            subtitle: prefsAsync.when(
              data: (prefs) => Text(
                  'Rp ${prefs.dailyBudget.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => '.')} / hari'),
              loading: () => const Text('Memuat...'),
              error: (_, __) => const Text('Gagal memuat'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Dialog ubah budget (simpel)
              prefsAsync.whenData((prefs) {
                _showBudgetDialog(context, ref, prefs.dailyBudget);
              });
            },
          ),
          if (isMealPlanGenerated) // Sembunyikan tile jika belum di-generate
            ListTile(
              title: const Text('Reset rencana makan'),
              subtitle: const Text('Buat ulang menu 30 hari berdasarkan preferensi terbaru'),
              trailing: const Icon(Icons.refresh),
              onTap: () {
                _showConfirmDialog(
                  context: context,
                  title: 'Reset Rencana Makan?',
                  content: 'Tindakan ini akan membuat ulang menu Anda.',
                onConfirm: () {
                  ref.read(dummyMealPlanProvider.notifier).regenerate(); // Replace with actual
                },
                );
              },
            ),
          const Divider(height: 1),

          // ── Akun ─────────────────────────────────────────────────────────────
          _buildSectionHeader('Akun'),
          ListTile(
            title: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              _showConfirmDialog(
                context: context,
                title: 'Konfirmasi Logout',
                content: 'Yakin ingin keluar dari aplikasi?',
                onConfirm: () async {
                  await ref.read(supabaseProvider).auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, int currentBudget) {
    double budget = currentBudget.toDouble();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ubah Budget Harian'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rp ${budget.toInt().toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => '.')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Slider(
                    value: budget,
                    min: 10000,
                    max: 200000,
                    divisions: 38,
                    onChanged: (val) => setState(() => budget = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final supabase = ref.read(supabaseProvider);
                    final user = supabase.auth.currentUser;
                    if (user != null) {
                      await supabase.from('preferences').update({
                        'daily_budget': budget.toInt(),
                        'updated_at': DateTime.now().toUtc().toIso8601String(),
                      }).eq('user_id', user.id);
                      ref.invalidate(preferencesProvider);
                      // ref.read(dummyMealPlanProvider.notifier).regenerate(); // optionally trigger meal plan
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
