import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/wallet/data/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(Supabase.instance.client);
});

final myWalletProvider = FutureProvider<Wallet?>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return null;

  final repository = ref.watch(walletRepositoryProvider);
  return repository.getOrCreateWallet(session.user.id);
});

final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((
  ref,
) async {
  final wallet = await ref.watch(myWalletProvider.future);
  if (wallet == null) return [];

  final repository = ref.watch(walletRepositoryProvider);
  return repository.getTransactionHistory(wallet.id);
});
