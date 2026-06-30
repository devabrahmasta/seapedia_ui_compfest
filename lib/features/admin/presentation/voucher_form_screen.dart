import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/core/utils/validators.dart';
import 'package:seapedia_ui_compfest/features/promo/application/promo_provider.dart';

class VoucherFormScreen extends ConsumerStatefulWidget {
  const VoucherFormScreen({super.key});

  @override
  ConsumerState<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends ConsumerState<VoucherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _limitController = TextEditingController();

  String _discountType = 'fixed';
  DateTime? _expiryDate;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF60BA62),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal kadaluarsa terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = _codeController.text.trim();
      final limitStr = _limitController.text.trim();
      final valStr = _valueController.text.trim();

      final codeError = Validators.validateRequired(code, 'Kode Voucher');
      final limitError = Validators.validatePositiveInteger(limitStr, 'Limit Penggunaan');
      final valError = Validators.validatePositiveNumber(valStr, 'Nilai Diskon');

      if (codeError != null) {
        setState(() => _error = codeError);
        return;
      }
      if (limitError != null) {
        setState(() => _error = limitError);
        return;
      }
      if (valError != null) {
        setState(() => _error = valError);
        return;
      }

      final usageLimit = int.parse(limitStr);
      final discountValue = double.parse(valStr);

      if (_discountType == 'percentage' && discountValue > 100) {
        setState(() => _error = 'Nilai diskon persentase tidak boleh lebih dari 100%');
        return;
      }

      await ref.read(promoRepositoryProvider).createVoucher(
            code: code,
            discountValue: discountValue,
            discountType: _discountType,
            usageLimit: usageLimit,
            expiryDate: _expiryDate!,
          );

      ref.invalidate(allVouchersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voucher berhasil dibuat')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat voucher: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Voucher Baru',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingHorizontal.add(
          const EdgeInsets.symmetric(vertical: 24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              AppTextField(
                label: 'Kode Voucher (Contoh: ONGKIR10K)',
                controller: _codeController,
                maxLength: 20,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _discountType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Diskon',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF60BA62)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text('Nominal Tetap (Rp)'),
                  ),
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Persentase (%)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _discountType = val);
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nilai Diskon',
                controller: _valueController,
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Batas Penggunaan',
                controller: _limitController,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Kadaluarsa',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF60BA62)),
                    ),
                  ),
                  child: Text(
                    _expiryDate == null
                        ? 'Pilih Tanggal'
                        : DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(_expiryDate!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60BA62),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Voucher',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
