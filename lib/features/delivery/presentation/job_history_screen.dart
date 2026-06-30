import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/delivery/application/delivery_job_provider.dart';
import 'package:seapedia_ui_compfest/features/delivery/data/delivery_job_repository.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/delivery_method_label.dart';

class JobHistoryScreen extends ConsumerWidget {
  const JobHistoryScreen({super.key});

  static final _dateFmt = DateFormat('d MMM, HH:mm', 'id_ID');
  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(jobHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Job'),
        centerTitle: true,
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat riwayat: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat job',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(jobHistoryProvider.future),
            child: ListView.separated(
              padding: AppSpacing.screenPaddingHorizontal.add(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _HistoryCard(
                item: items[index],
                dateFmt: _dateFmt,
                priceFmt: _priceFmt,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DeliveryJobHistoryItem item;
  final DateFormat dateFmt;
  final NumberFormat priceFmt;

  const _HistoryCard({
    required this.item,
    required this.dateFmt,
    required this.priceFmt,
  });

  @override
  Widget build(BuildContext context) {
    final completedAt = item.job.completedAt;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.storeName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (completedAt != null) ...[
                      Text(
                        dateFmt.format(completedAt.toLocal()),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      deliveryMethodIcon(item.deliveryMethod),
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deliveryMethodLabel(item.deliveryMethod),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            priceFmt.format(item.earning),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
