import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/delivery/application/delivery_job_provider.dart';
import 'package:seapedia_ui_compfest/features/delivery/data/delivery_job_repository.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/delivery_method_label.dart';

class JobSearchScreen extends ConsumerWidget {
  const JobSearchScreen({super.key});

  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(availableJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Job'), centerTitle: true),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat job: $e')),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada job tersedia',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(availableJobsProvider.future),
            child: ListView.separated(
              padding: AppSpacing.screenPaddingHorizontal.add(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              itemCount: jobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _JobCard(
                  job: job,
                  priceFmt: _priceFmt,
                  onTap: () => context.push('/driver/jobs/${job.job.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final DeliveryJobSummary job;
  final NumberFormat priceFmt;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.priceFmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.storeName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                deliveryMethodIcon(job.deliveryMethod),
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                deliveryMethodLabel(job.deliveryMethod),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job.addressFull.isEmpty ? '–' : job.addressFull,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimasi Pendapatan',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                priceFmt.format(job.deliveryFee),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
