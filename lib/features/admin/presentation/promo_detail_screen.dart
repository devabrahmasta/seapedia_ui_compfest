import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/features/promo/data/promo_repository.dart';

class PromoDetailScreen extends StatelessWidget {
  final PromoCode promo;

  const PromoDetailScreen({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    final isVoucher = promo.source == PromoSource.voucher;
    final isExpired = promo.expiryDate.isBefore(DateTime.now());
    final isDepleted =
        isVoucher && (promo.usageCount ?? 0) >= (promo.usageLimit ?? 1);
    final isInactive = isExpired || isDepleted;

    final dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');
    final formattedDate = dateFormat.format(promo.expiryDate);

    String discountText = '';
    if (promo.discountType == 'percentage') {
      discountText = '${promo.discountValue.toInt()}%';
    } else {
      final currencyFmt = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      discountText = currencyFmt.format(promo.discountValue);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isVoucher ? 'Detail Voucher' : 'Detail Promo',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingHorizontal.add(
          const EdgeInsets.symmetric(vertical: 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Column(
                children: [
                  Text(
                    promo.code,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isInactive
                          ? Colors.black12
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isInactive ? 'Tidak Aktif' : 'Aktif',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: isInactive
                            ? Colors.black54
                            : const Color(0xFF60BA62),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Informasi Diskon',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Tipe',
              value: promo.discountType == 'percentage'
                  ? 'Persentase'
                  : 'Nominal Tetap',
            ),
            const Divider(color: Color(0xFFE5E5E5), height: 32),
            _DetailRow(label: 'Nilai Diskon', value: discountText),
            const Divider(color: Color(0xFFE5E5E5), height: 32),
            _DetailRow(label: 'Kadaluarsa', value: formattedDate),
            if (isVoucher) ...[
              const Divider(color: Color(0xFFE5E5E5), height: 32),
              _DetailRow(
                label: 'Batas Penggunaan',
                value: '${promo.usageLimit} kali',
              ),
              const Divider(color: Color(0xFFE5E5E5), height: 32),
              _DetailRow(
                label: 'Telah Digunakan',
                value: '${promo.usageCount} kali',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
