import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(activeRoleProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${activeRole ?? ''}'.trim()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              // ref.read(activeRoleProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Selamat datang, role : ${activeRole ?? 'tidak ada'}'),
      ),
    );
  }
}
