import 'package:supabase_flutter/supabase_flutter.dart';

class Address {
  final String id;
  final String userId;
  final String label;
  final String fullAddress;
  final bool isDefault;
  final DateTime createdAt;

  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullAddress,
    required this.isDefault,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    label: json['label'] as String,
    fullAddress: json['full_address'] as String,
    isDefault: json['is_default'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class AddressRepository {
  final SupabaseClient _client;

  AddressRepository(this._client);

  Future<List<Address>> getAddresses(String userId) async {
    final data = await _client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return data.map((e) => Address.fromJson(e)).toList();
  }

  Future<Address> createAddress({
    required String userId,
    required String label,
    required String fullAddress,
    required bool isDefault,
  }) async {
    if (isDefault) await _clearDefaultForUser(userId);

    final data = await _client
        .from('addresses')
        .insert({
          'user_id': userId,
          'label': label,
          'full_address': fullAddress,
          'is_default': isDefault,
        })
        .select()
        .single();

    return Address.fromJson(data);
  }

  Future<void> updateAddress({
    required String addressId,
    required String userId,
    required String label,
    required String fullAddress,
    required bool isDefault,
  }) async {
    if (isDefault) await _clearDefaultForUser(userId);

    await _client
        .from('addresses')
        .update({
          'label': label,
          'full_address': fullAddress,
          'is_default': isDefault,
        })
        .eq('id', addressId);
  }

  Future<void> setDefault({
    required String addressId,
    required String userId,
  }) async {
    await _clearDefaultForUser(userId);
    await _client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }

  Future<void> delete(String addressId) async {
    await _client.from('addresses').delete().eq('id', addressId);
  }

  Future<void> _clearDefaultForUser(String userId) async {
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId)
        .eq('is_default', true);
  }
}
