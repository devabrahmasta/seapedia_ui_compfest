import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_search_bar.dart';
import 'package:seapedia_ui_compfest/core/widgets/product_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/product/data/product_repository.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/product_filter.dart';

class ProductListingScreen extends ConsumerStatefulWidget {
  final bool autofocus;

  const ProductListingScreen({super.key, this.autofocus = false});

  @override
  ConsumerState<ProductListingScreen> createState() =>
      _ProductListingScreenState();
}

class _ProductListingScreenState extends ConsumerState<ProductListingScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ProductFilter _filter = const ProductFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final result = await showProductFilterSheet(context, _filter);
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _filter = _filter.copyWith(
        categories: {..._filter.categories}..remove(category),
      );
    });
  }

  void _removePriceSort() {
    setState(() {
      _filter = _filter.copyWith(priceSort: PriceSort.none);
    });
  }

  void _removeRating() {
    setState(() {
      _filter = _filter.copyWith(minRating: 0);
    });
  }

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    var products = allProducts.where((product) {
      if (_query.isNotEmpty) {
        final keyword = _query.toLowerCase();
        final matchesQuery =
            product.name.toLowerCase().contains(keyword) ||
            product.storeName.toLowerCase().contains(keyword);
        if (!matchesQuery) return false;
      }

      // Filter kategori dimatikan sementara karena model Product asli belum punya field category
      /*
      if (_filter.categories.isNotEmpty && !_filter.categories.contains(product.category)) {
        return false;
      }
      */

      // Filter rating dimatikan sementara karena model Product asli belum punya field rating
      /*
      if (product.rating < _filter.minRating) {
        return false;
      }
      */

      return true;
    }).toList();

    if (_filter.priceSort == PriceSort.lowToHigh) {
      products.sort((a, b) => a.price.compareTo(b.price));
    } else if (_filter.priceSort == PriceSort.highToLow) {
      products.sort((a, b) => b.price.compareTo(a.price));
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Semua Produk'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.screenPaddingHorizontal,
            child: Column(
              children: [
                const SizedBox(height: 12),
                AppSearchBar(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  autofocus: widget.autofocus,
                ),
                const SizedBox(height: 16),
                _FilterChipRow(
                  filter: _filter,
                  onFilterTap: _openFilterSheet,
                  onRemoveCategory: _removeCategory,
                  onRemovePriceSort: _removePriceSort,
                  onRemoveRating: _removeRating,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  const Center(child: Text('Gagal memuat produk')),
              data: (allProducts) {
                final filteredProducts = _getFilteredProducts(allProducts);

                if (filteredProducts.isEmpty) {
                  return const _EmptyState();
                }

                return SingleChildScrollView(
                  padding: AppSpacing.screenPaddingHorizontal,
                  child: MasonryGridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final ProductFilter filter;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onRemoveCategory;
  final VoidCallback onRemovePriceSort;
  final VoidCallback onRemoveRating;

  const _FilterChipRow({
    required this.filter,
    required this.onFilterTap,
    required this.onRemoveCategory,
    required this.onRemovePriceSort,
    required this.onRemoveRating,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Filter',
            icon: Icons.tune,
            isActive: false,
            onTap: onFilterTap,
          ),
          const SizedBox(width: 10),
          if (filter.priceSort != PriceSort.none) ...[
            _Chip(
              label: filter.priceSort == PriceSort.lowToHigh
                  ? 'Termurah'
                  : 'Termahal',
              isActive: true,
              onTap: onRemovePriceSort,
            ),
            const SizedBox(width: 10),
          ],
          /* Filter kategori dan rating disembunyikan sementara
          if (filter.minRating > 0) ...[
            _Chip(
              label: '${filter.minRating}+',
              isActive: true,
              onTap: onRemoveRating,
            ),
            const SizedBox(width: 10),
          ],
          ...filter.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _Chip(
                label: category,
                isActive: true,
                onTap: () => onRemoveCategory(category),
              ),
            );
          }),
          */
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              const Icon(Icons.close, size: 14, color: AppColors.onPrimary),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'Produk tidak ditemukan',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci atau filter lain',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
