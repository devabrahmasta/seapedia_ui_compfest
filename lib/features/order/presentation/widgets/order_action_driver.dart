import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/delivery/application/delivery_job_provider.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';

class OrderActionDriver extends ConsumerStatefulWidget {
  final Order order;

  const OrderActionDriver({super.key, required this.order});

  @override
  ConsumerState<OrderActionDriver> createState() => _OrderActionDriverState();
}

class _OrderActionDriverState extends ConsumerState<OrderActionDriver> {
  static final _priceFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  bool _isLoading = false;

  Future<void> _completeJob(String jobId, String driverId) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(deliveryJobRepositoryProvider)
          .completeJob(jobId, driverId, widget.order.deliveryFee);
      ref.invalidate(orderDetailProvider(widget.order.id));
      ref.invalidate(jobByOrderIdProvider(widget.order.id));
      ref.invalidate(availableJobsProvider);
      if (mounted) {
        context.go('/driver/job-completed', extra: widget.order.deliveryFee);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyelesaikan pengantaran: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.status == 'Sedang Dikirim') {
      final driverId = ref.watch(authProvider).value?.user.id;
      final jobAsync = ref.watch(jobByOrderIdProvider(widget.order.id));

      return jobAsync.when(
        data: (job) {
          if (job == null || driverId == null || job.driverId != driverId) {
            return const SizedBox.shrink();
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tandai pesanan sudah sampai ke pembeli',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _isLoading
                      ? 'Memproses...'
                      : 'Selesaikan Pengantaran',
                  isLoading: _isLoading,
                  onPressed: _isLoading
                      ? null
                      : () => _completeJob(job.id, driverId),
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      );
    }

    if (widget.order.status == 'Pesanan Selesai') {
      return Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pengantaran selesai',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '+${_priceFmt.format(widget.order.deliveryFee)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
