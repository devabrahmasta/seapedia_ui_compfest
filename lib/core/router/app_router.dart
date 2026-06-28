import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/login_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/main_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/register_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/role_selection.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshController = StreamController<void>.broadcast();

  ref.listen(authProvider, (previous, next) => refreshController.add(null));
  ref.listen(activeRoleProvider, (previous, next) => refreshController.add(null));

  ref.onDispose(() => refreshController.close());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(refreshController.stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final activeRoleState = ref.read(activeRoleProvider);

      final session = authState.value;
      final activeRole = activeRoleState.value;

      final isLoggedIn = session != null;
      final path = state.matchedLocation;
      final isAuthPage = path == '/login' || path == '/register';

      if (authState.isLoading && !authState.hasValue) return null;

      if (!isLoggedIn) {
        if (isAuthPage) return null;
        return '/login';
      }

      if (activeRoleState.isLoading && !activeRoleState.hasValue) {
        return null;
      }

      if (activeRole == null) {
        if (path == '/select-role') return null;
        return '/select-role';
      }

      if (isAuthPage || path == '/select-role') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
    ],
  );
});