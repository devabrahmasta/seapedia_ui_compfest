import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/order_status.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  static final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');
  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pesanan Saya'),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat pesanan: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text('Belum ada pesanan', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myOrdersProvider.future),
            child: ListView.separated(
              padding: AppSpacing.screenPaddingHorizontal.add(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _OrderCard(
                order: orders[i],
                dateFmt: _dateFmt,
                priceFmt: _priceFmt,
                onTap: () => context.push('/order/${orders[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderSummary order;
  final DateFormat dateFmt;
  final NumberFormat priceFmt;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.dateFmt,
    required this.priceFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemLabel = order.itemNames.isEmpty
        ? '–'
        : order.itemNames.join(', ');

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${order.storeName} · ${dateFmt.format(order.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            itemLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(orderStatusIcon(order.status), size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.status,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                priceFmt.format(order.total),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
