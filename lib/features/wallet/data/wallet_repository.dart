import 'package:supabase_flutter/supabase_flutter.dart';

class Wallet {
  final String id;
  final String userId;
  final double balance;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    balance: (json['balance'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class WalletTransaction {
  final String id;
  final String walletId;
  final String type;
  final double amount;
  final String? description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  bool get isTopUp => type == 'top_up';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        walletId: json['wallet_id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class WalletRepository {
  final SupabaseClient _client;

  WalletRepository(this._client);

  Future<Wallet> getOrCreateWallet(String userId) async {
    final existing = await _client
        .from('wallets')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) return Wallet.fromJson(existing);

    final created = await _client
        .from('wallets')
        .insert({'user_id': userId, 'balance': 0})
        .select()
        .single();

    return Wallet.fromJson(created);
  }

  Future<Wallet> topUp({
    required String walletId,
    required double amount,
    required double currentBalance,
  }) async {
    final newBalance = currentBalance + amount;

    await _client
        .from('wallets')
        .update({'balance': newBalance})
        .eq('id', walletId);

    await _client.from('wallet_transactions').insert({
      'wallet_id': walletId,
      'type': 'top_up',
      'amount': amount,
      'description': 'Top Up Saldo',
    });

    final data = await _client
        .from('wallets')
        .select()
        .eq('id', walletId)
        .single();

    return Wallet.fromJson(data);
  }

  Future<void> deductForOrder({
    required String walletId,
    required double amount,
    required double currentBalance,
    required String orderId,
  }) async {
    final newBalance = currentBalance - amount;

    await _client
        .from('wallets')
        .update({'balance': newBalance})
        .eq('id', walletId);

    await _client.from('wallet_transactions').insert({
      'wallet_id': walletId,
      'type': 'payment',
      'amount': amount,
      'description': 'Pembayaran Pesanan',
    });
  }

  Future<List<WalletTransaction>> getTransactionHistory(
    String walletId,
  ) async {
    final data = await _client
        .from('wallet_transactions')
        .select()
        .eq('wallet_id', walletId)
        .order('created_at', ascending: false);

    return data.map((e) => WalletTransaction.fromJson(e)).toList();
  }
}
