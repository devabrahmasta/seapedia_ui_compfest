import 'package:flutter/material.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textTertiary,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surface,
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textTertiary,
              size: 32,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surface,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}