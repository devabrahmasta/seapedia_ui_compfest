import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_search_bar.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_card.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_dummy.dart';
import 'package:seapedia_ui_compfest/features/reviews/application/review_provider.dart';

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
            onPressed: () => context.push('/products?focus=true'),
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
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: AppSearchBar(
                readOnly: true,
                onTap: () => context.push('/products?focus=true'),
              ),
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
                  GestureDetector(
                    onTap: () => context.push('/products'),
                    child: Text(
                      'Lihat semua',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
            const SizedBox(height: 16),
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: AppButton(
                label: 'Tulis Review',
                onPressed: () => context.push('/write-review'),
              ),
            ),
            const SizedBox(height: 40),
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
          return ProductCard(product: dummyProducts[index]);
        },
      ),
    );
  }
}

class _ReviewCarousel extends ConsumerWidget {
  const _ReviewCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewListProvider);

    return reviewsAsync.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Gagal memuat review',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return SizedBox(
            height: 140,
            child: Center(
              child: Text(
                'Belum ada review, jadilah yang pertama!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.separated(
            padding: AppSpacing.screenPaddingHorizontal,
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final review = reviews[index];

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
      },
    );
  }
}
