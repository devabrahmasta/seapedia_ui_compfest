import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? existingProduct;

  const ProductFormScreen({this.existingProduct, super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  late final _nameController = TextEditingController(
    text: widget.existingProduct?.name ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.existingProduct?.description ?? '',
  );
  late final _priceController = TextEditingController(
    text: widget.existingProduct?.price.toStringAsFixed(0) ?? '',
  );
  late final _stockController = TextEditingController(
    text: widget.existingProduct?.stock.toString() ?? '',
  );

  bool _isSubmitting = false;
  String? _error;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());

    if (name.isEmpty || price == null || stock == null) {
      setState(() => _error = 'Lengkapi semua data dengan benar');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);

      if (_isEditing) {
        await repository.updateProduct(
          productId: widget.existingProduct!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          imageUrl: widget.existingProduct!.imageUrl,
        );
      } else {
        final store = await ref.read(myStoreProvider.future);
        await repository.createProduct(
          storeId: store!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
        );
      }

      ref.invalidate(myProductsProvider);
      if (mounted) context.pop();
    } catch (error) {
      setState(() => _error = 'Gagal menyimpan produk');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: AppColors.textTertiary, size: 32),
                    SizedBox(height: 8),
                    Text('Tambah Foto Produk', style: TextStyle(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(label: 'Nama Produk', controller: _nameController),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Deskripsi',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Harga',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Stok',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: _isSubmitting ? 'Menyimpan...' : 'Simpan Produk',
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}