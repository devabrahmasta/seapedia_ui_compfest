import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String username;
  final String? fullName;
  final String? email;
  final String? activeRole;
  final List<String> roles;

  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.activeRole,
    required this.roles,
  });
}

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

  Future<UserProfile> getCurrentUserProfile(String userId) async {
    final profileResponse = await _client
        .from('profiles')
        .select('id, username, full_name, active_role')
        .eq('id', userId)
        .single();

    final roles = await getUserRoles(userId);
    final email = _client.auth.currentUser?.email;

    return UserProfile(
      id: profileResponse['id'] as String,
      username: profileResponse['username'] as String,
      fullName: profileResponse['full_name'] as String?,
      email: email,
      activeRole: profileResponse['active_role'] as String?,
      roles: roles,
    );
  }
}
