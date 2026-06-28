import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';

final userRolesProvider = FutureProvider<List<String>>((ref) async {
  final session = ref.watch(authProvider).value;
  if (session == null) return [];
  final profileRepository = ref.read(profileRepositoryProvider);
  return profileRepository.getUserRoles(session.user.id);
});
