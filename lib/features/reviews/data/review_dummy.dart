class AppReview {
  final String id;
  final String reviewerName;
  final int rating;
  final String comment;

  const AppReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });
}

const dummyReviews = [
  AppReview(
    id: '1',
    reviewerName: 'Budi Santoso',
    rating: 5,
    comment: 'Marketplace yang sangat responsif dan desainnya clean!',
  ),
  AppReview(
    id: '2',
    reviewerName: 'Siti Aminah',
    rating: 4,
    comment: 'Mudah digunakan untuk pemula, navigasinya sangat jelas.',
  ),
  AppReview(
    id: '3',
    reviewerName: 'Andi Wijaya',
    rating: 5,
    comment: 'Checkout sangat cepat dan pilihan pengirimannya lengkap.',
  ),
];