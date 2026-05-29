import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../errors/app_exception.dart';
import '../../../app_theme.dart';

class ErrorDisplay extends StatelessWidget {
  final AppException exception;
  final VoidCallback onRetry;

  const ErrorDisplay({
    super.key,
    required this.exception,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    IconData getIcon() {
      if (exception is NetworkException) return Icons.wifi_off_rounded;
      if (exception is ServerException) return Icons.dns_rounded;
      if (exception is LocationException) return Icons.location_off_rounded;
      if (exception is AuthException) return Icons.lock_outline_rounded;
      return Icons.error_outline_rounded;
    }

    return Container(
      color: AppColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(getIcon(), color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                exception.prefix,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exception.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.publicSans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  'Coba Lagi',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
