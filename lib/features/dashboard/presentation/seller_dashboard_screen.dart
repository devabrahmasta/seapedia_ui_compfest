import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_card.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';
import 'package:seapedia_ui_compfest/features/product/application/product_provider.dart';
import 'package:seapedia_ui_compfest/features/store/application/store_provider.dart';
import 'package:seapedia_ui_compfest/features/order/presentation/widgets/order_summary_card.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  ConsumerState<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _dateFmt = DateFormat('d MMM', 'id_ID');

  bool _isIncomeVisible = false;

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(myStoreProvider);

    return Scaffold(
      body: SafeArea(
        child: storeAsync.when(
          data: (store) {
            if (store == null) {
              return const Center(child: Text('Toko tidak ditemukan'));
            }

            final incomeAsync = ref.watch(storeIncomeProvider(store.id));
            final productsAsync = ref.watch(myProductsProvider);
            final ordersAsync = ref.watch(incomingOrdersProvider);

            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(myStoreProvider);
                ref.refresh(storeIncomeProvider(store.id));
                ref.refresh(myProductsProvider);
                ref.refresh(incomingOrdersProvider);
              },
              child: ListView(
                padding: AppSpacing.screenPaddingHorizontal,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Halo,',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${store.storeName} ',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Section
                  incomeAsync.when(
                    data: (summary) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Pendapatan Bulan Ini',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _isIncomeVisible
                                                            ? _currencyFormatter
                                                                  .format(
                                                                    summary
                                                                        .totalIncome,
                                                                  )
                                                            : 'Rp ••••••••',
                                                        style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _isIncomeVisible
                                                            ? Icons
                                                                  .visibility_outlined
                                                            : Icons
                                                                  .visibility_off_outlined,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _isIncomeVisible =
                                                              !_isIncomeVisible;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(
                                          color: AppColors.border,
                                          height: 1,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Produk Terjual',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                productsAsync.maybeWhen(
                                                  data: (products) =>
                                                      '${products.length}',
                                                  orElse: () => '-',
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Rating Toko',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const Text(
                                                '4.6', // Mock Rating
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),

                  const SizedBox(height: 32),

                  // Orders Section
                  ordersAsync.when(
                    data: (orders) {
                      final perluDiproses = orders
                          .where((o) => o.status == 'Sedang Dikemas')
                          .toList();
                      final menungguKurir = orders
                          .where(
                            (o) =>
                                o.status == 'Menunggu Pengirim' ||
                                o.status == 'Sedang Dikirim',
                          )
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            title: 'Perlu Diproses',
                            iconColor: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          if (perluDiproses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Text(
                                'Tidak ada pesanan perlu diproses',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            ...perluDiproses.map(
                              (o) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OrderSummaryCard(
                                  order: o,
                                  dateFmt: _dateFmt,
                                  priceFmt: _currencyFormatter,
                                  onTap: () => context.push('/order/${o.id}'),
                                  accentColor: AppColors.primary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          const SectionHeader(title: 'Menunggu Kurir'),
                          const SizedBox(height: 12),
                          if (menungguKurir.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Text(
                                'Tidak ada pesanan menunggu kurir',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            ...menungguKurir.map(
                              (o) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OrderSummaryCard(
                                  order: o,
                                  dateFmt: _dateFmt,
                                  priceFmt: _currencyFormatter,
                                  onTap: () => context.push('/order/${o.id}'),
                                ),
                              ),
                            ),
                          const SizedBox(height: 32), // bottom padding
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
