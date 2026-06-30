import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/order/data/order_repository.dart';

class JobAlreadyTakenException implements Exception {
  const JobAlreadyTakenException();
}

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
  final String? storeAddress;
  final String? buyerName;
  final String addressLabel;
  final String addressFull;
  final String deliveryMethod;
  final double deliveryFee;
  final double total;

  const DeliveryJobSummary({
    required this.job,
    required this.storeName,
    this.storeAddress,
    this.buyerName,
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
    final profileData = orderData?['profiles'] as Map<String, dynamic>?;
    return DeliveryJobSummary(
      job: DeliveryJob.fromJson(json),
      storeName: storeData?['store_name'] as String? ?? 'Toko',
      storeAddress: storeData?['address'] as String?,
      buyerName:
          profileData?['full_name'] as String? ??
          profileData?['username'] as String?,
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
  final String? storeAddress;
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
    this.storeAddress,
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
      storeAddress: storeData?['address'] as String?,
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

class DeliveryJobHistoryItem {
  final DeliveryJob job;
  final String storeName;
  final String deliveryMethod;
  final double earning;

  const DeliveryJobHistoryItem({
    required this.job,
    required this.storeName,
    required this.deliveryMethod,
    required this.earning,
  });

  factory DeliveryJobHistoryItem.fromJson(Map<String, dynamic> json) {
    final orderData = json['orders'] as Map<String, dynamic>?;
    final storeData = orderData?['stores'] as Map<String, dynamic>?;
    return DeliveryJobHistoryItem(
      job: DeliveryJob.fromJson(json),
      storeName: storeData?['store_name'] as String? ?? 'Toko',
      deliveryMethod: orderData?['delivery_method'] as String? ?? 'regular',
      earning: (orderData?['delivery_fee'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DeliveryJobRepository {
  DeliveryJobRepository(this._client)
    : _orderRepository = OrderRepository(_client);

  final SupabaseClient _client;
  final OrderRepository _orderRepository;

  Future<DeliveryJob?> getJobByOrderId(String orderId) async {
    final data = await _client
        .from('delivery_jobs')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();
    return data == null ? null : DeliveryJob.fromJson(data);
  }

  Future<void> takeJob(String jobId, String driverId) async {
    final updated = await _client
        .from('delivery_jobs')
        .update({
          'driver_id': driverId,
          'status': 'taken',
          'taken_at': DateTime.now().toIso8601String(),
        })
        .eq('id', jobId)
        .eq('status', 'available')
        .select();

    final rows = updated as List;
    if (rows.isEmpty) {
      throw const JobAlreadyTakenException();
    }

    final orderId = rows.first['order_id'] as String;
    await _orderRepository.updateOrderStatus(orderId, 'Sedang Dikirim');
  }

  Future<void> completeJob(
    String jobId,
    String driverId,
    double deliveryFee,
  ) async {
    final updated = await _client
        .from('delivery_jobs')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', jobId)
        .eq('driver_id', driverId)
        .select();

    final rows = updated as List;
    if (rows.isEmpty) {
      throw Exception('Job tidak ditemukan atau bukan milik Anda');
    }

    final orderId = rows.first['order_id'] as String;
    await _orderRepository.updateOrderStatus(orderId, 'Pesanan Selesai');

    await _client.from('driver_earnings').insert({
      'driver_id': driverId,
      'delivery_job_id': jobId,
      'amount': deliveryFee,
    });
  }

  Future<DeliveryJobSummary?> getActiveJob(String driverId) async {
    final data = await _client
        .from('delivery_jobs')
        .select(
          '*, orders!order_id(delivery_method, delivery_fee, total, stores!store_id(store_name), addresses!address_id(label, full_address), profiles!buyer_id(username, full_name))',
        )
        .eq('driver_id', driverId)
        .eq('status', 'taken')
        .order('taken_at', ascending: false)
        .limit(1);

    final rows = data as List;
    if (rows.isEmpty) return null;
    return DeliveryJobSummary.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<List<DeliveryJobHistoryItem>> getJobHistory(String driverId) async {
    final data = await _client
        .from('delivery_jobs')
        .select(
          '*, orders!order_id(delivery_method, delivery_fee, stores!store_id(store_name))',
        )
        .eq('driver_id', driverId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false);

    return (data as List)
        .map((e) => DeliveryJobHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DeliveryJobSummary>> getAvailableJobs() async {
    final data = await _client
        .from('delivery_jobs')
        .select(
          '*, orders!order_id(delivery_method, delivery_fee, total, stores!store_id(store_name, address), addresses!address_id(label, full_address))',
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
          '*, orders!order_id(delivery_method, delivery_fee, total, stores!store_id(store_name, address), addresses!address_id(label, full_address), profiles!buyer_id(username, full_name), order_items(product_name_snapshot, quantity))',
        )
        .eq('id', jobId)
        .single();
    return DeliveryJobDetail.fromJson(data);
  }
}
