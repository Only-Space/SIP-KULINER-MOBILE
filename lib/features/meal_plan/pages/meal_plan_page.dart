import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:usada_rare/core/utils/format_utils.dart';
import 'package:usada_rare/models/meal_plan.dart';

class MealPlanPage extends ConsumerWidget {
  const MealPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanState = ref.watch(mealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Makan 30 Hari'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.surface,
      body: mealPlanState.when(
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('Tidak ada rencana makan.'));
          }

          final progress = plan.totalBudget > 0 ? plan.totalEstimatedCost / plan.totalBudget : 0.0;
          final dailyBudget = plan.totalBudget ~/ 30;

          return Column(
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                color: const Color(0xFFD6E3FF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Keuangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001B3E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total budget:', style: GoogleFonts.publicSans(color: const Color(0xFF001B3E))),
                        Text('Rp ${plan.totalBudget.toFormattedString()}', style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: const Color(0xFF001B3E))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimasi pengeluaran:', style: GoogleFonts.publicSans(color: const Color(0xFF001B3E))),
                        Text('Rp ${plan.totalEstimatedCost.toFormattedString()}', style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: const Color(0xFF001B3E))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimasi hemat:', style: GoogleFonts.publicSans(color: const Color(0xFF001B3E))),
                        Text('Rp ${plan.estimatedSavings.toFormattedString()}', style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: Colors.green[700])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(progress > 1.0 ? Colors.red : AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plan.days.length,
                  itemBuilder: (context, index) {
                    final day = plan.days[index];
                    final isOverBudget = day.totalDailyCost > dailyBudget;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hari ke-${day.day}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOverBudget ? Colors.red[50] : Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Rp ${day.totalDailyCost.toFormattedString()}',
                                    style: GoogleFonts.publicSans(
                                      color: isOverBudget ? Colors.red[700] : Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildMealSection(context, 'Sarapan', Icons.wb_sunny, day.breakfast),
                            const Divider(height: 24, thickness: 0.5),
                            _buildMealSection(context, 'Makan Siang', Icons.wb_cloudy, day.lunch),
                            const Divider(height: 24, thickness: 0.5),
                            _buildMealSection(context, 'Makan Malam', Icons.nights_stay, day.dinner),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () {
          final loadingMsg = ref.watch(mealPlanLoadingMessageProvider);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  loadingMsg,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan saat menyusun menu',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.read(mealPlanProvider.notifier).regenerate(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: mealPlanState.hasValue && mealPlanState.value != null
          ? FloatingActionButton(
              onPressed: () {
                _showRegenerateDialog(context, ref);
              },
              backgroundColor: AppColors.primary,
              tooltip: 'Buat ulang menu',
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMealSection(BuildContext context, String title, IconData icon, MealItem item) {
    return InkWell(
      onTap: item.placeId != null
          ? () {
              Navigator.pushNamed(context, '/detail', arguments: item.placeId);
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: AppColors.primary.withValues(alpha: 0.8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.foodName,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rp ${item.price.toFormattedString()}',
                        style: GoogleFonts.publicSans(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.warungName} • ${item.warungArea}',
                    style: GoogleFonts.publicSans(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  if (item.tips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue[300]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.tips,
                            style: GoogleFonts.publicSans(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (item.placeId != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'Lihat detail & rute',
                child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat ulang menu?'),
        content: const Text('Token AI akan digunakan untuk menyusun ulang rencana makan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(mealPlanProvider.notifier).regenerate();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Ya, Buat Ulang'),
          ),
        ],
      ),
    );
  }
}
