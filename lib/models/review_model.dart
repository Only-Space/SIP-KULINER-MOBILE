class ReviewModel {
  final String id;
  final String userId;
  final String placeId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatarUrl;
  final List<String> photos;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
    this.photos = const [],
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Supabase JOIN response handling
    final profile = json['profiles'] as Map<String, dynamic>?;
    final photosList = json['review_photos'] as List<dynamic>? ?? [];
    
    return ReviewModel(
      id: json['id'],
      userId: json['user_id'],
      placeId: json['place_id'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['name'] ?? 'Pengguna Anonim',
      userAvatarUrl: profile?['avatar_url'],
      photos: photosList.map((p) => p['storage_url'] as String).toList(),
    );
  }
}
