import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/store/data/store_repository.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(Supabase.instance.client);
});

final myStoreProvider = FutureProvider<Store?>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return null;

  final repository = ref.watch(storeRepositoryProvider);
  return repository.getStoreBySellerId(session.user.id);
});

final getStoreByIdProvider = FutureProvider.family<Store?, String>((
  ref,
  storeId,
) async {
  final repository = ref.watch(storeRepositoryProvider);
  return repository.getStoreById(storeId);
});
