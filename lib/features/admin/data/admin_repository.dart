import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  AdminRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, int>> getUserCount() async {
    final response = await _client.from('user_roles').select('role');
    final Map<String, int> counts = {};
    for (final row in response) {
      final role = row['role'] as String;
      counts[role] = (counts[role] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> getStoreCount() async {
    final response = await _client.from('stores').select('id');
    return response.length;
  }

  Future<int> getProductCount() async {
    final response = await _client.from('products').select('id');
    return response.length;
  }

  Future<Map<String, int>> getOrderCountByStatus() async {
    final response = await _client.from('orders').select('status');
    final Map<String, int> counts = {};
    for (final row in response) {
      final status = row['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> getVoucherPromoCount() async {
    final now = DateTime.now().toIso8601String();

    final vouchersResponse = await _client
        .from('vouchers')
        .select('id')
        .gte('expiry_date', now);

    final promosResponse = await _client
        .from('promos')
        .select('id')
        .gte('expiry_date', now);

    return vouchersResponse.length + promosResponse.length;
  }

  Future<Map<String, int>> getDeliveryJobCountByStatus() async {
    final response = await _client.from('delivery_jobs').select('status');
    final Map<String, int> counts = {};
    for (final row in response) {
      final status = row['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> getOverdueOrderCount() async {
    final threeDaysAgo = DateTime.now()
        .subtract(const Duration(days: 3))
        .toIso8601String();

    final response = await _client
        .from('orders')
        .select('id')
        .neq('status', 'Pesanan Selesai')
        .neq('status', 'Dikembalikan')
        .lte('created_at', threeDaysAgo);

    return response.length;
  }
}
