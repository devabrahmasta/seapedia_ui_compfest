import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/auth/data/profile_repository.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/widgets/buyer_profile_section.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/widgets/driver_profile_section.dart';
import 'package:seapedia_ui_compfest/features/auth/presentation/widgets/seller_profile_section.dart';

const _roleLabels = {
  'buyer': 'Pembeli',
  'seller': 'Penjual',
  'driver': 'Kurir',
  'admin': 'Admin',
};

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              const Center(child: Text('Gagal memuat profil')),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Belum login'));
            }
            return ListView(
              padding: AppSpacing.screenPaddingHorizontal,
              children: [
                const SizedBox(height: 16),
                _ProfileHeader(profile: profile),
                const SizedBox(height: 20),
                switch (profile.activeRole) {
                  'buyer' => const BuyerProfileSection(),
                  'seller' => const SellerProfileSection(),
                  'driver' => const DriverProfileSection(),
                  _ => const SizedBox.shrink(),
                },
                const SizedBox(height: 20),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15), 
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          if (profile.activeRole == 'admin') ...[
                            _MenuTile(
                              icon: Icons.group_outlined,
                              label: 'Kelola Pengguna',
                            ),
                            const Divider(height: 1, thickness: 1, color: AppColors.border),
                            _MenuTile(
                              icon: Icons.local_offer_outlined,
                              label: 'Kelola Diskon',
                            ),
                            const Divider(height: 1, thickness: 1, color: AppColors.border),
                          ],
                          _MenuTile(
                            icon: Icons.edit_outlined,
                            label: 'Edit Profil',
                          ),
                          const Divider(height: 1, thickness: 1, color: AppColors.border),
                          _MenuTile(icon: Icons.help_outline, label: 'Bantuan'),
                          const Divider(height: 1, thickness: 1, color: AppColors.border),
                          _MenuTile(
                            icon: Icons.info_outline,
                            label: 'Tentang SEAPEDIA',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Material(
                      color: Colors.transparent,
                      child: _MenuTile(
                        icon: Icons.logout,
                        label: 'Logout',
                        isDanger: true,
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu login kembali untuk masuk ke akun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surface,
              child: Text(
                profile.username.isNotEmpty
                    ? profile.username[0].toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName?.isNotEmpty == true
                        ? profile.fullName!
                        : profile.username,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${profile.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mode: ${_roleLabels[profile.activeRole] ?? '-'}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(width: 8),
            if (profile.roles.length > 1)
              OutlinedButton(
                onPressed: () => context.push('/select-role'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Ganti Peran',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDanger;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.danger : AppColors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: isDanger
          ? null
          : const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap ?? () {},
    );
  }
}