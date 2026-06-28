import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_image.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_dummy.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedThumbnail = 0;
  bool _showDescription = true;

  String _formatSoldCount(int count) {
    if (count < 1000) return '$count terjual';
    final thousands = count / 1000;
    final formatted = thousands.toStringAsFixed(1).replaceAll('.', ',');
    return '${formatted}rb terjual';
  }

  @override
  Widget build(BuildContext context) {
    final product = dummyProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => dummyProducts.first,
    );
    final currencyFormat = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: ProductImage(imageUrl: product.imageUrl),
            ),
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _ThumbnailRow(
                    imageUrl: product.imageUrl,
                    selectedIndex: _selectedThumbnail,
                    onSelect: (index) =>
                        setState(() => _selectedThumbnail = index),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFF5A623),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount} ulasan)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 6),
                      Text('·', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 6),
                      Text(
                        _formatSoldCount(product.soldCount),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailTabs(
                    showDescription: _showDescription,
                    onTapDescription: () =>
                        setState(() => _showDescription = true),
                    onTapReviews: () =>
                        setState(() => _showDescription = false),
                  ),
                  const SizedBox(height: 16),
                  if (_showDescription)
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Text(
                      'Belum ada ulasan untuk produk ini.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 76,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Rp${currencyFormat.format(product.price)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(label: 'Keranjang', onPressed: () {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbnailRow extends StatelessWidget {
  final String imageUrl;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ThumbnailRow({
    required this.imageUrl,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isSelected = index == selectedIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ProductImage(
                imageUrl: imageUrl,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  final bool showDescription;
  final VoidCallback onTapDescription;
  final VoidCallback onTapReviews;

  const _DetailTabs({
    required this.showDescription,
    required this.onTapDescription,
    required this.onTapReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: 'Deskripsi',
          isActive: showDescription,
          onTap: onTapDescription,
        ),
        const SizedBox(width: 24),
        _TabItem(
          label: 'Ulasan',
          isActive: !showDescription,
          onTap: onTapReviews,
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 60,
            color: isActive ? AppColors.textPrimary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
