import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';

class OrderActionSeller extends ConsumerStatefulWidget {
  final Order order;

  const OrderActionSeller({super.key, required this.order});

  @override
  ConsumerState<OrderActionSeller> createState() => _OrderActionSellerState();
}

class _OrderActionSellerState extends ConsumerState<OrderActionSeller> {
  bool _isLoading = false;

  Future<void> _processOrder() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(widget.order.id, 'Menunggu Pengirim');
      ref.invalidate(orderDetailProvider(widget.order.id));
      ref.invalidate(incomingOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diproses')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memproses pesanan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.status == 'Sedang Dikemas') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tandai pesanan siap untuk pengiriman',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: _isLoading ? 'Memproses...' : 'Proses Pesanan',
              icon: _isLoading ? null : Icons.local_shipping_outlined,
              onPressed: _isLoading ? null : _processOrder,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Menunggu kurir mengambil pesanan',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
