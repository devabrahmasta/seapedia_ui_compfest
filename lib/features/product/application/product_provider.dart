import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

final myProductsProvider = FutureProvider<List<Product>>((ref) async {
  final store = await ref.watch(myStoreProvider.future);
  if (store == null) return [];

  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchMyProducts(store.id);
});

final getProductsByStoreIdProvider =
    FutureProvider.family<List<Product>, String>((ref, storeId) async {
      final repository = ref.watch(productRepositoryProvider);
      return repository.fetchMyProducts(storeId);
    });
