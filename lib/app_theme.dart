import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF002045);
  static const primaryLight = Color(0xFF1A3D6B);
  static const secondary = Color(0xFF875200);
  static const accent = Color(0xFF3D7EF0);
  static const surface = Color(0xFFF9F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF0F3FF);
  static const surfaceContainer = Color(0xFFE7EEFF);
  static const surfaceContainerHigh = Color(0xFFDEE8FF);
  static const surfaceContainerHighest = Color(0xFFD9E3F9);
  static const surfaceVariant = Color(0xFFD9E3F9);
  static const onSurface = Color(0xFF121C2C);
  static const onSurfaceVariant = Color(0xFF43474E);
  static const outlineVariant = Color(0xFFC4C6CF);
  static const secondaryContainer = Color(0xFFFFB55C);
  static const onSecondaryContainer = Color(0xFF744600);
  static const primaryFixed = Color(0xFFD6E3FF);
  static const secondaryFixed = Color(0xFFFFDDBA);
  static const error = Color(0xFFBA1A1A);
  static const tertiaryContainer = Color(0xFF73000C);
  static const success = Color(0xFF1D8A4E);
  static const amber = Color(0xFFFFC107);
}

class AppGradients {
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF002045), Color(0xFF1A3D6B), Color(0xFF0D2E56)],
    stops: [0.0, 0.6, 1.0],
  );

  static const chipActiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, Color(0xFF1A3D6B)],
  );
}

class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const medium = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const strong = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  static const elevated = [
    BoxShadow(
      color: Color(0x18002045),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
