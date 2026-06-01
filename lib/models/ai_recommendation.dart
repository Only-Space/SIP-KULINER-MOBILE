import 'geoapify_place.dart';

class AiRecommendation {
  final GeoapifyPlace place;
  final int rank;

  /// Alasan singkat dalam Bahasa Indonesia, maksimal 15 kata.
  final String reason;

  /// Skor relevansi dari AI, rentang 0.0 – 1.0.
  final double score;

  const AiRecommendation({
    required this.place,
    required this.rank,
    required this.reason,
    required this.score,
  });

  @override
  String toString() =>
      'AiRecommendation(rank: $rank, place: ${place.name}, score: $score)';
}
