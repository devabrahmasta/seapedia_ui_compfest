import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/promo/data/promo_repository.dart';

final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepository(Supabase.instance.client);
});

final availablePromosProvider = FutureProvider<List<PromoCode>>((ref) async {
  return ref.read(promoRepositoryProvider).getAvailablePromos();
});

final allVouchersProvider = FutureProvider<List<PromoCode>>((ref) async {
  return ref.watch(promoRepositoryProvider).getAllVouchers();
});

final allPromosProvider = FutureProvider<List<PromoCode>>((ref) async {
  return ref.watch(promoRepositoryProvider).getAllPromos();
});
