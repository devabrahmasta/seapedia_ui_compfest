import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/login_screen.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/register_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
