import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/geoapify_place.dart';
import '../../../../data/services/geoapify_service.dart';
import '../../../../core/errors/app_exception.dart';

final placeDetailProvider = FutureProvider.family<GeoapifyPlace, String>((ref, placeId) async {
  final geoapifyService = GeoapifyService();
  try {
    return await geoapifyService.getPlaceDetails(placeId);
  } catch (e) {
    throw parseException(e);
  }
});
