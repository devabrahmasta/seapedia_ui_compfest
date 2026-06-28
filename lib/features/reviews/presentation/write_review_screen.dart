import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/reviews/application/review_provider.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty || comment.isEmpty || _rating == 0) {
      setState(() => _error = 'Nama, rating, dan komentar wajib diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final session = ref.read(authProvider).value;
      final repository = ref.read(reviewRepositoryProvider);
      await repository.submitReview(
        userId: session?.user.id,
        reviewerName: name,
        rating: _rating,
        comment: comment,
      );
      ref.invalidate(reviewListProvider);
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _error = 'Gagal mengirim review, coba lagi');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Review')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingHorizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Bagaimana pengalamanmu menggunakan SEAPEDIA?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starValue),
                    icon: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF5A623),
                      size: 32,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Nama',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Komentar',
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: _isSubmitting ? 'Mengirim...' : 'Kirim Review',
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}