import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/address/data/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(Supabase.instance.client);
});

final myAddressesProvider = FutureProvider<List<Address>>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return [];

  final repository = ref.watch(addressRepositoryProvider);
  return repository.getAddresses(session.user.id);
});
