import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/login_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/main_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/profile_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/register_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/role_selection.dart';
import 'package:seapedia_ui_compfest/features/dashboard/presentation/seller_dashboard_screen.dart';
import 'package:seapedia_ui_compfest/features/dashboard/presentation/seller_report_screen.dart';
import 'package:seapedia_ui_compfest/features/dashboard/presentation/seller_main_screen.dart';
import 'package:seapedia_ui_compfest/features/dashboard/presentation/driver_main_screen.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/driver_earnings_screen.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/job_completed_screen.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/job_detail_screen.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/job_history_screen.dart';
import 'package:seapedia_ui_compfest/features/delivery/presentation/job_search_screen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/landing_screen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/product_detail_screeen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/product_form_screen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/product_listing_screen.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/seller_product_list_screen.dart';
import 'package:seapedia_ui_compfest/features/reviews/presentation/write_review_screen.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';
import 'package:seapedia_ui_compfest/features/store/presentation/store_public_screen.dart';
import 'package:seapedia_ui_compfest/features/store/presentation/store_setup_screen.dart';
import 'package:seapedia_ui_compfest/features/address/data/address_repository.dart';
import 'package:seapedia_ui_compfest/features/address/presentation/address_form_screen.dart';
import 'package:seapedia_ui_compfest/features/address/presentation/address_list_screen.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';
import 'package:seapedia_ui_compfest/features/cart/presentation/cart_screen.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/checkout_screen.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/my_orders_screen.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/incoming_orders_screen.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/order_detail_screen.dart';
import 'package:seapedia_ui_compfest/features/promo/data/promo_repository.dart';
import 'package:seapedia_ui_compfest/features/promo/presentation/promo_selection_screen.dart';
import 'package:seapedia_ui_compfest/features/wallet/presentation/wallet_screen.dart';

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
  ref.listen(myStoreProvider, (previous, next) => refreshController.add(null));

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
      final isPublicPage =
          path == '/' ||
          path == '/search' ||
          path.startsWith('/product') ||
          path.startsWith('/store') ||
          path == '/write-review';

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

      if (activeRole == 'seller') {
        if (path == '/select-role') return null;

        if (path != '/store-setup') {
          final storeState = ref.read(myStoreProvider);
          if (storeState.isLoading && !storeState.hasValue) return null;
          if (storeState.value == null) return '/store-setup';
        }
        if (!path.startsWith('/seller') &&
            path != '/store-setup' &&
            !path.startsWith('/product') &&
            !path.startsWith('/store/') &&
            !path.startsWith('/order/')) {
          return '/seller/dashboard';
        }
      }

      if (activeRole == 'driver') {
        if (path == '/select-role') return null;
        if (!path.startsWith('/driver') &&
            !path.startsWith('/order/') &&
            !path.startsWith('/product')) {
          return '/driver/jobs';
        }
      }

      if (isAuthPage) {
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
      GoRoute(
        path: '/write-review',
        builder: (context, state) => const WriteReviewScreen(),
      ),
      GoRoute(
        path: '/store-setup',
        builder: (context, state) => const StoreSetupScreen(),
      ),
      GoRoute(
        path: '/store/:id',
        builder: (context, state) {
          final storeId = state.pathParameters['id']!;
          return StorePublicScreen(storeId: storeId);
        },
      ),

      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/driver/job-completed',
        builder: (context, state) {
          final earning = state.extra as double;
          return JobCompletedScreen(earning: earning);
        },
      ),
      GoRoute(
        path: '/promo-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PromoSelectionScreen(
            subtotal: extra['subtotal'] as double,
            selectedPromo: extra['selectedPromo'] as PromoCode?,
          );
        },
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const AddressFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              final address = state.extra as Address;
              return AddressFormScreen(existingAddress: address);
            },
          ),
        ],
      ),

      // Buyer mainscreen
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
                    const ProductListingScreen(autofocus: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const MyOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Seller  mainscreen
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SellerMainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/dashboard',
                builder: (context, state) => const SellerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/products',
                builder: (context, state) => const SellerProductListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final product = state.extra as Product;
                      return ProductFormScreen(existingProduct: product);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/orders',
                builder: (context, state) => const IncomingOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/reports',
                builder: (context, state) => const SellerReportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Driver mainscreen
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DriverMainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/jobs',
                builder: (context, state) => const JobSearchScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return JobDetailScreen(jobId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/history',
                builder: (context, state) => const JobHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/earnings',
                builder: (context, state) => const DriverEarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
