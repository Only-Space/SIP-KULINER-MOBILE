import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usada_rare/core/utils/format_utils.dart';

/// Bottom sheet sukses yang muncul satu kali setelah meal plan selesai
/// di-generate (bukan dari cache).
class MealPlanSuccessSheet extends StatelessWidget {
  const MealPlanSuccessSheet({
    super.key,
    required this.estimatedCost,
    required this.savings,
  });

  final int estimatedCost;
  final int savings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // ── Animated checkmark circle ─────────────────────────────────
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF002045), Color(0xFF1A3D6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF002045).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Judul ─────────────────────────────────────────────────────
          Text(
            'Rencana Makan Siap! 🎉',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF002045),
            ),
          ),
          const SizedBox(height: 8),

          // ── Subjudul ──────────────────────────────────────────────────
          Text(
            'Menu 30 hari sudah tersusun\nsesuai selera dan budgetmu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // ── Stats row ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  value: '30',
                  label: 'Hari',
                  icon: Icons.calendar_month_outlined,
                ),
                _VerticalDivider(),
                _StatItem(
                  value: 'Rp ${estimatedCost.toFormattedString()}',
                  label: 'Estimasi',
                  icon: Icons.receipt_long_outlined,
                ),
                _VerticalDivider(),
                _StatItem(
                  value: savings >= 0
                      ? 'Rp ${savings.toFormattedString()}'
                      : '-Rp ${savings.abs().toFormattedString()}',
                  label: savings >= 0 ? 'Hemat' : 'Lebih',
                  icon: Icons.savings_outlined,
                  valueColor: savings >= 0
                      ? Colors.green.shade600
                      : Colors.red.shade500,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Tombol CTA ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text(
                'Lihat Rencana Makan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002045),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Tombol secondary ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.valueColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFFB55C)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF002045),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.grey.shade200,
    );
  }
}
