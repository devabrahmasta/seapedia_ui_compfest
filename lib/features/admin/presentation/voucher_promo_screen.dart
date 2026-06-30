import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/features/promo/application/promo_provider.dart';
import 'package:seapedia_ui_compfest/features/promo/data/promo_repository.dart';

class VoucherPromoScreen extends ConsumerStatefulWidget {
  const VoucherPromoScreen({super.key});

  @override
  ConsumerState<VoucherPromoScreen> createState() => _VoucherPromoScreenState();
}

class _VoucherPromoScreenState extends ConsumerState<VoucherPromoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Voucher & Promo',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                context.go('/admin/vouchers/new-voucher');
              } else {
                context.go('/admin/vouchers/new-promo');
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: AppSpacing.screenPaddingHorizontal.copyWith(bottom: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.primary,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.onPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Voucher'),
                  Tab(text: 'Promo'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_VoucherList(), _PromoList()],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 16.0),
      //   child: FloatingActionButton.extended(
      //     onPressed: () {
      //       if (_tabController.index == 0) {
      //         context.go('/admin/vouchers/new-voucher');
      //       } else {
      //         context.go('/admin/vouchers/new-promo');
      //       }
      //     },
      //     backgroundColor: const Color(0xFF60BA62),
      //     icon: const Icon(Icons.add, color: Colors.white),
      //     label: const Text(
      //       'Buat Baru',
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontFamily: 'Poppins',
      //         fontWeight: FontWeight.w600,
      //       ),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _VoucherList extends ConsumerWidget {
  const _VoucherList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allVouchersProvider);

    return state.when(
      data: (vouchers) {
        if (vouchers.isEmpty) {
          return const Center(child: Text('Belum ada voucher'));
        }
        return RefreshIndicator(
          color: const Color(0xFF60BA62),
          onRefresh: () async => ref.invalidate(allVouchersProvider),
          child: ListView.separated(
            padding: AppSpacing.screenPaddingHorizontal.add(
              const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            ),
            itemCount: vouchers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              return _PromoItemCard(promo: voucher);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF60BA62)),
      ),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _PromoList extends ConsumerWidget {
  const _PromoList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allPromosProvider);

    return state.when(
      data: (promos) {
        if (promos.isEmpty) {
          return const Center(child: Text('Belum ada promo'));
        }
        return RefreshIndicator(
          color: const Color(0xFF60BA62),
          onRefresh: () async => ref.invalidate(allPromosProvider),
          child: ListView.separated(
            padding: AppSpacing.screenPaddingHorizontal.add(
              const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            ),
            itemCount: promos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return _PromoItemCard(promo: promo);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF60BA62)),
      ),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _PromoItemCard extends StatelessWidget {
  final PromoCode promo;

  const _PromoItemCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final isExpired = promo.expiryDate.isBefore(DateTime.now());
    final isDepleted =
        promo.source == PromoSource.voucher &&
        (promo.usageCount ?? 0) >= (promo.usageLimit ?? 1);
    final isInactive = isExpired || isDepleted;

    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final formattedDate = dateFormat.format(promo.expiryDate);

    String discountText = '';
    if (promo.discountType == 'percentage') {
      discountText = '${promo.discountValue.toInt()}% off';
    } else {
      final currencyFmt = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      discountText = '${currencyFmt.format(promo.discountValue)} off';
    }

    return InkWell(
      onTap: () {
        context.go('/admin/vouchers/${promo.code}', extra: promo);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  promo.code,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (promo.source == PromoSource.voucher)
                  Text(
                    '${promo.usageCount}/${promo.usageLimit} terpakai',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              discountText,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: isInactive ? Colors.black54 : const Color(0xFF60BA62),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
              child: isInactive
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              isInactive
                  ? 'Habis · kadaluarsa $formattedDate'
                  : 'Kadaluarsa $formattedDate',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
