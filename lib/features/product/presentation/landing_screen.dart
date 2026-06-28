import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_dummy.dart';
import 'package:seapedia_ui_compfest/features/reviews/data/review_dummy.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SEAPEDIA',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: _SearchBarPlaceholder(),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: _PromoBanner(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Text(
                'Kategori',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            const _CategoryList(),
            const SizedBox(height: 24),
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produk populer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Lihat semua',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _PopularProductsGrid(),
            const SizedBox(height: 32),

            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Text(
                'Review Aplikasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            const _ReviewCarousel(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SearchBarPlaceholder extends StatelessWidget {
  const _SearchBarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Cari produk atau toko',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'banner promo',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.set_meal_outlined, 'label': 'Ikan'},
      {'icon': Icons.eco_outlined, 'label': 'Rumput'},
      {'icon': Icons.kitchen_outlined, 'label': 'Olahan'},
      {'icon': Icons.grid_view_outlined, 'label': 'Lainnya'},
    ];

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((cat) {
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  cat['icon'] as IconData,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat['label'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PopularProductsGrid extends StatelessWidget {
  const _PopularProductsGrid();

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'id_ID');

    return Padding(
      padding: AppSpacing.screenPaddingHorizontal,
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: dummyProducts.length,
        itemBuilder: (context, index) {
          final product = dummyProducts[index];

          return AppCard(
            padding: EdgeInsets.zero,
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar tetap kotak presisi (1:1)
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.storeName,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rp${currencyFormat.format(product.price)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReviewCarousel extends StatelessWidget {
  const _ReviewCarousel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: AppSpacing.screenPaddingHorizontal,
        scrollDirection: Axis.horizontal,
        itemCount: dummyReviews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final review = dummyReviews[index];

          return SizedBox(
            width: 280,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          review.reviewerName[0],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          review.reviewerName,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 16,
                            color: i < review.rating
                                ? const Color(0xFFF5A623)
                                : AppColors.border,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review.comment,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
