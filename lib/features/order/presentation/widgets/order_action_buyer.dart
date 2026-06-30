import 'package:flutter/material.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';

class OrderActionBuyer extends StatelessWidget {
  final Order order;

  const OrderActionBuyer({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status != 'Sedang Dikemas') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: null,
        child: Text(
          'Hubungi Penjual',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
