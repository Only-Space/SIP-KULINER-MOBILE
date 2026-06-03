import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/core/widgets/confirm_dialog.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';
import 'package:usada_rare/features/profile/widgets/preferences_edit_sheet.dart';
import 'package:usada_rare/features/meal_plan/providers/meal_plan_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);
    final mealPlanAsync = ref.watch(mealPlanProvider);
    final isMealPlanGenerated = mealPlanAsync.hasValue && mealPlanAsync.value != null;
    final supabase = ref.watch(supabaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF002045),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER PROFILE CARD ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF002045), Color(0xFF1A3D6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFFFB55C),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supabase.auth.currentUser?.email ?? 'Pengguna',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SIPKULINER Member',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── PREFERENSI MAKAN SECTION ─────────────────────────────────────────
            _buildSectionLabel('Preferensi Makan'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    title: 'Ubah preferensi makanan',
                    subtitle: 'Makanan favorit, pantangan, budget harian',
                    icon: Icons.restaurant_menu,
                    iconColor: const Color(0xFFFFB55C),
                    iconBgColor: const Color(0xFFFFB55C).withValues(alpha: 0.15),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: () {
                      prefsAsync.whenData((prefs) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent, // Untuk modal rounded
                          builder: (context) => PreferencesEditSheet(initialPrefs: prefs),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),

            // ── RENCANA MAKAN SECTION ────────────────────────────────────────────
            _buildSectionLabel('Rencana Makan'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    title: 'Budget bulanan',
                    subtitleWidget: prefsAsync.when(
                      data: (prefs) {
                        final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                        return Text(
                          '${formatter.format(prefs.dailyBudget)} / hari',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        );
                      },
                      loading: () => Text('Memuat...', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      error: (_, __) => Text('Gagal memuat', style: TextStyle(color: Colors.red.shade400, fontSize: 12)),
                    ),
                    icon: Icons.wallet,
                    iconColor: const Color(0xFFFFB55C),
                    iconBgColor: const Color(0xFFFFB55C).withValues(alpha: 0.15),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: () {
                      prefsAsync.whenData((prefs) {
                        _showBudgetDialog(context, ref, prefs.dailyBudget);
                      });
                    },
                  ),
                  if (isMealPlanGenerated) ...[
                    Divider(height: 1, indent: 56, endIndent: 16, color: Colors.grey.shade100),
                    _buildListTile(
                      title: 'Reset rencana makan',
                      subtitle: 'Buat ulang menu 30 hari',
                      icon: Icons.refresh,
                      iconColor: const Color(0xFFFFB55C),
                      iconBgColor: const Color(0xFFFFB55C).withValues(alpha: 0.15),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      onTap: () => showConfirmDialog(
                        context,
                        title: 'Buat Ulang Menu?',
                        message: 'Rencana makan 30 hari akan dibuat ulang\nberdasarkan preferensi terbaru kamu.',
                        confirmLabel: 'Buat Ulang',
                        icon: Icons.refresh_rounded,
                        iconColor: const Color(0xFFFFB55C),
                        confirmColor: const Color(0xFF002045),
                        onConfirm: () {
                          ref.read(mealPlanProvider.notifier).clearCacheAndRegenerate();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── AKUN SECTION ─────────────────────────────────────────────────────
            _buildSectionLabel('Akun'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    title: 'Keluar',
                    titleColor: Colors.red.shade600,
                    subtitle: null,
                    icon: Icons.logout,
                    iconColor: Colors.red.shade400,
                    iconBgColor: Colors.red.shade50,
                    trailing: null,
                    onTap: () => showConfirmDialog(
                      context,
                      title: 'Keluar dari Akun?',
                      message: 'Kamu akan keluar dari akun SIPKULINER.\nSampai jumpa lagi!',
                      confirmLabel: 'Keluar',
                      cancelLabel: 'Batal',
                      icon: Icons.logout_rounded,
                      iconColor: Colors.red.shade400,
                      confirmColor: Colors.red.shade500,
                      onConfirm: () async {
                        await ref.read(supabaseProvider).auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF002045),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Widget? trailing,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? const Color(0xFF002045),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitleWidget ?? (subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            )
          : null),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, int currentBudget) {
    double budget = currentBudget.toDouble();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ubah Budget Harian', style: TextStyle(color: Color(0xFF002045), fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatter.format(budget),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFFFB55C)),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: budget,
                    min: 10000,
                    max: 200000,
                    divisions: 38,
                    activeColor: const Color(0xFFFFB55C),
                    inactiveColor: const Color(0xFFFFB55C).withValues(alpha: 0.3),
                    onChanged: (val) => setState(() => budget = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
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
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002045),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
