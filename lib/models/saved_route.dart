import 'package:latlong2/latlong.dart';

class RouteWaypointData {
  final String name;
  final double lat;
  final double lng;
  final bool isOrigin;
  final String? placeId;

  RouteWaypointData({
    required this.name,
    required this.lat,
    required this.lng,
    this.isOrigin = false,
    this.placeId,
  });

  factory RouteWaypointData.fromJson(Map<String, dynamic> json) {
    return RouteWaypointData(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      isOrigin: json['is_origin'] as bool? ?? false,
      placeId: json['place_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      if (isOrigin) 'is_origin': isOrigin,
      if (placeId != null) 'place_id': placeId,
    };
  }

  LatLng toLatLng() => LatLng(lat, lng);
}

class SavedRoute {
  final String? id;
  final String userId;
  final String name;
  final String mode;
  final List<RouteWaypointData> waypoints;
  final int? totalDistanceM;
  final int? totalDurationS;
  final DateTime? createdAt;

  SavedRoute({
    this.id,
    required this.userId,
    required this.name,
    this.mode = 'drive',
    required this.waypoints,
    this.totalDistanceM,
    this.totalDurationS,
    this.createdAt,
  });

  factory SavedRoute.fromJson(Map<String, dynamic> json) {
    return SavedRoute(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      mode: json['mode'] as String? ?? 'drive',
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((e) => RouteWaypointData.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDistanceM: json['total_distance_m'] as int?,
      totalDurationS: json['total_duration_s'] as int?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'mode': mode,
      'waypoints': waypoints.map((e) => e.toJson()).toList(),
      if (totalDistanceM != null) 'total_distance_m': totalDistanceM,
      if (totalDurationS != null) 'total_duration_s': totalDurationS,
    };
  }
}
