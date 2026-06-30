import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/delivery/data/delivery_job_repository.dart';

final deliveryJobRepositoryProvider = Provider<DeliveryJobRepository>((ref) {
  return DeliveryJobRepository(Supabase.instance.client);
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
