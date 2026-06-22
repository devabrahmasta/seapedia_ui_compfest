import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';

class RoleOption {
  final String role;
  final String title;
  final String description;
  final IconData icon;

  const RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const roleOptions = [
    RoleOption(
      role: 'buyer',
      title: 'Pembeli',
      description: 'Belanja & lacak pesanan',
      icon: Icons.shopping_bag_outlined,
    ),
    RoleOption(
      role: 'seller',
      title: 'Penjual',
      description: 'Kelola toko & produk',
      icon: Icons.storefront_outlined,
    ),
    RoleOption(
      role: 'driver',
      title: 'Kurir',
      description: 'Antar pesanan ke pembeli',
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Pilih peran untuk sesi ini',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Akun kamu punya beberapa peran. Pilih satu untuk lanjut.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ...roleOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _RoleCard(option: option),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends ConsumerWidget {
  final RoleOption option;

  const _RoleCard({required this.option});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await ref.read(setActiveRoleProvider)(option.role);
        if (context.mounted) {
          context.go('/${option.role}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: Theme.of(context).textTheme.titleSmall),
                  Text(option.description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}