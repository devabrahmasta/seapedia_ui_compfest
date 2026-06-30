import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/delivery/application/delivery_job_provider.dart';
import 'package:seapedia_ui_compfest/features/delivery/data/delivery_job_repository.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/delivery_method_label.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Job'), centerTitle: true),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat job: $e')),
        data: (detail) => _DetailBody(detail: detail, priceFmt: _priceFmt),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final DeliveryJobDetail detail;
  final NumberFormat priceFmt;

  const _DetailBody({required this.detail, required this.priceFmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPaddingHorizontal.add(
              const EdgeInsets.symmetric(vertical: 20),
            ),
            children: [
              _Section(
                title: 'Rute Pengantaran',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      deliveryMethodIcon(detail.deliveryMethod),
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deliveryMethodLabel(detail.deliveryMethod),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteRow(
                        icon: Icons.storefront_outlined,
                        label: 'Ambil dari',
                        name: detail.storeName,
                        address: '',
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: Container(
                          width: 1.5,
                          height: 20,
                          color: AppColors.border,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _RouteRow(
                        icon: Icons.location_on_outlined,
                        label: 'Antar ke',
                        name: detail.buyerName,
                        address: detail.addressFull,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Ringkasan Pesanan',
                child: AppCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < detail.items.length; i++) ...[
                        _ItemRow(item: detail.items[i]),
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
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimasi Pendapatan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceFmt.format(detail.deliveryFee),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.primary, fontSize: 26),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.screenPaddingHorizontal.add(
              const EdgeInsets.only(bottom: 12, top: 4),
            ),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Ambil Job',
                onPressed: () {
                  // TODO: implementasi takeJob di Tahap 2
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            ?trailing,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final String address;

  const _RouteRow({
    required this.icon,
    required this.label,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final DeliveryJobItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
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
          'x${item.quantity}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
