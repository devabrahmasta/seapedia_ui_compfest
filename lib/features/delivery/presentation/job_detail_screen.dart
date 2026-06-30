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

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  bool _isLoading = false;

  Future<void> _takeJob(DeliveryJobDetail detail) async {
    final driverId = ref.read(authProvider).value?.user.id;
    if (driverId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(deliveryJobRepositoryProvider)
          .takeJob(detail.job.id, driverId);
      ref.invalidate(availableJobsProvider);
      if (mounted) context.go('/order/${detail.job.orderId}');
    } on JobAlreadyTakenException {
      if (mounted) await _showJobTakenDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil job: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showJobTakenDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                Icons.inventory_2_outlined,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Job Sudah Diambil',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Job ini baru saja diambil oleh kurir lain. Coba job lain yang masih tersedia.',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Kembali ke Daftar Job',
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/driver/jobs');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(jobDetailProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Job'), centerTitle: true),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat job: $e')),
        data: (detail) => _DetailBody(
          detail: detail,
          priceFmt: _priceFmt,
          isLoading: _isLoading,
          onTakeJob: () => _takeJob(detail),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final DeliveryJobDetail detail;
  final NumberFormat priceFmt;
  final bool isLoading;
  final VoidCallback onTakeJob;

  const _DetailBody({
    required this.detail,
    required this.priceFmt,
    required this.isLoading,
    required this.onTakeJob,
  });

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
                        address: detail.storeAddress ?? '',
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
                label: isLoading ? 'Mengambil...' : 'Ambil Job',
                isLoading: isLoading,
                onPressed: isLoading ? null : onTakeJob,
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
                Text(address, style: Theme.of(context).textTheme.bodyMedium),
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
