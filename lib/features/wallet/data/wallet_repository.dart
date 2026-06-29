import 'package:supabase_flutter/supabase_flutter.dart';

class Wallet {
  final String id;
  final String userId;
  final double balance;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    balance: (json['balance'] as num).toDouble(),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

class WalletTransaction {
  final String id;
  final String walletId;
  final String type;
  final double amount;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  bool get isTopUp => type == 'topup';

  String get displayLabel {
    switch (type) {
      case 'topup':
        return 'Top Up Saldo';
      case 'checkout':
        return 'Pembayaran Pesanan';
      case 'refund':
        return 'Pengembalian Dana';
      case 'driver_earning':
        return 'Pendapatan Kurir';
      default:
        return type;
    }
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        walletId: json['wallet_id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
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
      'type': 'topup',
      'amount': amount,
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
      'type': 'checkout',
      'amount': amount,
      'reference_id': orderId,
    });
  }

  Future<List<WalletTransaction>> getTransactionHistory(String walletId) async {
    final data = await _client
        .from('wallet_transactions')
        .select()
        .eq('wallet_id', walletId)
        .order('created_at', ascending: false);

    return data.map((e) => WalletTransaction.fromJson(e)).toList();
  }
}
