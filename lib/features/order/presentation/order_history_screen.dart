import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/widgets/order_summary_card.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  static final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');
  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(incomingOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History Pesanan'),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat pesanan: $e')),
        data: (orders) {
          final completedOrders = orders
              .where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan')
              .toList();

          if (completedOrders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada history pesanan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(incomingOrdersProvider.future),
            child: ListView.builder(
              padding: AppSpacing.screenPaddingHorizontal.add(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                final o = completedOrders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderSummaryCard(
                    order: o,
                    dateFmt: _dateFmt,
                    priceFmt: _priceFmt,
                    onTap: () => context.push('/order/${o.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
