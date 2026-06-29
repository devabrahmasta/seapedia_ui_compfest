import 'package:flutter/material.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text(
          'Ringkasan toko akan tersedia di level berikutnya',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}