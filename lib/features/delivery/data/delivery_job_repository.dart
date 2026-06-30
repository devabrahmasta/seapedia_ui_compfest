import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryJob {
  final String id;
  final String orderId;
  final String? driverId;
  final String status;
  final DateTime? takenAt;
  final DateTime? completedAt;

  const DeliveryJob({
    required this.id,
    required this.orderId,
    this.driverId,
    required this.status,
    this.takenAt,
    this.completedAt,
  });

  factory DeliveryJob.fromJson(Map<String, dynamic> json) => DeliveryJob(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    driverId: json['driver_id'] as String?,
    status: json['status'] as String,
    takenAt: json['taken_at'] == null
        ? null
        : DateTime.parse(json['taken_at'] as String),
    completedAt: json['completed_at'] == null
        ? null
        : DateTime.parse(json['completed_at'] as String),
  );
}

class DeliveryJobSummary {
  final DeliveryJob job;
  final String storeName;
  final String addressLabel;
  final String addressFull;
  final String deliveryMethod;
  final double deliveryFee;
  final double total;

  const DeliveryJobSummary({
    required this.job,
    required this.storeName,
    required this.addressLabel,
    required this.addressFull,
    required this.deliveryMethod,
    required this.deliveryFee,
    required this.total,
  });

  factory DeliveryJobSummary.fromJson(Map<String, dynamic> json) {
    final orderData = json['orders'] as Map<String, dynamic>?;
    final storeData = orderData?['stores'] as Map<String, dynamic>?;
    final addressData = orderData?['addresses'] as Map<String, dynamic>?;
    return DeliveryJobSummary(
      job: DeliveryJob.fromJson(json),
      storeName: storeData?['store_name'] as String? ?? 'Toko',
      addressLabel: addressData?['label'] as String? ?? '',
      addressFull: addressData?['full_address'] as String? ?? '',
      deliveryMethod: orderData?['delivery_method'] as String? ?? 'regular',
      deliveryFee: (orderData?['delivery_fee'] as num?)?.toDouble() ?? 0,
      total: (orderData?['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DeliveryJobItem {
  final String productNameSnapshot;
  final int quantity;

  const DeliveryJobItem({
    required this.productNameSnapshot,
    required this.quantity,
  });

  factory DeliveryJobItem.fromJson(Map<String, dynamic> json) =>
      DeliveryJobItem(
        productNameSnapshot: json['product_name_snapshot'] as String,
        quantity: json['quantity'] as int,
      );
}

class DeliveryJobDetail {
  final DeliveryJob job;
  final String storeName;
  final String buyerName;
  final String addressLabel;
  final String addressFull;
  final String deliveryMethod;
  final double deliveryFee;
  final double total;
  final List<DeliveryJobItem> items;

  const DeliveryJobDetail({
    required this.job,
    required this.storeName,
    required this.buyerName,
    required this.addressLabel,
    required this.addressFull,
    required this.deliveryMethod,
    required this.deliveryFee,
    required this.total,
    required this.items,
  });

  factory DeliveryJobDetail.fromJson(Map<String, dynamic> json) {
    final orderData = json['orders'] as Map<String, dynamic>?;
    final storeData = orderData?['stores'] as Map<String, dynamic>?;
    final addressData = orderData?['addresses'] as Map<String, dynamic>?;
    final profileData = orderData?['profiles'] as Map<String, dynamic>?;
    final itemsRaw = orderData?['order_items'] as List? ?? [];

    return DeliveryJobDetail(
      job: DeliveryJob.fromJson(json),
      storeName: storeData?['store_name'] as String? ?? 'Toko',
      buyerName:
          profileData?['full_name'] as String? ??
          profileData?['username'] as String? ??
          'Pembeli',
      addressLabel: addressData?['label'] as String? ?? '',
      addressFull: addressData?['full_address'] as String? ?? '',
      deliveryMethod: orderData?['delivery_method'] as String? ?? 'regular',
      deliveryFee: (orderData?['delivery_fee'] as num?)?.toDouble() ?? 0,
      total: (orderData?['total'] as num?)?.toDouble() ?? 0,
      items: itemsRaw
          .map((e) => DeliveryJobItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DeliveryJobRepository {
  DeliveryJobRepository(this._client);

  final SupabaseClient _client;

  Future<List<DeliveryJobSummary>> getAvailableJobs() async {
    final data = await _client
        .from('delivery_jobs')
        .select(
          '*, orders!order_id(delivery_method, delivery_fee, total, stores!store_id(store_name), addresses!address_id(label, full_address))',
        )
        .eq('status', 'available')
        .order('taken_at', ascending: true);
    return (data as List)
        .map((e) => DeliveryJobSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryJobDetail> getJobDetail(String jobId) async {
    final data = await _client
        .from('delivery_jobs')
        .select(
          '*, orders!order_id(delivery_method, delivery_fee, total, stores!store_id(store_name), addresses!address_id(label, full_address), profiles!buyer_id(username, full_name), order_items(product_name_snapshot, quantity))',
        )
        .eq('id', jobId)
        .single();
    return DeliveryJobDetail.fromJson(data);
  }
}
