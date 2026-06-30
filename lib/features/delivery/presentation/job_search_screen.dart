import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
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
    final activeJobAsync = ref.watch(activeJobProvider);
    final historyAsync = ref.watch(jobHistoryProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        title: _GreetingHeader(
          driverName: profileAsync.value?.fullName?.isNotEmpty == true
              ? profileAsync.value!.fullName!
              : profileAsync.value?.username,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableJobsProvider);
          ref.invalidate(activeJobProvider);
          ref.invalidate(jobHistoryProvider);
        },
        child: ListView(
          padding: AppSpacing.screenPaddingHorizontal.add(
            const EdgeInsets.symmetric(vertical: 16),
          ),
          children: [
            activeJobAsync.maybeWhen(
              data: (activeJob) => activeJob == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _ActiveJobCard(job: activeJob),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            historyAsync.maybeWhen(
              data: (history) {
                final now = DateTime.now();
                final todayStart = DateTime(now.year, now.month, now.day);
                final completedToday = history.where((item) {
                  final completedAt = item.job.completedAt;
                  return completedAt != null &&
                      !completedAt.toLocal().isBefore(todayStart);
                }).toList();
                final earningsToday = completedToday.fold<double>(
                  0,
                  (sum, item) => sum + item.earning,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline,
                          value: '${completedToday.length}',
                          label: 'Job selesai hari ini',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.payments_outlined,
                          value: _priceFmt.format(earningsToday),
                          label: 'Pendapatan hari ini',
                          valueColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            jobsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Gagal memuat job: $e')),
              data: (jobs) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Job Tersedia',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${jobs.length} job',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (jobs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Belum ada job tersedia',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      for (int i = 0; i < jobs.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == jobs.length - 1 ? 0 : 12,
                          ),
                          child: _JobCard(
                            job: jobs[i],
                            priceFmt: _priceFmt,
                            onTap: () =>
                                context.push('/driver/jobs/${jobs[i].job.id}'),
                          ),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String? driverName;

  const _GreetingHeader({required this.driverName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primarySurface,
          child: Icon(Icons.two_wheeler, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${driverName ?? 'Kurir'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text('Kurir', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: valueColor, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends ConsumerStatefulWidget {
  final DeliveryJobSummary job;

  const _ActiveJobCard({required this.job});

  @override
  ConsumerState<_ActiveJobCard> createState() => _ActiveJobCardState();
}

class _ActiveJobCardState extends ConsumerState<_ActiveJobCard> {
  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Material(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.two_wheeler,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengantaran Aktif',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                Text(
                  '#${job.job.orderId.substring(0, 8).toUpperCase()}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RouteRow(
              icon: Icons.storefront_outlined,
              label: 'Ambil dari',
              name: job.storeName,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Container(
                width: 1.5,
                height: 16,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            _RouteRow(
              icon: Icons.location_on_outlined,
              label: 'Antar ke',
              name: job.buyerName?.isNotEmpty == true
                  ? '${job.buyerName} · ${job.addressFull.isEmpty ? '–' : job.addressFull}'
                  : (job.addressFull.isEmpty ? '–' : job.addressFull),
            ),
            const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Detail Pengantaran',
                  onPressed: () {
                    context.push('/order/${job.job.orderId}');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;

  const _RouteRow({
    required this.icon,
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final DeliveryJobSummary job;
  final NumberFormat priceFmt;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.priceFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.storeName,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (job.storeAddress != null &&
                        job.storeAddress!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        job.storeAddress!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Estimasi',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    priceFmt.format(job.deliveryFee),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
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
              const Spacer(),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
