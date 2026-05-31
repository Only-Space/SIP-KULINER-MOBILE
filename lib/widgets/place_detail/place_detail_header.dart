import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/core/widgets/cached_image.dart';

class PlaceDetailHeader extends StatelessWidget {
  final String headerImage;

  const PlaceDetailHeader({
    super.key,
    required this.headerImage,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(
              imageUrl: headerImage,
              fit: BoxFit.cover,
            ),
            // Gradient overlay agar teks di bawah terbaca
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
