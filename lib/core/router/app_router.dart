import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/auth/application/active_role_provider.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/dashboard_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/login_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/register_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/role_selection.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final session = ref.read(authProvider).value;
      final activeRole = ref.read(activeRoleProvider);
      final isLoggedIn = session != null;
      final path = state.matchedLocation;

      final isAuthPage = path == '/login' || path == '/register';

      if (!isLoggedIn) {
        if (isAuthPage) return null;
        return '/login';
      }

      if (isLoggedIn && isAuthPage) {
        return '/';
      }

      if (path == '/select-role') {
        return null;
      }

      if (activeRole == null) {
        return '/select-role';
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
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});