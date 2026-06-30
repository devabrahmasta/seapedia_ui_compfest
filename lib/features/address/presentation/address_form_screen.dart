import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/address/application/address_provider.dart';
import 'package:seapedia_ui_compfest/features/address/data/address_repository.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/core/utils/validators.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final Address? existingAddress;

  const AddressFormScreen({super.key, this.existingAddress});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _fullAddressController;
  late bool _isDefault;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existingAddress?.label,
    );
    _fullAddressController = TextEditingController(
      text: widget.existingAddress?.fullAddress,
    );
    _isDefault = widget.existingAddress?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final label = _labelController.text.trim();
    final fullAddress = _fullAddressController.text.trim();

    final labelError = Validators.validateRequired(label, 'Label Alamat');
    final addressError = Validators.validateRequired(fullAddress, 'Alamat Lengkap');

    if (labelError != null || addressError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(labelError ?? addressError!)),
      );
      return;
    }

    final userId = ref.read(authProvider).value?.user.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(addressRepositoryProvider);

      if (widget.existingAddress != null) {
        await repository.updateAddress(
          addressId: widget.existingAddress!.id,
          userId: userId,
          label: label,
          fullAddress: fullAddress,
          isDefault: _isDefault,
        );
      } else {
        await repository.createAddress(
          userId: userId,
          label: label,
          fullAddress: fullAddress,
          isDefault: _isDefault,
        );
      }

      ref.invalidate(myAddressesProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAddress != null
                  ? 'Alamat berhasil diperbarui'
                  : 'Alamat berhasil ditambahkan',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Ubah Alamat' : 'Tambah Alamat')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingHorizontal.add(
          const EdgeInsets.symmetric(vertical: 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Label Alamat', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Rumah, Kantor, dll',
              controller: _labelController,
              maxLength: 50,
            ),
            const SizedBox(height: 20),
            Text(
              'Alamat Lengkap',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Tulis alamat lengkap, patokan, kode pos...',
              controller: _fullAddressController,
              maxLines: 4,
              maxLength: 255,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadikan alamat utama',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Switch(
                  value: _isDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => setState(() => _isDefault = value),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppButton(
            label: 'Simpan Alamat',
            onPressed: _handleSave,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
