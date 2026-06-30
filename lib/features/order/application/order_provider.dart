import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(Supabase.instance.client);
});

final myOrdersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return [];
  return ref.read(orderRepositoryProvider).getMyOrders(session.user.id);
});

final orderDetailProvider = FutureProvider.family<OrderDetail, String>((
  ref,
  orderId,
) async {
  return ref.read(orderRepositoryProvider).getOrderDetail(orderId);
});

final incomingOrdersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  final store = await ref.watch(myStoreProvider.future);
  if (store == null) return [];
  return ref.read(orderRepositoryProvider).getIncomingOrders(store.id);
});

final storeIncomeProvider = FutureProvider.family<StoreIncomeSummary, String>((
  ref,
  storeId,
) async {
  return ref.read(orderRepositoryProvider).getStoreIncomeSummary(storeId);
});
