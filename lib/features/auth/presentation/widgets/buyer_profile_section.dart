import 'package:flutter/material.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';

class BuyerProfileSection extends StatelessWidget {
  const BuyerProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saldo Wallet',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Rp -', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alamat Saya',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  _MenuTile(icon: Icons.favorite_border, label: 'Wishlist'),
                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                  _MenuTile(icon: Icons.confirmation_number_outlined, label: 'Voucher Saya'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: () {},
    );
  }
}