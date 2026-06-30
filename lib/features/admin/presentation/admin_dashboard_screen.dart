import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/features/admin/application/admin_provider.dart';
import 'package:seapedia_ui_compfest/features/order/application/order_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final offset = ref.watch(simulatedTimeOffsetProvider);
              return TextButton.icon(
                onPressed: () {
                  ref.read(simulatedTimeOffsetProvider.notifier).increment();
                  // Also refresh the counts
                  ref.invalidate(overdueOrderCountProvider);
                },
                icon: const Icon(Icons.fast_forward, color: Color(0xFF60BA62)),
                label: Text(
                  '+$offset Hari',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF60BA62),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF60BA62),
        onRefresh: () async {
          ref.invalidate(userCountProvider);
          ref.invalidate(storeCountProvider);
          ref.invalidate(productCountProvider);
          ref.invalidate(orderCountByStatusProvider);
          ref.invalidate(voucherPromoCountProvider);
          ref.invalidate(deliveryJobCountByStatusProvider);
          ref.invalidate(overdueOrderCountProvider);
          ref.invalidate(overdueOrdersListProvider);
        },
        child: ListView(
          padding: AppSpacing.screenPaddingHorizontal.add(
            const EdgeInsets.symmetric(vertical: 24),
          ),
          children: const [
            _UsersCard(),
            SizedBox(height: 16),
            _StoresCard(),
            SizedBox(height: 16),
            _ProductsCard(),
            SizedBox(height: 16),
            _OrdersCard(),
            SizedBox(height: 16),
            _VoucherPromoCard(),
            SizedBox(height: 16),
            _DeliveryJobsCard(),
            SizedBox(height: 16),
            _OverdueOrdersCard(),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF60BA62), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _UsersCard extends ConsumerWidget {
  const _UsersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userCountProvider);
    return _DashboardCard(
      title: 'Users',
      icon: Icons.people_outline,
      child: state.when(
        data: (data) {
          final total = data.values.fold(0, (sum, val) => sum + val);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF60BA62),
                ),
              ),
              const SizedBox(height: 8),
              ...data.entries.map(
                (e) => Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _StoresCard extends ConsumerWidget {
  const _StoresCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeCountProvider);
    return _DashboardCard(
      title: 'Stores',
      icon: Icons.storefront_outlined,
      child: state.when(
        data: (data) => Text(
          data.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF60BA62),
          ),
        ),
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _ProductsCard extends ConsumerWidget {
  const _ProductsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productCountProvider);
    return _DashboardCard(
      title: 'Products',
      icon: Icons.inventory_2_outlined,
      child: state.when(
        data: (data) => Text(
          data.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF60BA62),
          ),
        ),
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _OrdersCard extends ConsumerWidget {
  const _OrdersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderCountByStatusProvider);
    return _DashboardCard(
      title: 'Orders',
      icon: Icons.receipt_long_outlined,
      child: state.when(
        data: (data) {
          final total = data.values.fold(0, (sum, val) => sum + val);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF60BA62),
                ),
              ),
              const SizedBox(height: 8),
              ...data.entries.map(
                (e) => Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _VoucherPromoCard extends ConsumerWidget {
  const _VoucherPromoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voucherPromoCountProvider);
    return _DashboardCard(
      title: 'Active Vouchers & Promos',
      icon: Icons.local_offer_outlined,
      child: state.when(
        data: (data) => Text(
          data.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF60BA62),
          ),
        ),
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _DeliveryJobsCard extends ConsumerWidget {
  const _DeliveryJobsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryJobCountByStatusProvider);
    return _DashboardCard(
      title: 'Delivery Jobs',
      icon: Icons.local_shipping_outlined,
      child: state.when(
        data: (data) {
          final total = data.values.fold(0, (sum, val) => sum + val);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF60BA62),
                ),
              ),
              const SizedBox(height: 8),
              ...data.entries.map(
                (e) => Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}

class _OverdueOrdersCard extends ConsumerWidget {
  const _OverdueOrdersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(overdueOrdersListProvider);
    final simulatedNow = ref.watch(simulatedNowProvider);

    return _DashboardCard(
      title: 'Overdue Orders (Auto Refund)',
      icon: Icons.warning_amber_rounded,
      child: state.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Text(
              'Tidak ada order overdue',
              style: TextStyle(fontFamily: 'Poppins'),
            );
          }
          return Column(
            children: orders.map((order) {
              final elapsedDays = simulatedNow
                  .difference(order.createdAt)
                  .inDays;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buyer: ${order.buyerName} | Toko: ${order.storeName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Kurir: ${order.deliveryMethod} | Overdue: $elapsedDays hari lalu',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF60BA62),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await ref
                                .read(orderRepositoryProvider)
                                .processOverdueRefund(order.id);
                            ref.invalidate(overdueOrdersListProvider);
                            ref.invalidate(orderCountByStatusProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Refund berhasil diproses'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Proses Refund',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () =>
            const CircularProgressIndicator(color: Color(0xFF60BA62)),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }
}
