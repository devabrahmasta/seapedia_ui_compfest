import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/order_status.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color? iconColor;

  const SectionHeader({super.key, required this.title, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (iconColor != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  final OrderSummary order;
  final DateFormat dateFmt;
  final NumberFormat priceFmt;
  final VoidCallback onTap;
  final Color? accentColor;

  const OrderSummaryCard({
    super.key,
    required this.order,
    required this.dateFmt,
    required this.priceFmt,
    required this.onTap,
    this.accentColor,
  });

  String _buyerDisplay() {
    final name = order.buyerName;
    if (name != null && name.isNotEmpty) return name;
    return 'Pembeli';
  }

  @override
  Widget build(BuildContext context) {
    final itemLabel = order.itemNames.isEmpty
        ? '–'
        : order.itemNames.join(', ');

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (accentColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.surface,
                      child: Text(
                        _buyerDisplay().characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _buyerDisplay(),
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      dateFmt.format(order.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            itemLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            children: [
              Icon(
                orderStatusIcon(order.status),
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.status,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                priceFmt.format(order.total),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
