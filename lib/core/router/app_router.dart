import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/login_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/main_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/register_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/role_selection.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/landing_screen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/product_detail_screeen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/product_listing_screen.dart';

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
  ref.listen(
    activeRoleProvider,
    (previous, next) => refreshController.add(null),
  );

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
      final isPublicPage = path == '/' || path.startsWith('/product');

      if (authState.isLoading && !authState.hasValue) return null;

      if (!isLoggedIn) {
        if (isAuthPage || isPublicPage) return null;
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
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final autofocus = state.uri.queryParameters['focus'] == 'true';
          return ProductListingScreen(autofocus: autofocus);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const LandingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) =>
                    const Center(child: Text('Search Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) =>
                    const Center(child: Text('Cart Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) =>
                    const Center(child: Text('Orders Page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const Center(child: Text('Profile Page')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
