import 'package:flutter/material.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';

class DriverProfileSection extends StatefulWidget {
  const DriverProfileSection({super.key});

  @override
  State<DriverProfileSection> createState() => _DriverProfileSectionState();
}

class _DriverProfileSectionState extends State<DriverProfileSection> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Status: ${_isAvailable ? 'Tersedia' : 'Tidak Tersedia'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: _isAvailable,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _isAvailable = value),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Total Pendapatan',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text('Rp -', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Material(
              color: Colors.transparent,
              child: _MenuTile(icon: Icons.history, label: 'Riwayat Pengantaran'),
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