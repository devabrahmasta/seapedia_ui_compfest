import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/order_status.dart';

class IncomingOrdersScreen extends ConsumerWidget {
  const IncomingOrdersScreen({super.key});

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
        title: const Text('Pesanan Masuk'),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat pesanan: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pesanan masuk',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          final perluDiproses = orders.where((o) => o.status == 'Sedang Dikemas').toList();
          final menungguKurir = orders.where((o) => o.status != 'Sedang Dikemas').toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(incomingOrdersProvider.future),
            child: ListView(
              padding: AppSpacing.screenPaddingHorizontal.add(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              children: [
                const _SectionHeader(title: 'Perlu Diproses', iconColor: AppColors.primary),
                const SizedBox(height: 12),
                if (perluDiproses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text('Tidak ada pesanan', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  ...perluDiproses.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _IncomingOrderCard(
                      order: o,
                      dateFmt: _dateFmt,
                      priceFmt: _priceFmt,
                      onTap: () => context.push('/order/${o.id}'),
                      accentColor: AppColors.primary,
                    ),
                  )),
                const SizedBox(height: 12),
                const _SectionHeader(title: 'Menunggu Kurir'),
                const SizedBox(height: 12),
                if (menungguKurir.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text('Tidak ada pesanan', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  ...menungguKurir.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _IncomingOrderCard(
                      order: o,
                      dateFmt: _dateFmt,
                      priceFmt: _priceFmt,
                      onTap: () => context.push('/order/${o.id}'),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? iconColor;

  const _SectionHeader({required this.title, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconColor != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _IncomingOrderCard extends StatelessWidget {
  final OrderSummary order;
  final DateFormat dateFmt;
  final NumberFormat priceFmt;
  final VoidCallback onTap;
  final Color? accentColor;

  const _IncomingOrderCard({
    required this.order,
    required this.dateFmt,
    required this.priceFmt,
    required this.onTap,
    this.accentColor,
  });

  String _buyerDisplay() {
    final name = order.buyerName;
    if (name != null && name.isNotEmpty) return name;
    return 'Pembeli';
  }

  @override
  Widget build(BuildContext context) {
    final itemLabel = order.itemNames.isEmpty ? '–' : order.itemNames.join(', ');

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (accentColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  '${_buyerDisplay()} · ${dateFmt.format(order.createdAt)}',
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
