import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/reviews/data/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(Supabase.instance.client);
});

final reviewListProvider = FutureProvider<List<Review>>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.fetchReviews();
});