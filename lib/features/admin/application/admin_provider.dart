import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/admin/data/admin_repository.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

final userCountProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(adminRepositoryProvider).getUserCount();
});

final storeCountProvider = FutureProvider<int>((ref) {
  return ref.watch(adminRepositoryProvider).getStoreCount();
});

final productCountProvider = FutureProvider<int>((ref) {
  return ref.watch(adminRepositoryProvider).getProductCount();
});

final orderCountByStatusProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(adminRepositoryProvider).getOrderCountByStatus();
});

final voucherPromoCountProvider = FutureProvider<int>((ref) {
  return ref.watch(adminRepositoryProvider).getVoucherPromoCount();
});

final deliveryJobCountByStatusProvider = FutureProvider<Map<String, int>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).getDeliveryJobCountByStatus();
});

final overdueOrderCountProvider = FutureProvider<int>((ref) {
  return ref.watch(adminRepositoryProvider).getOverdueOrderCount();
});

class SimulatedTimeOffsetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final simulatedTimeOffsetProvider =
    NotifierProvider<SimulatedTimeOffsetNotifier, int>(() {
      return SimulatedTimeOffsetNotifier();
    });

final simulatedNowProvider = Provider<DateTime>((ref) {
  final offset = ref.watch(simulatedTimeOffsetProvider);
  return DateTime.now().add(Duration(days: offset));
});

final overdueOrdersListProvider = FutureProvider<List<OverdueOrder>>((
  ref,
) async {
  final simulatedNow = ref.watch(simulatedNowProvider);
  return ref.watch(orderRepositoryProvider).findOverdueOrders(simulatedNow);
});
