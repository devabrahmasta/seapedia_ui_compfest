import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_image.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';
import 'package:seapedia_ui_compfest/features/store/data/store_repository.dart';

class StorePublicScreen extends ConsumerWidget {
  final String storeId;

  const StorePublicScreen({required this.storeId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(getStoreByIdProvider(storeId));
    final productsAsync = ref.watch(getProductsByStoreIdProvider(storeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Gagal memuat toko')),
        data: (store) {
          if (store == null) {
            return const Center(child: Text('Toko tidak ditemukan'));
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StoreHeader(store: store),
                Padding(
                  padding: AppSpacing.screenPaddingHorizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Produk',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      productsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) =>
                            const Text('Gagal memuat produk'),
                        data: (products) {
                          if (products.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Belum ada produk di toko ini'),
                              ),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.62,
                                ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return _StoreProductTile(
                                product: products[index],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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

class _StoreHeader extends StatelessWidget {
  final Store store;

  const _StoreHeader({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_outlined, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            store.storeName,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (store.address != null && store.address!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    store.address!,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            store.description ?? 'Toko',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Color(0xFFF5A623)),
              const SizedBox(width: 4),
              Text('4.9 rating', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(width: 12),
              Text('320 produk', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreProductTile extends StatelessWidget {
  final Product product;

  const _StoreProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'id_ID');

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/product/${product.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: ProductImage(
              imageUrl: product.imageUrl ?? '',
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
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
  }
}
