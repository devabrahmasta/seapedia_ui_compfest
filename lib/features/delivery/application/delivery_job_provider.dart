import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/delivery/data/delivery_job_repository.dart';
import 'package:seapedia_ui_compfest/features/delivery/data/driver_earnings_repository.dart';

final deliveryJobRepositoryProvider = Provider<DeliveryJobRepository>((ref) {
  return DeliveryJobRepository(Supabase.instance.client);
});

final driverEarningsRepositoryProvider = Provider<DriverEarningsRepository>((
  ref,
) {
  return DriverEarningsRepository(Supabase.instance.client);
});

final availableJobsProvider = FutureProvider<List<DeliveryJobSummary>>((
  ref,
) async {
  return ref.read(deliveryJobRepositoryProvider).getAvailableJobs();
});

final jobDetailProvider = FutureProvider.family<DeliveryJobDetail, String>((
  ref,
  jobId,
) async {
  return ref.read(deliveryJobRepositoryProvider).getJobDetail(jobId);
});

final jobByOrderIdProvider = FutureProvider.family<DeliveryJob?, String>((
  ref,
  orderId,
) async {
  return ref.read(deliveryJobRepositoryProvider).getJobByOrderId(orderId);
});

final activeJobProvider = FutureProvider<DeliveryJobSummary?>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return null;
  return ref
      .read(deliveryJobRepositoryProvider)
      .getActiveJob(session.user.id);
});

final jobHistoryProvider = FutureProvider<List<DeliveryJobHistoryItem>>((
  ref,
) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return [];
  return ref
      .read(deliveryJobRepositoryProvider)
      .getJobHistory(session.user.id);
});

final driverEarningsSummaryProvider = FutureProvider<DriverEarningsSummary>((
  ref,
) async {
  final session = ref.watch(authProvider).value;
  if (session == null) {
    return const DriverEarningsSummary(
      totalEarnings: 0,
      completedJobCount: 0,
      averagePerJob: 0,
    );
  }
  return ref
      .read(driverEarningsRepositoryProvider)
      .getEarningsSummary(session.user.id);
});
