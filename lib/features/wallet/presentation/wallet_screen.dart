import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/features/wallet/application/wallet_provider.dart';
import 'package:seapedia_ui_compfest/features/wallet/data/wallet_repository.dart';
import 'package:seapedia_ui_compfest/features/wallet/presentation/top_up_bottom_sheet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(myWalletProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Saya')),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat wallet: $e')),
        data: (wallet) {
          if (wallet == null) return const SizedBox.shrink();
          return _WalletContent(wallet: wallet, formatter: _formatter);
        },
      ),
    );
  }
}

class _WalletContent extends ConsumerWidget {
  final Wallet wallet;
  final NumberFormat formatter;

  const _WalletContent({required this.wallet, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return ListView(
      padding: AppSpacing.screenPaddingHorizontal.add(
        const EdgeInsets.symmetric(vertical: 24),
      ),
      children: [
        _BalanceCard(
          balance: wallet.balance,
          formatter: formatter,
          onTopUp: () => _showTopUp(context, wallet),
        ),
        const SizedBox(height: 28),
        Text(
          'Riwayat Transaksi',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        transactionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            'Gagal memuat riwayat: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    'Belum ada transaksi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }
            return Column(
              children: transactions
                  .map((t) => _TransactionTile(
                        transaction: t,
                        formatter: formatter,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _showTopUp(BuildContext context, Wallet wallet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TopUpBottomSheet(wallet: wallet),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final NumberFormat formatter;
  final VoidCallback onTopUp;

  const _BalanceCard({
    required this.balance,
    required this.formatter,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Kamu',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(balance),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          AppButton(label: '+ Top Up', onPressed: onTopUp),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  final NumberFormat formatter;

  const _TransactionTile({
    required this.transaction,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isTopUp = transaction.isTopUp;
    final amountColor = isTopUp ? AppColors.primary : AppColors.textPrimary;
    final amountText =
        '${isTopUp ? '+' : '-'}${formatter.format(transaction.amount)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTopUp ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ??
                      (isTopUp ? 'Top Up' : 'Pembayaran Pesanan'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
