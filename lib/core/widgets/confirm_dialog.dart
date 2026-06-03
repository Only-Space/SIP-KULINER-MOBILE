import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom confirm dialog yang konsisten dengan tema navy-amber aplikasi.
///
/// Gunakan helper [showConfirmDialog] untuk menampilkannya:
/// ```dart
/// final confirmed = await showConfirmDialog(
///   context,
///   title: 'Buat Ulang Menu?',
///   message: 'Rencana makan akan dibuat ulang.',
///   confirmLabel: 'Buat Ulang',
/// );
/// if (confirmed) { /* lakukan aksi */ }
/// ```
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Batal',
    this.icon = Icons.help_outline_rounded,
    this.iconColor = const Color(0xFFFFB55C),
    this.confirmColor = const Color(0xFF002045),
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final IconData icon;
  final Color iconColor;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon circle ─────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),

            // ── Title ───────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF002045),
              ),
            ),
            const SizedBox(height: 8),

            // ── Message ─────────────────────────────────────────
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── Buttons ─────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF002045),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper untuk menampilkan [ConfirmDialog].
///
/// Mengembalikan `true` jika user menekan tombol konfirmasi,
/// `false` jika menekan Batal atau menutup dialog.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required VoidCallback onConfirm,
  String cancelLabel = 'Batal',
  IconData icon = Icons.help_outline_rounded,
  Color iconColor = const Color(0xFFFFB55C),
  Color confirmColor = const Color(0xFF002045),
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      iconColor: iconColor,
      confirmColor: confirmColor,
      onConfirm: onConfirm,
    ),
  );
  return result ?? false;
}
