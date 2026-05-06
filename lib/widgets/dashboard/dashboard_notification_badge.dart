import 'package:flutter/material.dart';
import '../../app_theme.dart';

class DashboardNotificationBadge extends StatelessWidget {
  const DashboardNotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
          onPressed: () {},
        ),
        Positioned(
          top: 12, right: 12,
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}
