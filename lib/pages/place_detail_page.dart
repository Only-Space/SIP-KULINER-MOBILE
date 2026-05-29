import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../data/services/geoapify_service.dart';
import '../models/geoapify_place.dart';
import '../models/review_model.dart';
import '../data/services/review_service.dart';
import 'route_map_page.dart';
import '../widgets/place_detail/place_detail_header.dart';
import '../widgets/place_detail/place_detail_info.dart';
import '../widgets/place_detail/place_detail_map.dart';
import '../widgets/place_detail/place_reviews_list.dart';

class PlaceDetailPage extends StatefulWidget {
  const PlaceDetailPage({super.key});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  final ReviewService _reviewService = ReviewService();
  bool _isLoading = true;
  String? _errorMessage;
  GeoapifyPlace? _placeDetails;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fsqId = ModalRoute.of(context)?.settings.arguments as String?;
    if (fsqId != null && _isLoading && _placeDetails == null) {
      _fetchDetails(fsqId);
      _fetchReviews(fsqId);
    }
  }

  Future<void> _fetchReviews(String placeId) async {
    setState(() => _isLoadingReviews = true);
    try {
      final reviews = await _reviewService.getReviews(placeId);
      if (mounted) setState(() => _reviews = reviews);
    } catch (e) {
      debugPrint('Gagal memuat ulasan: $e');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _fetchDetails(String fsqId) async {
    try {
      final details = await _geoapifyService.getPlaceDetails(fsqId);
      if (mounted) {
        setState(() {
          _placeDetails = details;
          _isLoading = false;
        });
        if (details.id != fsqId) _fetchReviews(details.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openRouteMap(double lat, double lng, String name) {
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

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Tempat'),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Gagal memuat: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final place = _placeDetails!;
    final headerImage = place.toFoodItem().imageUrl;

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
                    avgRating: _avgRating,
                  ),
                  const SizedBox(height: 8),
                  PlaceDetailMap(
                    lat: place.latitude,
                    lng: place.longitude,
                    onRouteTap: () => _openRouteMap(place.latitude, place.longitude, place.name),
                  ),
                  const SizedBox(height: 8),
                  PlaceReviewsList(
                    placeId: place.id,
                    reviews: _reviews,
                    isLoadingReviews: _isLoadingReviews,
                    onReviewSubmitted: () => _fetchReviews(place.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
