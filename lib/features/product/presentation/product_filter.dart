import 'package:flutter/material.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';

enum PriceSort { none, lowToHigh, highToLow }

class ProductFilter {
  final Set<String> categories;
  final PriceSort priceSort;
  final double minRating;

  const ProductFilter({
    this.categories = const {},
    this.priceSort = PriceSort.none,
    this.minRating = 0,
  });

  ProductFilter copyWith({
    Set<String>? categories,
    PriceSort? priceSort,
    double? minRating,
  }) {
    return ProductFilter(
      categories: categories ?? this.categories,
      priceSort: priceSort ?? this.priceSort,
      minRating: minRating ?? this.minRating,
    );
  }

  bool get isActive => categories.isNotEmpty || priceSort != PriceSort.none || minRating > 0;
}

Future<ProductFilter?> showProductFilterSheet(BuildContext context, ProductFilter current) {
  return showModalBottomSheet<ProductFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ProductFilterSheet(initial: current),
  );
}

class _ProductFilterSheet extends StatefulWidget {
  final ProductFilter initial;

  const _ProductFilterSheet({required this.initial});

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  late Set<String> _selectedCategories;
  late PriceSort _priceSort;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    _selectedCategories = {...widget.initial.categories};
    _priceSort = widget.initial.priceSort;
    _minRating = widget.initial.minRating;
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Produk', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          /* Filter kategori dan rating disembunyikan sementara
          Text('Kategori', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dummyCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return GestureDetector(
                onTap: () => _toggleCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          */
          Text('Urutkan Harga', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _SortChip(
                label: 'Termurah',
                isSelected: _priceSort == PriceSort.lowToHigh,
                onTap: () => setState(() => _priceSort = _priceSort == PriceSort.lowToHigh ? PriceSort.none : PriceSort.lowToHigh),
              ),
              _SortChip(
                label: 'Termahal',
                isSelected: _priceSort == PriceSort.highToLow,
                onTap: () => setState(() => _priceSort = _priceSort == PriceSort.highToLow ? PriceSort.none : PriceSort.highToLow),
              ),
            ],
          ),
          const SizedBox(height: 20),
          /*
          Text('Rating Minimal', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [4, 4.5].map((value) {
              final isSelected = _minRating == value;
              return _SortChip(
                label: '$value+',
                isSelected: isSelected,
                onTap: () => setState(() => _minRating = isSelected ? 0 : value.toDouble()),
              );
            }).toList(),
          ),
          */
          const SizedBox(height: 24),
          AppButton(
            label: 'Terapkan Filter',
            onPressed: () {
              Navigator.pop(
                context,
                ProductFilter(
                  categories: _selectedCategories,
                  priceSort: _priceSort,
                  minRating: _minRating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}