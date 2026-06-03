import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usada_rare/app_theme.dart';

class _MealPlanStep {
  final IconData icon;
  final String label;
  final String sublabel;

  const _MealPlanStep({
    required this.icon,
    required this.label,
    required this.sublabel,
  });
}

class MealPlanLoadingScreen extends StatefulWidget {
  const MealPlanLoadingScreen({super.key});

  @override
  State<MealPlanLoadingScreen> createState() => _MealPlanLoadingScreenState();
}

class _MealPlanLoadingScreenState extends State<MealPlanLoadingScreen>
    with SingleTickerProviderStateMixin {
  // ── Steps ────────────────────────────────────────────────────────────────
  final List<_MealPlanStep> _steps = const [
    _MealPlanStep(
      icon: Icons.location_on_outlined,
      label: 'Mendeteksi lokasi kamu',
      sublabel: 'Mencari warung di sekitarmu...',
    ),
    _MealPlanStep(
      icon: Icons.store_outlined,
      label: 'Mengumpulkan data warung',
      sublabel: 'Ditemukan tempat makan terdekat...',
    ),
    _MealPlanStep(
      icon: Icons.psychology_outlined,
      label: 'AI menyusun menu',
      sublabel: 'Menyesuaikan dengan preferensi & budgetmu...',
    ),
    _MealPlanStep(
      icon: Icons.check_circle_outline,
      label: 'Rencana makan siap!',
      sublabel: 'Menyimpan ke akun kamu...',
    ),
  ];

  // ── Quotes ────────────────────────────────────────────────────────────────
  final List<String> _quotes = const [
    '🍽️ Menu bervariasi agar kamu tidak bosan',
    '💰 Disesuaikan dengan budgetmu',
    '📍 Warung nyata di sekitar lokasimu',
    '✨ Dipilihkan AI khusus untukmu',
  ];

  int _currentStep = 0;
  int _currentQuote = 0;

  // Step advance timings (cumulative seconds)
  static const _stepTimings = [3, 8, 15]; // advance at 3s, 8s, 15s

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();

    // Pulse animation for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Step timers
    for (int i = 0; i < _stepTimings.length; i++) {
      final targetStep = i + 1;
      _timers.add(Timer(Duration(seconds: _stepTimings[i]), () {
        if (mounted) {
          setState(() => _currentStep = targetStep);
        }
      }));
    }

    // Quote rotator — every 3 seconds
    _timers.add(Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() => _currentQuote = (_currentQuote + 1) % _quotes.length);
      }
    }));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── 1. Animated Icon ────────────────────────────────────
                _buildPulsingIcon(),
                const SizedBox(height: 8),
                Text(
                  'Menyiapkan rencana makanmu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mohon tunggu sebentar...',
                  style: GoogleFonts.publicSans(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── 2. Step Progress ─────────────────────────────────────
                _buildStepList(),
                const SizedBox(height: 24),

                // ── 3. Progress Bar ──────────────────────────────────────
                _buildProgressBar(),
                const SizedBox(height: 24),

                // ── 4. Motivational Quote ────────────────────────────────
                _buildQuote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Pulsing icon ─────────────────────────────────────────────────────────
  Widget _buildPulsingIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFB55C).withOpacity(0.12),
        ),
        child: const Icon(
          Icons.restaurant_menu_outlined,
          size: 72,
          color: Color(0xFFFFB55C),
        ),
      ),
    );
  }

  // ── Step list ────────────────────────────────────────────────────────────
  Widget _buildStepList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            return Padding(
              padding: const EdgeInsets.only(left: 17),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 2,
                    height: 20,
                    color: stepIndex < _currentStep
                        ? AppColors.primary
                        : Colors.grey.shade200,
                  ),
                ],
              ),
            );
          }

          final stepIndex = index ~/ 2;
          return _buildStepRow(stepIndex);
        }),
      ),
    );
  }

  Widget _buildStepRow(int index) {
    final step = _steps[index];
    final isDone = index < _currentStep;
    final isActive = index == _currentStep;
    final isPending = index > _currentStep;

    Widget iconContainer;
    if (isDone) {
      iconContainer = _iconCircle(
        icon: step.icon,
        bg: AppColors.primary,
        iconColor: Colors.white,
      );
    } else if (isActive) {
      iconContainer = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFFB55C), Color(0xFFFF9800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(step.icon, color: Colors.white, size: 18),
      );
    } else {
      iconContainer = _iconCircle(
        icon: step.icon,
        bg: Colors.grey.shade200,
        iconColor: Colors.grey.shade400,
      );
    }

    Widget trailing;
    if (isDone) {
      trailing = const Icon(Icons.check, color: Colors.green, size: 16);
    } else if (isActive) {
      trailing = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFFFB55C),
        ),
      );
    } else {
      trailing = const SizedBox(width: 16);
    }

    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconContainer,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isPending
                      ? Colors.grey.shade400
                      : AppColors.primary,
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 2),
                Text(
                  step.sublabel,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );

    if (isActive) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(1.02),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB55C).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: rowContent,
      );
    }

    return Opacity(
      opacity: isDone ? 0.6 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: rowContent,
      ),
    );
  }

  Widget _iconCircle({
    required IconData icon,
    required Color bg,
    required Color iconColor,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  // ── Progress bar ─────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _steps.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB55C)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Langkah ${_currentStep + 1} dari ${_steps.length}',
          textAlign: TextAlign.center,
          style: GoogleFonts.publicSans(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ── Quote ─────────────────────────────────────────────────────────────────
  Widget _buildQuote() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Text(
        _quotes[_currentQuote],
        key: ValueKey<int>(_currentQuote),
        textAlign: TextAlign.center,
        style: GoogleFonts.publicSans(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: AppColors.primary.withOpacity(0.6),
        ),
      ),
    );
  }
}
