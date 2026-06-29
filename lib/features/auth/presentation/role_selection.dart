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

class RoleSelectionScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final userRolesAsync = ref.watch(userRolesProvider);

    return Scaffold(
      body: SafeArea(
        child: userRolesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              const Center(child: Text('Gagal memuat peran')),
          data: (ownedRoles) {
            final availableOptions = roleOptions
                .where((opt) => ownedRoles.contains(opt.role))
                .toList();

            return Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Pilih peran untuk sesi ini',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Akun kamu punya beberapa peran. Pilih satu untuk lanjut.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ...availableOptions.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _RoleCard(option: option),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends ConsumerStatefulWidget {
  final RoleOption option;

  const _RoleCard({required this.option});

  @override
  ConsumerState<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends ConsumerState<_RoleCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    setState(() => _isLoading = true);
    await ref.read(activeRoleProvider.notifier).setRole(widget.option.role);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isLoading ? null : _handleTap,
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
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(widget.option.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.option.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    widget.option.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
