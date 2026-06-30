import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';
import 'package:seapedia_ui_compfest/core/utils/validators.dart';

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

  XFile? _selectedImage;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

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
    final priceStr = _priceController.text.trim();
    final stockStr = _stockController.text.trim();

    final nameError = Validators.validateRequired(name, 'Nama Produk');
    final descError = Validators.validateRequired(description, 'Deskripsi');
    final priceError = Validators.validatePositiveNumber(priceStr, 'Harga');
    final stockError = Validators.validatePositiveInteger(stockStr, 'Stok');

    if (nameError != null) {
      setState(() => _error = nameError);
      return;
    }
    if (descError != null) {
      setState(() => _error = descError);
      return;
    }
    if (priceError != null) {
      setState(() => _error = priceError);
      return;
    }
    if (stockError != null) {
      setState(() => _error = stockError);
      return;
    }

    final price = double.parse(priceStr);
    final stock = int.parse(stockStr);

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      String? imageUrl = widget.existingProduct?.imageUrl;

      if (_isEditing) {
        if (_selectedImage != null) {
          imageUrl = await repository.uploadProductImage(
            widget.existingProduct!.storeId,
            File(_selectedImage!.path),
          );
        }
        await repository.updateProduct(
          productId: widget.existingProduct!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          imageUrl: imageUrl,
        );
      } else {
        final store = await ref.read(myStoreProvider.future);
        if (store == null) {
          setState(
            () => _error = 'Buat toko terlebih dahulu sebelum menambah produk',
          );
          setState(() => _isSubmitting = false);
          return;
        }
        if (_selectedImage != null) {
          imageUrl = await repository.uploadProductImage(
            store.id,
            File(_selectedImage!.path),
          );
        }
        await repository.createProduct(
          storeId: store.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          imageUrl: imageUrl,
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(File(_selectedImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : (widget.existingProduct?.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    widget.existingProduct!.imageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child:
                      _selectedImage == null &&
                          widget.existingProduct?.imageUrl == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.textTertiary,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tambah Foto Produk',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Nama Produk', 
                controller: _nameController,
                maxLength: 100,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Deskripsi',
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Harga',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Stok',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
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
