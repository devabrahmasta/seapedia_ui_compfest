import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/order_status.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/widgets/order_action_buyer.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/widgets/order_action_driver.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/widgets/order_action_seller.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  static final _timeFmt = DateFormat('d MMM, HH:mm', 'id_ID');
  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _compact(double price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}rb';
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(orderId));
    final activeRole = ref.watch(activeRoleProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan'), centerTitle: true),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat detail: $e')),
        data: (detail) => _DetailBody(
          detail: detail,
          timeFmt: _timeFmt,
          priceFmt: _priceFmt,
          compact: _compact,
          activeRole: activeRole,
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final OrderDetail detail;
  final DateFormat timeFmt;
  final NumberFormat priceFmt;
  final String Function(double) compact;
  final String? activeRole;

  const _DetailBody({
    required this.detail,
    required this.timeFmt,
    required this.priceFmt,
    required this.compact,
    required this.activeRole,
  });

  @override
  Widget build(BuildContext context) {
    final order = detail.order;
    return ListView(
      padding: AppSpacing.screenPaddingHorizontal.add(
        const EdgeInsets.symmetric(vertical: 20),
      ),
      children: [
        _StatusBanner(status: order.status),
        const SizedBox(height: 24),
        _Section(
          title: 'Status Pesanan',
          child: _StatusTimeline(
            history: detail.statusHistory,
            timeFmt: timeFmt,
          ),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Produk',
          child: AppCard(
            child: Column(
              children: [
                for (int i = 0; i < detail.items.length; i++) ...[
                  _ProductRow(item: detail.items[i], compact: compact),
                  if (i < detail.items.length - 1) ...[
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Rincian Pembayaran',
          child: AppCard(
            child: Column(
              children: [
                _PriceRow(
                  label: 'Subtotal',
                  value: priceFmt.format(order.subtotal),
                ),
                if (order.discountAmount > 0) ...[
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: 'Diskon',
                    value: '-${priceFmt.format(order.discountAmount)}',
                    valueColor: AppColors.primary,
                  ),
                ],
                const SizedBox(height: 10),
                _PriceRow(
                  label: 'Pengiriman',
                  value: priceFmt.format(order.deliveryFee),
                ),
                const SizedBox(height: 10),
                _PriceRow(label: 'PPN', value: priceFmt.format(order.ppn)),
                const SizedBox(height: 10),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      priceFmt.format(order.total),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Alamat Pengiriman',
          child: AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detail.addressLabel.isNotEmpty)
                        Text(
                          detail.addressLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(fontSize: 14),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        detail.addressFull.isEmpty ? '–' : detail.addressFull,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        switch (activeRole) {
          'buyer' => OrderActionBuyer(order: order),
          'seller' => OrderActionSeller(order: order),
          'driver' => OrderActionDriver(order: order),
          _ => const SizedBox.shrink(),
        },
        const SizedBox(height: 12),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            orderStatusIcon(status),
            size: 32,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  _statusSubtitle(status),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusSubtitle(String status) {
    switch (status) {
      case 'Sedang Dikemas':
        return 'Pesanan sedang disiapkan oleh penjual';
      case 'Menunggu Pengirim':
        return 'Menunggu kurir mengambil paket';
      case 'Sedang Dikirim':
        return 'Estimasi tiba hari ini';
      case 'Pesanan Selesai':
        return 'Pesanan telah diterima';
      case 'Dikembalikan':
        return 'Pesanan sedang diproses pengembalian';
      default:
        return '';
    }
  }
}

class _StatusTimeline extends StatelessWidget {
  final List<OrderStatusHistory> history;
  final DateFormat timeFmt;

  const _StatusTimeline({required this.history, required this.timeFmt});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (int i = 0; i < history.length; i++)
          _TimelineRow(
            entry: history[i],
            isFirst: i == 0,
            isLast: i == history.length - 1,
            timeFmt: timeFmt,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final OrderStatusHistory entry;
  final bool isFirst;
  final bool isLast;
  final DateFormat timeFmt;

  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.timeFmt,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst ? AppColors.primary : AppColors.border,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.border,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.status,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
                      color: isFirst
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeFmt.format(entry.changedAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _ProductRow extends StatelessWidget {
  final OrderItem item;
  final String Function(double) compact;

  const _ProductRow({required this.item, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.productNameSnapshot,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${item.quantity} × ${compact(item.priceSnapshot)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
