import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_image.dart';
import 'package:seapedia_ui_compfest/features/cart/application/cart_provider.dart';
import 'package:seapedia_ui_compfest/features/cart/data/cart_repository.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang'), centerTitle: true),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat keranjang: $e')),
        data: (cartState) {
          if (cartState.isEmpty) return const _EmptyCartState();
          return _CartContent(cartState: cartState, formatter: _formatter);
        },
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingHorizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keranjang kamu masih kosong',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Mulai Belanja',
              onPressed: () => context.go('/products'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends ConsumerWidget {
  final CartState cartState;
  final NumberFormat formatter;

  const _CartContent({required this.cartState, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPaddingHorizontal.add(
              const EdgeInsets.symmetric(vertical: 16),
            ),
            children: [
              _StoreHeader(storeName: cartState.cart?.storeName ?? 'Toko'),
              const SizedBox(height: 16),
              ...cartState.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartItemRow(
                    item: item,
                    formatter: formatter,
                    onQuantityChanged: (qty) => notifier.updateQuantity(
                      cartItemId: item.id,
                      quantity: qty,
                    ),
                    onRemove: () => notifier.removeItem(item.id),
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 32),
              _SubtotalRow(
                subtotal: cartState.subtotal,
                formatter: formatter,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        _CheckoutBar(subtotal: cartState.subtotal, formatter: formatter),
      ],
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final String storeName;

  const _StoreHeader({required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.storefront_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          storeName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemWithProduct item;
  final NumberFormat formatter;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.item,
    required this.formatter,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk?'),
        content: Text(
          '${item.productName} akan dihapus dari keranjang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onRemove();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: ProductImage(
            imageUrl: item.productImageUrl,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(item.productPrice),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              _QuantityStepper(
                quantity: item.quantity,
                onChanged: onQuantityChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _confirmRemove(context),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: () => onChanged(quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SubtotalRow extends StatelessWidget {
  final double subtotal;
  final NumberFormat formatter;

  const _SubtotalRow({required this.subtotal, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Subtotal',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          formatter.format(subtotal),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double subtotal;
  final NumberFormat formatter;

  const _CheckoutBar({required this.subtotal, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPaddingHorizontal.add(
          const EdgeInsets.only(bottom: 16, top: 12),
        ),
        child: AppButton(
          label: 'Checkout · ${formatter.format(subtotal)}',
          onPressed: () {},
        ),
      ),
    );
  }
}
