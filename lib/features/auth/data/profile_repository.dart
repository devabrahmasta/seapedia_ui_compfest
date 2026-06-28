import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<void> createProfile({
    required String userId,
    required String username,
    required String fullName,
  }) {
    return _client.from('profiles').insert({
      'id': userId,
      'username': username,
      'full_name': fullName,
    });
  }

  Future<void> insertUserRoles({
    required String userId,
    required Set<String> roles,
  }) {
    final rows = roles
        .map((role) => {'user_id': userId, 'role': role})
        .toList();
    return _client.from('user_roles').insert(rows);
  }

  Future<List<String>> getUserRoles(String userId) async {
    final response = await _client
        .from('user_roles')
        .select('role')
        .eq('user_id', userId);
    return (response as List).map((row) => row['role'] as String).toList();
  }

  Future<void> setActiveRole({required String userId, required String? role}) {
    return _client
        .from('profiles')
        .update({'active_role': role})
        .eq('id', userId);
  }

  Future<String?> getActiveRole(String userId) async {
    final response = await _client
        .from('profiles')
        .select('active_role')
        .eq('id', userId)
        .maybeSingle();
    return response?['active_role'] as String?;
  }
}
