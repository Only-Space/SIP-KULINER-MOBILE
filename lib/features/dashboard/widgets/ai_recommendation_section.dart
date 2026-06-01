import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_theme.dart';
import '../../../data/providers/supabase_provider.dart';
import '../providers/ai_recommendation_provider.dart';
import 'ai_recommendation_card.dart';

class AiRecommendationSection extends ConsumerWidget {
  const AiRecommendationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guard: hanya tampilkan jika user sudah login
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final aiAsync = ref.watch(aiRecommendationProvider);

    return aiAsync.when(
      loading: () => _buildShimmerRow(),
      error: (_, __) => const SizedBox.shrink(),
      data: (recommendations) {
        if (recommendations.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rekomendasi untuk Kamu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  _RefreshButton(
                    onRefresh: () =>
                        ref.read(aiRecommendationProvider.notifier).refresh(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Horizontal list ───────────────────────────────────────
            SizedBox(
              height: 168, // card 160 + slight vertical breathing room
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recommendations.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AiRecommendationCard(
                    recommendation: recommendations[index],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Tiga shimmer card abu-abu sebagai placeholder saat loading.
  Widget _buildShimmerRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 200,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 3,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 200,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Refresh button — switches to spinner while provider is loading
// ---------------------------------------------------------------------------

class _RefreshButton extends ConsumerWidget {
  final VoidCallback onRefresh;
  const _RefreshButton({required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(aiRecommendationProvider).isLoading;

    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.refresh_rounded, size: 20),
      color: AppColors.accent,
      visualDensity: VisualDensity.compact,
      tooltip: 'Perbarui rekomendasi',
      onPressed: onRefresh,
    );
  }
}
