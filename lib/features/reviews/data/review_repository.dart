import 'package:supabase_flutter/supabase_flutter.dart';

class Review {
  final String id;
  final String? userId;
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      reviewerName: json['reviewer_name'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ReviewRepository {
  ReviewRepository(this._client);

  final SupabaseClient _client;

  Future<List<Review>> fetchReviews() async {
    final response = await _client
        .from('reviews')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((json) => Review.fromJson(json)).toList();
  }

  Future<void> submitReview({
    String? userId,
    required String reviewerName,
    required int rating,
    required String comment,
  }) {
    return _client.from('reviews').insert({
      'user_id': userId,
      'reviewer_name': reviewerName,
      'rating': rating,
      'comment': comment,
    });
  }
}
