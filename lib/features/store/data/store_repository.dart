import 'package:supabase_flutter/supabase_flutter.dart';

class Store {
  final String id;
  final String sellerId;
  final String storeName;
  final String? description;
  final DateTime createdAt;

  const Store({
    required this.id,
    required this.sellerId,
    required this.storeName,
    required this.description,
    required this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      storeName: json['store_name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class StoreRepository {
  StoreRepository(this._client);

  final SupabaseClient _client;

  Future<Store?> getStoreBySellerId(String sellerId) async {
    final response = await _client
        .from('stores')
        .select()
        .eq('seller_id', sellerId)
        .maybeSingle();
    return response == null ? null : Store.fromJson(response);
  }

  Future<Store> createStore({
    required String sellerId,
    required String storeName,
    String? description,
  }) async {
    final response = await _client
        .from('stores')
        .insert({
          'seller_id': sellerId,
          'store_name': storeName,
          'description': description,
        })
        .select()
        .single();
    return Store.fromJson(response);
  }

  Future<Store> updateStore({
    required String storeId,
    required String storeName,
    String? description,
  }) async {
    final response = await _client
        .from('stores')
        .update({'store_name': storeName, 'description': description})
        .eq('id', storeId)
        .select()
        .single();
    return Store.fromJson(response);
  }

  Future<Store?> getStoreById(String id) async {
    final response = await _client
        .from('stores')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response == null ? null : Store.fromJson(response);
  }
}
