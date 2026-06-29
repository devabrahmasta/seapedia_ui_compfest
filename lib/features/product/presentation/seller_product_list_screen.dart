import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_image.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';

class SellerProductListScreen extends ConsumerWidget {
  const SellerProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
            onPressed: () => context.push('/seller/products/new'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Gagal memuat produk')),
        data: (products) {
          if (products.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: AppSpacing.screenPaddingHorizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              return _ProductRow(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingHorizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Belum ada produk', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Tambahkan produk pertamamu untuk mulai berjualan',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Tambah Produk',
              onPressed: () => context.push('/seller/products/new'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends ConsumerWidget {
  final Product product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat('#,###', 'id_ID');
    final isOutOfStock = product.stock == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: ProductImage(imageUrl: product.imageUrl ?? ''),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  'Rp${currencyFormat.format(product.price)}',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                Text(
                  isOutOfStock ? 'Stok 0 \u00b7 habis' : 'Stok ${product.stock}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOutOfStock ? AppColors.danger : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/seller/products/${product.id}/edit', extra: product);
              } else if (value == 'delete') {
                _confirmDelete(context, ref, product);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('${product.name} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(productRepositoryProvider);
      await repository.deleteProduct(product.id);
      ref.invalidate(myProductsProvider);
    }
  }
}