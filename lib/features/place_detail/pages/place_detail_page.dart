import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/models/review_model.dart';
import 'package:usada_rare/features/place_detail/providers/place_detail_provider.dart';
import 'package:usada_rare/features/place_detail/providers/place_reviews_provider.dart';
import 'package:usada_rare/core/widgets/error_display.dart';
import 'package:usada_rare/core/widgets/skeleton_loader.dart';
import 'package:usada_rare/core/errors/app_exception.dart';
import 'package:usada_rare/pages/route_map_page.dart';
import 'package:usada_rare/widgets/place_detail/place_detail_header.dart';
import 'package:usada_rare/widgets/place_detail/place_detail_info.dart';
import 'package:usada_rare/widgets/place_detail/place_detail_map.dart';
import 'package:usada_rare/widgets/place_detail/place_reviews_list.dart';

class PlaceDetailPage extends ConsumerWidget {
  const PlaceDetailPage({super.key});

  void _openRouteMap(BuildContext context, double lat, double lng, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteMapPage(
          destinationLat: lat,
          destinationLng: lng,
          destinationName: name,
        ),
      ),
    );
  }

  double _avgRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fsqId = ModalRoute.of(context)?.settings.arguments as String?;
    if (fsqId == null) {
      return const Scaffold(body: Center(child: Text('ID tempat tidak ditemukan')));
    }

    final placeAsyncValue = ref.watch(placeDetailProvider(fsqId));
    final reviewsAsyncValue = ref.watch(placeReviewsProvider(fsqId));

    return placeAsyncValue.when(
      loading: () => const Scaffold(
        body: Center(
          child: SkeletonLoader(width: double.infinity, height: double.infinity),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Detail Tempat'),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: ErrorDisplay(
          exception: parseException(error),
          onRetry: () => ref.refresh(placeDetailProvider(fsqId)),
        ),
      ),
      data: (place) {
        final headerImage = place.toFoodItem().imageUrl;
        final reviews = reviewsAsyncValue.value ?? [];
        final isLoadingReviews = reviewsAsyncValue.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
          slivers: [
            PlaceDetailHeader(headerImage: headerImage),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlaceDetailInfo(
                    place: place,
                    avgRating: _avgRating(reviews),
                  ),
                  const SizedBox(height: 8),
                  PlaceDetailMap(
                    lat: place.latitude,
                    lng: place.longitude,
                    onRouteTap: () => _openRouteMap(context, place.latitude, place.longitude, place.name),
                  ),
                  const SizedBox(height: 8),
                  PlaceReviewsList(
                    placeId: place.id,
                    reviews: reviews,
                    isLoadingReviews: isLoadingReviews,
                    onReviewSubmitted: () => ref.refresh(placeReviewsProvider(fsqId)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
