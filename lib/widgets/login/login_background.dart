import 'package:flutter/material.dart';
import '../../app_theme.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
      ],
    );
  }
}
