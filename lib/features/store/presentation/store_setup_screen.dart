import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/utils/auth_error_mapper.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';
import 'package:seapedia_ui_compfest/features/store/data/store_repository.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  bool _isEditing = false;
  Store? _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(myStoreProvider).value;
      if (store != null) {
        setState(() {
          _isEditing = true;
          _store = store;
          _storeNameController.text = store.storeName;
          _descriptionController.text = store.description ?? '';
          _addressController.text = store.address ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final storeName = _storeNameController.text.trim();
    final description = _descriptionController.text.trim();
    final address = _addressController.text.trim();

    if (storeName.isEmpty) {
      setState(() => _error = 'Nama toko wajib diisi');
      return;
    }
    if (address.isEmpty) {
      setState(() => _error = 'Alamat toko wajib diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final session = ref.read(authProvider).value;
      final repository = ref.read(storeRepositoryProvider);
      
      if (_isEditing && _store != null) {
        await repository.updateStore(
          storeId: _store!.id,
          storeName: _store!.storeName,
          description: description.isEmpty ? null : description,
          address: address,
        );
      } else {
        await repository.createStore(
          sellerId: session!.user.id,
          storeName: storeName,
          description: description.isEmpty ? null : description,
          address: address,
        );
      }
      ref.invalidate(myStoreProvider);
      await ref.read(myStoreProvider.future);
      if (mounted) context.go('/seller/dashboard');
    } catch (error) {
      setState(() => _error = mapAuthError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                _isEditing ? 'Edit Info Toko' : 'Buat Toko Kamu',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isEditing ? 'Perbarui alamat dan deskripsi toko' : 'Lengkapi info toko sebelum mulai berjualan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Nama Toko',
                controller: _storeNameController,
                prefixIcon: Icons.storefront_outlined,
                readOnly: _isEditing,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Deskripsi (opsional)',
                controller: _descriptionController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Alamat Toko',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: _isSubmitting ? 'Menyimpan...' : (_isEditing ? 'Simpan Perubahan' : 'Buat Toko'),
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
