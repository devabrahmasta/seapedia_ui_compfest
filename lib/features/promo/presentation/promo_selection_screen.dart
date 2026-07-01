import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/features/promo/application/promo_provider.dart';
import 'package:seapedia_ui_compfest/features/promo/data/promo_repository.dart';

class PromoSelectionScreen extends ConsumerStatefulWidget {
  final double subtotal;
  final PromoCode? selectedPromo;

  const PromoSelectionScreen({
    super.key,
    required this.subtotal,
    this.selectedPromo,
  });

  @override
  ConsumerState<PromoSelectionScreen> createState() =>
      _PromoSelectionScreenState();
}

class _PromoSelectionScreenState extends ConsumerState<PromoSelectionScreen> {
  static final _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final _codeController = TextEditingController();
  String? _manualError;
  bool _isApplying = false;
  String? _applyingCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _errorMessage(Object e, String code) {
    if (e is PromoExpiredException) return 'Kode sudah kadaluarsa';
    if (e is PromoUsageLimitExceededException) {
      return 'Kode sudah mencapai batas penggunaan';
    }
    return 'Kode tidak valid';
  }

  Future<void> _applyManualCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _manualError = 'Masukkan kode promo');
      return;
    }
    setState(() {
      _isApplying = true;
      _manualError = null;
    });
    try {
      final promo = await ref.read(promoRepositoryProvider).validateCode(code);
      if (!mounted) return;
      context.pop(promo);
    } catch (e) {
      if (!mounted) return;
      setState(() => _manualError = _errorMessage(e, code));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _selectFromList(PromoCode promo) async {
    setState(() => _applyingCode = promo.code);
    try {
      final validated = await ref
          .read(promoRepositoryProvider)
          .validateCode(promo.code);
      if (!mounted) return;
      context.pop(validated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(e, promo.code))));
    } finally {
      if (mounted) setState(() => _applyingCode = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(availablePromosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Pilih Promo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.screenPaddingHorizontal.add(
          const EdgeInsets.symmetric(vertical: 16),
        ),
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kode promo',
                    hintStyle: TextStyle(fontSize: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: _manualError != null
                            ? AppColors.danger
                            : AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: _manualError != null
                            ? AppColors.danger
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: _manualError != null
                            ? AppColors.danger
                            : AppColors.border,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: AppButton(
                  onPressed: _isApplying ? null : _applyManualCode,
                  label: 'Terapkan',
                ),
              ),
            ],
          ),
          if (_manualError != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 4),
                Text(
                  _manualError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text('Promo Tersedia', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          promosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Gagal memuat promo: $e')),
            data: (promos) {
              if (promos.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada promo tersedia saat ini',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final promo in promos) ...[
                    _PromoListCard(
                      promo: promo,
                      fmt: _fmt,
                      subtotal: widget.subtotal,
                      isSelected: widget.selectedPromo?.id == promo.id,
                      isLoading: _applyingCode == promo.code,
                      onTap: () => _selectFromList(promo),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PromoListCard extends StatelessWidget {
  final PromoCode promo;
  final NumberFormat fmt;
  final double subtotal;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  static final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');

  const _PromoListCard({
    required this.promo,
    required this.fmt,
    required this.subtotal,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  String get _description {
    final discount = promo.calculateDiscount(subtotal);
    if (promo.discountType == 'percentage') {
      return 'Diskon ${promo.discountValue.toStringAsFixed(0)}% s.d ${fmt.format(discount)}';
    }
    return 'Diskon ${fmt.format(promo.discountValue)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : AppColors.background,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 22,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.code,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Berlaku s.d ${_dateFmt.format(promo.expiryDate.toLocal())}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Pakai'),
                ),
        ],
      ),
    );
  }
}
