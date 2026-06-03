import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/core/widgets/confirm_dialog.dart';
import 'package:usada_rare/features/meal_plan/providers/meal_plan_provider.dart';
import 'package:usada_rare/core/utils/format_utils.dart';
import 'package:usada_rare/models/meal_plan.dart';
import 'package:usada_rare/features/meal_plan/widgets/meal_plan_summary_card.dart';
import 'package:usada_rare/features/meal_plan/widgets/meal_plan_loading_screen.dart';
import 'package:usada_rare/features/meal_plan/widgets/meal_plan_success_sheet.dart';

class MealPlanPage extends ConsumerStatefulWidget {
  const MealPlanPage({super.key});

  @override
  ConsumerState<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends ConsumerState<MealPlanPage> {
  /// Flag agar success sheet hanya tampil sekali per sesi generate.
  bool _hasShownSuccess = false;

  @override
  Widget build(BuildContext context) {
    final mealPlanState = ref.watch(mealPlanProvider);

    // ── Deteksi transisi loading → data untuk fresh generate ──────────
    ref.listen<AsyncValue<MealPlan?>>(mealPlanProvider, (previous, next) {
      if (previous?.isLoading == true &&
          next.hasValue &&
          next.value != null &&
          !_hasShownSuccess) {
        // generatedAt dalam 1 menit terakhir → ini fresh generate, bukan cache
        final isFromCache = next.value!.generatedAt
            .isBefore(DateTime.now().subtract(const Duration(minutes: 1)));

        if (!isFromCache) {
          _hasShownSuccess = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withValues(alpha: 0.5),
              isScrollControlled: true,
              builder: (_) => MealPlanSuccessSheet(
                estimatedCost: next.value!.totalEstimatedCost,
                savings: next.value!.estimatedSavings,
              ),
            );
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rencana Makan'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      backgroundColor: AppColors.surface,
      body: mealPlanState.when(
        data: (plan) {
          if (plan == null) {
            return _buildEmptyState(context, ref);
          }

          final dailyBudget = plan.totalBudget ~/ 30;

          return Column(
            children: [
              const SizedBox(height: 16),
              MealPlanSummaryCard(
                totalBudget: plan.totalBudget,
                totalCost: plan.totalEstimatedCost,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  itemCount: plan.days.length,
                  itemBuilder: (context, index) {
                    final day = plan.days[index];
                    final isOverBudget  = day.totalDailyCost > dailyBudget;
                    final isNearBudget  = !isOverBudget &&
                        day.totalDailyCost > (dailyBudget * 0.9).toInt();

                    final totalColor = isOverBudget
                        ? Colors.red.shade600
                        : isNearBudget
                            ? Colors.orange.shade600
                            : Colors.green.shade600;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hari ${day.day}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isOverBudget) ...
                                      [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Colors.red.shade400, size: 14),
                                        const SizedBox(width: 4),
                                      ],
                                    Text(
                                      'Rp ${day.totalDailyCost.toFormattedString()}',
                                      style: GoogleFonts.publicSans(
                                        color: totalColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: AppColors.surfaceContainerHigh),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildMealSection(context, 'Sarapan', Icons.wb_sunny_outlined, AppColors.amber, day.breakfast),
                                const Divider(height: 24, thickness: 1, color: AppColors.surfaceContainerHigh),
                                _buildMealSection(context, 'Makan Siang', Icons.wb_cloudy_outlined, Colors.lightBlue, day.lunch),
                                const Divider(height: 24, thickness: 1, color: AppColors.surfaceContainerHigh),
                                _buildMealSection(context, 'Makan Malam', Icons.nights_stay_outlined, AppColors.primary, day.dinner),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => _buildLoadingState(ref),
        error: (err, stack) => _buildErrorState(context, ref, err),
      ),
      floatingActionButton: mealPlanState.hasValue && mealPlanState.value != null
          ? FloatingActionButton(
              onPressed: () => showConfirmDialog(
                context,
                title: 'Buat Ulang Menu?',
                message: 'Menu 30 hari akan dibuat ulang.\nProses ini membutuhkan beberapa saat.',
                confirmLabel: 'Buat Ulang',
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFFFFB55C),
                confirmColor: const Color(0xFF002045),
                onConfirm: () {
                  ref.read(mealPlanProvider.notifier).clearCacheAndRegenerate();
                },
              ),
              backgroundColor: AppColors.primary,
              tooltip: 'Buat ulang menu',
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.soup_kitchen_outlined, size: 64, color: AppColors.amber),
          const SizedBox(height: 16),
          Text(
            'Belum ada rencana makan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol refresh untuk mulai',
            style: GoogleFonts.publicSans(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(mealPlanProvider.notifier).regenerate(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buat Rencana Makan'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(WidgetRef ref) {
    return const MealPlanLoadingScreen();
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.soup_kitchen_outlined, size: 64, color: AppColors.amber),
          const SizedBox(height: 16),
          Text(
            'Belum ada rencana makan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol refresh untuk mulai',
            style: GoogleFonts.publicSans(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(mealPlanProvider.notifier).regenerate(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buat Rencana Makan'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Error Detail: ${err.toString()}',
              textAlign: TextAlign.center,
              style: GoogleFonts.publicSans(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, String title, IconData icon, Color iconColor, MealItem item) {
    return InkWell(
      onTap: item.placeId != null
          ? () {
              Navigator.pushNamed(context, '/detail', arguments: item.placeId);
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.foodName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.warungName,
                    style: GoogleFonts.publicSans(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    item.warungArea,
                    style: GoogleFonts.publicSans(
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Rp ${item.price.toFormattedString()}',
              style: GoogleFonts.publicSans(
                color: AppColors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
