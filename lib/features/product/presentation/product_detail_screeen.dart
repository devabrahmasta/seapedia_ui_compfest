import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/cart/application/cart_provider.dart';
import 'package:seapedia_ui_compfest/features/cart/data/cart_repository.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
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
    final currencyFormat = NumberFormat('#,###', 'id_ID');
    final productAsync = ref.watch(getProductByIdProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          _CartIconButton(),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Gagal memuat produk')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Produk tidak ditemukan'));
          }

          return SingleChildScrollView(
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
                      // Rating & ulasan di-hardcode sementara karena belum ada di model asli
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFF5A623),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '0.0', // rating dummy
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(0 ulasan)', // ulasan dummy
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 6),
                          Text('·', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 6),
                          Text(
                            _formatSoldCount(0), // terjual dummy
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Consumer(
                        builder: (context, ref, child) {
                          final storeAsync = ref.watch(getStoreByIdProvider(product.storeId));
                          return GestureDetector(
                            onTap: () => context.push('/store/${product.storeId}'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.store, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        storeAsync.when(
                                          data: (store) => Text(
                                            store?.storeName ?? product.storeName,
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                          loading: () => Text(
                                            'Memuat toko...',
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                          error: (_, _) => Text(
                                            product.storeName,
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lihat Toko',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          );
                        },
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
          );
        },
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) {
          if (product == null) return const SizedBox.shrink();
          return SafeArea(
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
                      child: _ProductCartAction(product: product),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _ProductCartAction extends ConsumerWidget {
  final dynamic product;

  const _ProductCartAction({required this.product});

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    final session = ref.read(authProvider).value;
    if (session == null) {
      context.go('/login');
      return;
    }

    try {
      await ref.read(cartProvider.notifier).addItem(
        productId: product.id,
        storeId: product.storeId,
        storeName: product.storeName,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk ditambahkan ke keranjang')),
      );
    } on CartDifferentStoreException catch (e) {
      if (!context.mounted) return;
      _showDifferentStoreDialog(context, ref, e);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan ke keranjang')),
      );
    }
  }

  void _showDifferentStoreDialog(
    BuildContext context,
    WidgetRef ref,
    CartDifferentStoreException e,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keranjang Berisi Toko Lain'),
        content: Text(
          'Keranjangmu sudah berisi produk dari ${e.currentStoreName}. '
          'Menambah produk dari ${e.newStoreName} akan mengosongkan keranjang saat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(cartProvider.notifier).clearAndAddItem(
                  productId: product.id,
                  storeId: product.storeId,
                  storeName: product.storeName,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Keranjang diperbarui')),
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Gagal memperbarui keranjang')),
                );
              }
            },
            child: const Text('Kosongkan dan Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartItem = cartAsync.value?.items
        .where((item) => item.productId == product.id)
        .firstOrNull;

    if (cartItem != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: _InlineQuantityStepper(
          quantity: cartItem.quantity,
          onDecrement: () {
            if (cartItem.quantity <= 1) {
              ref.read(cartProvider.notifier).removeItem(cartItem.id);
            } else {
              ref.read(cartProvider.notifier).updateQuantity(
                cartItemId: cartItem.id,
                quantity: cartItem.quantity - 1,
              );
            }
          },
          onIncrement: () => ref.read(cartProvider.notifier).updateQuantity(
            cartItemId: cartItem.id,
            quantity: cartItem.quantity + 1,
          ),
        ),
      );
    }

    return AppButton(
      label: 'Tambah ke Keranjang',
      onPressed: () => _addToCart(context, ref),
    );
  }
}

class _InlineQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _InlineQuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: AppColors.onPrimary, size: 18),
      ),
    );
  }
}

class _CartIconButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final itemCount = cartAsync.value?.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ) ??
        0;

    return IconButton(
      icon: Badge(
        isLabelVisible: itemCount > 0,
        label: Text('$itemCount'),
        backgroundColor: AppColors.primary,
        textColor: AppColors.onPrimary,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
      onPressed: () => context.go('/cart'),
    );
  }
}

class _ThumbnailRow extends StatelessWidget {
  final String? imageUrl;
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
                      ? AppColors.primary
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
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 60,
            color: isActive ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
