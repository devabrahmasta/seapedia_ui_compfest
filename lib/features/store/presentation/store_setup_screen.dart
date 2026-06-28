import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/utils/auth_error_mapper.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final storeName = _storeNameController.text.trim();
    final description = _descriptionController.text.trim();

    if (storeName.isEmpty) {
      setState(() => _error = 'Nama toko wajib diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final session = ref.read(authProvider).value;
      final repository = ref.read(storeRepositoryProvider);
      await repository.createStore(
        sellerId: session!.user.id,
        storeName: storeName,
        description: description.isEmpty ? null : description,
      );
      ref.invalidate(myStoreProvider);
      if (mounted) context.go('/');
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
                'Buat Toko Kamu',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi info toko sebelum mulai berjualan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Nama Toko',
                controller: _storeNameController,
                prefixIcon: Icons.storefront_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Deskripsi (opsional)',
                controller: _descriptionController,
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
                label: _isSubmitting ? 'Menyimpan...' : 'Buat Toko',
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}