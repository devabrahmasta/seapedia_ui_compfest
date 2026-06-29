import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_image.dart';
import 'package:seapedia_ui_compfest/features/address/application/address_provider.dart';
import 'package:seapedia_ui_compfest/features/address/data/address_repository.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/cart/application/cart_provider.dart';
import 'package:seapedia_ui_compfest/features/cart/data/cart_repository.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';
import 'package:seapedia_ui_compfest/features/wallet/application/wallet_provider.dart';
import 'package:seapedia_ui_compfest/features/wallet/data/wallet_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static final _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _deliveryMethod = 'instant';
  Address? _selectedAddress;
  bool _isLoading = false;

  double get _deliveryFee => OrderRepository.deliveryFees[_deliveryMethod]!;

  String _compact(double price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}rb';
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myAddressesProvider, (_, next) {
      next.whenData((list) {
        if (_selectedAddress == null && list.isNotEmpty && mounted) {
          setState(() => _selectedAddress = list.first);
        }
      });
    });

    final cartAsync = ref.watch(cartProvider);
    final walletAsync = ref.watch(myWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat cart: $e')),
        data: (cart) {
          if (cart.isEmpty) return const Center(child: Text('Keranjang kosong'));

          final subtotal = cart.subtotal;
          final ppn = subtotal * 0.12;
          final total = subtotal + _deliveryFee + ppn;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPaddingHorizontal.add(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                  children: [
                    _Section(
                      title: 'Alamat pengiriman',
                      child: _AddressCard(
                        address: _selectedAddress,
                        onTap: () => _showAddressPicker(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Metode pengiriman',
                      child: _DeliveryCard(
                        method: _deliveryMethod,
                        fee: _deliveryFee,
                        fmt: _fmt,
                        onTap: () => _showDeliveryPicker(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Produk',
                      child: AppCard(
                        child: Column(
                          children: [
                            for (int i = 0; i < cart.items.length; i++) ...[
                              _ProductRow(
                                item: cart.items[i],
                                compact: _compact(cart.items[i].productPrice),
                              ),
                              if (i < cart.items.length - 1) ...[
                                const SizedBox(height: 10),
                                const Divider(color: AppColors.border, height: 1),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Rincian pembelian',
                      child: AppCard(
                        child: Column(
                          children: [
                            _PriceRow(
                              label: 'Subtotal produk',
                              value: _fmt.format(subtotal),
                            ),
                            const SizedBox(height: 10),
                            _PriceRow(
                              label: 'Biaya pengiriman',
                              value: _fmt.format(_deliveryFee),
                            ),
                            const SizedBox(height: 10),
                            _PriceRow(
                              label: 'PPN (12%)',
                              value: _fmt.format(ppn),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: AppColors.border, height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total pembayaran',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  _fmt.format(total),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    walletAsync.maybeWhen(
                      data: (w) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Saldo wallet: ${_fmt.format(w?.balance ?? 0)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _PayBar(
                total: total,
                fmt: _fmt,
                isLoading: _isLoading,
                onPay: () => _handleCheckout(cart, total, walletAsync.value),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddressPicker(BuildContext context) {
    final list = ref.read(myAddressesProvider).value ?? [];
    if (list.isEmpty) {
      context.push('/addresses');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddressPickerSheet(
        addresses: list,
        selected: _selectedAddress,
        onSelect: (addr) {
          setState(() => _selectedAddress = addr);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showDeliveryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DeliveryPickerSheet(
        selected: _deliveryMethod,
        fmt: _fmt,
        onSelect: (method) {
          setState(() => _deliveryMethod = method);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _handleCheckout(CartState cart, double total, Wallet? wallet) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman terlebih dahulu')),
      );
      return;
    }
    if (wallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat informasi wallet')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = ref.read(authProvider).value!;
      await ref.read(orderRepositoryProvider).checkout(
        buyerId: session.user.id,
        cartId: cart.cart!.id,
        storeId: cart.cart!.storeId!,
        addressId: _selectedAddress!.id,
        deliveryMethod: _deliveryMethod,
        walletId: wallet.id,
        walletBalance: wallet.balance,
      );
      ref.invalidate(cartProvider);
      ref.invalidate(myWalletProvider);
      ref.invalidate(walletTransactionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat!')),
      );
      context.go('/');
    } on InsufficientBalanceException catch (e) {
      if (!mounted) return;
      _showInsufficientBalanceDialog(e);
    } on InsufficientStockException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok ${e.productName} tidak cukup (tersisa ${e.available})')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInsufficientBalanceDialog(InsufficientBalanceException e) {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 28,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Saldo Tidak Cukup', style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              'Saldo kamu ${_fmt.format(e.balance)}, total belanja ${_fmt.format(e.required)}',
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Top Up Sekarang',
              onPressed: () {
                Navigator.of(ctx).pop();
                router.push('/wallet');
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batalkan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ── Alamat ───────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final Address? address;
  final VoidCallback onTap;

  const _AddressCard({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: address == null
                ? Text(
                    'Pilih alamat pengiriman',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address!.label,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address!.fullAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

// ── Metode pengiriman ─────────────────────────────────────────────────────────

class _DeliveryCard extends StatelessWidget {
  final String method;
  final double fee;
  final NumberFormat fmt;
  final VoidCallback onTap;

  static const _labels = {
    'instant': 'Instant',
    'next_day': 'Next Day',
    'regular': 'Reguler',
  };

  const _DeliveryCard({
    required this.method,
    required this.fee,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labels[method] ?? method,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(fmt.format(fee), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

// ── Produk ────────────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final CartItemWithProduct item;
  final String compact;

  const _ProductRow({required this.item, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ProductImage(
            imageUrl: item.productImageUrl,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.productName,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${item.quantity} × $compact',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// ── Rincian ───────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ── Pay bar ───────────────────────────────────────────────────────────────────

class _PayBar extends StatelessWidget {
  final double total;
  final NumberFormat fmt;
  final bool isLoading;
  final VoidCallback onPay;

  const _PayBar({
    required this.total,
    required this.fmt,
    required this.isLoading,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingHorizontal
              .add(const EdgeInsets.only(bottom: 16, top: 12)),
          child: isLoading
              ? const AppButton(label: 'Memproses...', onPressed: null)
              : GestureDetector(
                  onTap: onPay,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fmt.format(total),
                          style: const TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Bayar Sekarang',
                              style: const TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.onPrimary,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Address picker sheet ──────────────────────────────────────────────────────

class _AddressPickerSheet extends StatelessWidget {
  final List<Address> addresses;
  final Address? selected;
  final ValueChanged<Address> onSelect;

  const _AddressPickerSheet({
    required this.addresses,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Pilih Alamat', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          ...addresses.map(
            (addr) => GestureDetector(
              onTap: () => onSelect(addr),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: selected?.id == addr.id ? AppColors.primary : AppColors.border,
                    width: selected?.id == addr.id ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addr.label,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontSize: 14),
                              ),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Utama',
                                    style: TextStyle(
                                      color: AppColors.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addr.fullAddress,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (selected?.id == addr.id)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delivery picker sheet ─────────────────────────────────────────────────────

class _DeliveryPickerSheet extends StatelessWidget {
  final String selected;
  final NumberFormat fmt;
  final ValueChanged<String> onSelect;

  static const _methods = [
    ('instant', 'Instant', 'Pengiriman langsung dalam hitungan jam'),
    ('next_day', 'Next Day', 'Tiba keesokan harinya'),
    ('regular', 'Reguler', 'Tiba dalam 2–3 hari kerja'),
  ];

  const _DeliveryPickerSheet({
    required this.selected,
    required this.fmt,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Pilih Metode Pengiriman', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          ..._methods.map(
            (entry) {
              final (key, label, desc) = entry;
              final isSelected = selected == key;
              final fee = OrderRepository.deliveryFees[key]!;
              return GestureDetector(
                onTap: () => onSelect(key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  label,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  fmt.format(fee),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
