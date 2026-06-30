import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/wallet/application/wallet_provider.dart';
import 'package:seapedia_ui_compfest/features/wallet/data/wallet_repository.dart';

class TopUpBottomSheet extends ConsumerStatefulWidget {
  final Wallet wallet;

  const TopUpBottomSheet({super.key, required this.wallet});

  @override
  ConsumerState<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends ConsumerState<TopUpBottomSheet> {
  final List<double> _presetNominals = [50000, 100000, 200000, 500000];
  double? _selectedPreset;
  final TextEditingController _customAmountController = TextEditingController();
  bool _isLoading = false;

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _onPresetSelected(double nominal) {
    setState(() {
      if (_selectedPreset == nominal) {
        _selectedPreset = null;
      } else {
        _selectedPreset = nominal;
        _customAmountController.clear();
      }
    });
  }

  Future<void> _handleTopUp() async {
    double amount = 0;
    if (_selectedPreset != null) {
      amount = _selectedPreset!;
    } else if (_customAmountController.text.isNotEmpty) {
      amount = double.tryParse(_customAmountController.text) ?? 0;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(walletRepositoryProvider);
      await repository.topUp(
        walletId: widget.wallet.id,
        amount: amount,
        currentBalance: widget.wallet.balance,
      );

      ref.invalidate(myWalletProvider);
      ref.invalidate(walletTransactionsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Top up berhasil: ${_formatter.format(amount)}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Top up gagal: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Top Up Saldo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetNominals.map((nominal) {
              final isSelected = _selectedPreset == nominal;
              return GestureDetector(
                onTap: () => _onPresetSelected(nominal),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 40 - 12) / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _formatter.format(nominal),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Atau masukkan jumlah lain',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Rp 0',
            controller: _customAmountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Konfirmasi Top Up',
            onPressed: _handleTopUp,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
