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
        .map((role) => {
              'user_id': userId,
              'role': role,
            })
        .toList();
    return _client.from('user_roles').insert(rows);
  }
}