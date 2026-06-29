import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/data/auth_repository.dart';
import 'package:seapedia_ui_compfest/features/auth/data/profile_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final authProvider = AsyncNotifierProvider<AuthNotifier, Session?>(() {
  return AuthNotifier();
});

final userRolesProvider = FutureProvider<List<String>>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return [];
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserRoles(session.user.id);
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = ref.watch(authProvider).value;
  ref.watch(activeRoleProvider);
  if (session == null) return null;
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCurrentUserProfile(session.user.id);
});

class ActiveRoleNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final session = ref.watch(authProvider).value;
    if (session == null) return null;

    final profileRepository = ref.watch(profileRepositoryProvider);
    return profileRepository.getActiveRole(session.user.id);
  }

  Future<void> setRole(String role) async {
    final session = ref.read(authProvider).value;
    if (session == null) return;

    state = AsyncData(role);
    final repository = ref.read(profileRepositoryProvider);
    await repository.setActiveRole(userId: session.user.id, role: role);
  }
}

final activeRoleProvider = AsyncNotifierProvider<ActiveRoleNotifier, String?>(
  () {
    return ActiveRoleNotifier();
  },
);

class AuthNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    return Supabase.instance.client.auth.currentSession;
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.signIn(
        email: email,
        password: password,
      );

      final profileRepo = ref.read(profileRepositoryProvider);
      final roles = await profileRepo.getUserRoles(response.user!.id);

      if (roles.length == 1) {
        await profileRepo.setActiveRole(
          userId: response.user!.id,
          role: roles.first,
        );
      } else {
        await profileRepo.setActiveRole(userId: response.user!.id, role: null);
      }

      return response.session;
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    } catch (_) {
    } finally {
      state = const AsyncData(null);
    }
  }

  Future<void> registerWithRoles({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required Set<String> roles,
  }) async {
    if (roles.isEmpty) {
      state = AsyncError(
        Exception('Pilih minimal satu peran.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final profileRepository = ref.read(profileRepositoryProvider);

      final response = await authRepository.signUp(
        email: email,
        password: password,
      );
      final userId = response.user!.id;

      await profileRepository.createProfile(
        userId: userId,
        username: username,
        fullName: fullName,
      );
      await profileRepository.insertUserRoles(userId: userId, roles: roles);

      if (roles.length == 1) {
        await profileRepository.setActiveRole(
          userId: userId,
          role: roles.first,
        );
      } else {
        await profileRepository.setActiveRole(userId: userId, role: null);
      }

      return response.session;
    });
  }
}
