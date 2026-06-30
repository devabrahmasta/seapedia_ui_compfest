import 'package:supabase_flutter/supabase_flutter.dart';

class InsufficientBalanceException implements Exception {
  final double balance;
  final double required;
  const InsufficientBalanceException({
    required this.balance,
    required this.required,
  });
}

class InsufficientStockException implements Exception {
  final String productName;
  final int available;
  const InsufficientStockException({
    required this.productName,
    required this.available,
  });
}

class Order {
  final String id;
  final String buyerId;
  final String storeId;
  final String addressId;
  final String deliveryMethod;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double ppn;
  final double total;
  final String status;
  final DateTime createdAt;
  final String? voucherId;
  final String? promoId;

  const Order({
    required this.id,
    required this.buyerId,
    required this.storeId,
    required this.addressId,
    required this.deliveryMethod,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.ppn,
    required this.total,
    required this.status,
    required this.createdAt,
    this.voucherId,
    this.promoId,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    buyerId: json['buyer_id'] as String,
    storeId: json['store_id'] as String,
    addressId: json['address_id'] as String,
    deliveryMethod: json['delivery_method'] as String,
    subtotal: (json['subtotal'] as num).toDouble(),
    discountAmount: (json['discount_amount'] as num).toDouble(),
    deliveryFee: (json['delivery_fee'] as num).toDouble(),
    ppn: (json['ppn'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    voucherId: json['voucher_id'] as String?,
    promoId: json['promo_id'] as String?,
  );
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productNameSnapshot;
  final double priceSnapshot;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productNameSnapshot,
    required this.priceSnapshot,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    productId: json['product_id'] as String,
    productNameSnapshot: json['product_name_snapshot'] as String,
    priceSnapshot: (json['price_snapshot'] as num).toDouble(),
    quantity: json['quantity'] as int,
  );
}

class OrderStatusHistory {
  final String id;
  final String orderId;
  final String status;
  final DateTime changedAt;

  const OrderStatusHistory({
    required this.id,
    required this.orderId,
    required this.status,
    required this.changedAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      OrderStatusHistory(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        status: json['status'] as String,
        changedAt: DateTime.parse(json['changed_at'] as String),
      );
}

class OrderSummary {
  final String id;
  final String storeName;
  final String? buyerName;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<String> itemNames;

  const OrderSummary({
    required this.id,
    required this.storeName,
    this.buyerName,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.itemNames,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final storeData = json['stores'] as Map<String, dynamic>?;
    final profileData = json['profiles'] as Map<String, dynamic>?;
    final itemsRaw = json['order_items'] as List? ?? [];
    return OrderSummary(
      id: json['id'] as String,
      storeName: storeData?['store_name'] as String? ?? 'Toko',
      buyerName:
          profileData?['full_name'] as String? ??
          profileData?['username'] as String?,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      itemNames: itemsRaw
          .map((e) => e['product_name_snapshot'] as String)
          .toList(),
    );
  }
}

class OrderDetail {
  final Order order;
  final String storeName;
  final String addressLabel;
  final String addressFull;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;

  const OrderDetail({
    required this.order,
    required this.storeName,
    required this.addressLabel,
    required this.addressFull,
    required this.items,
    required this.statusHistory,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final storeData = json['stores'] as Map<String, dynamic>?;
    final addressData = json['addresses'] as Map<String, dynamic>?;
    final itemsRaw = json['order_items'] as List? ?? [];
    final historyRaw = json['order_status_history'] as List? ?? [];

    final history =
        historyRaw
            .map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

    return OrderDetail(
      order: Order.fromJson(json),
      storeName: storeData?['store_name'] as String? ?? 'Toko',
      addressLabel: addressData?['label'] as String? ?? '',
      addressFull: addressData?['full_address'] as String? ?? '',
      items: itemsRaw
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusHistory: history,
    );
  }
}

class StoreIncomeSummary {
  final double totalIncome;
  final int completedOrderCount;
  final double averagePerOrder;

  const StoreIncomeSummary({
    required this.totalIncome,
    required this.completedOrderCount,
    required this.averagePerOrder,
  });
}

class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  static const deliveryFees = {
    'instant': 25000.0,
    'next_day': 15000.0,
    'regular': 9000.0,
  };

  Future<Order> checkout({
    required String buyerId,
    required String cartId,
    required String storeId,
    required String addressId,
    required String deliveryMethod,
    required String walletId,
    required double walletBalance,
    String? voucherId,
    String? promoId,
    double discountAmount = 0,
  }) async {
    final rawItems = await _client
        .from('cart_items')
        .select('quantity, products(id, name, price, stock)')
        .eq('cart_id', cartId);

    final items = rawItems as List;
    if (items.isEmpty) throw Exception('Keranjang kosong');

    for (final item in items) {
      final product = item['products'] as Map<String, dynamic>;
      final stock = product['stock'] as int;
      final qty = item['quantity'] as int;
      if (stock < qty) {
        throw InsufficientStockException(
          productName: product['name'] as String,
          available: stock,
        );
      }
    }

    double subtotal = 0;
    for (final item in items) {
      subtotal +=
          (item['products']['price'] as num).toDouble() *
          (item['quantity'] as int);
    }
    final deliveryFee = deliveryFees[deliveryMethod]!;
    final cappedDiscount = discountAmount.clamp(0, subtotal).toDouble();
    final ppn = (subtotal - cappedDiscount) * 0.12;
    final total = subtotal - cappedDiscount + deliveryFee + ppn;

    if (walletBalance < total) {
      throw InsufficientBalanceException(
        balance: walletBalance,
        required: total,
      );
    }

    final orderData = await _client
        .from('orders')
        .insert({
          'buyer_id': buyerId,
          'store_id': storeId,
          'address_id': addressId,
          'delivery_method': deliveryMethod,
          'subtotal': subtotal,
          'discount_amount': cappedDiscount,
          'delivery_fee': deliveryFee,
          'ppn': ppn,
          'total': total,
          'status': 'Sedang Dikemas',
          'voucher_id': voucherId,
          'promo_id': promoId,
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    await _client
        .from('order_items')
        .insert(
          items
              .map(
                (item) => {
                  'order_id': orderId,
                  'product_id': item['products']['id'] as String,
                  'product_name_snapshot': item['products']['name'] as String,
                  'price_snapshot': (item['products']['price'] as num)
                      .toDouble(),
                  'quantity': item['quantity'] as int,
                },
              )
              .toList(),
        );

    await _client.from('order_status_history').insert({
      'order_id': orderId,
      'status': 'Sedang Dikemas',
      'changed_at': DateTime.now().toIso8601String(),
    });

    for (final item in items) {
      final productId = item['products']['id'] as String;
      final currentStock = item['products']['stock'] as int;
      await _client
          .from('products')
          .update({'stock': currentStock - (item['quantity'] as int)})
          .eq('id', productId);
    }

    await _client
        .from('wallets')
        .update({'balance': walletBalance - total})
        .eq('id', walletId);

    await _client.from('wallet_transactions').insert({
      'wallet_id': walletId,
      'type': 'checkout',
      'amount': total,
      'reference_id': orderId,
    });

    await _client.from('cart_items').delete().eq('cart_id', cartId);
    await _client.from('carts').update({'store_id': null}).eq('id', cartId);

    if (voucherId != null) {
      final voucher = await _client
          .from('vouchers')
          .select('usage_count')
          .eq('id', voucherId)
          .single();
      final currentUsage = voucher['usage_count'] as int;
      await _client
          .from('vouchers')
          .update({'usage_count': currentUsage + 1})
          .eq('id', voucherId);
    }

    return Order.fromJson(orderData);
  }

  Future<List<OrderSummary>> getMyOrders(String buyerId) async {
    final data = await _client
        .from('orders')
        .select(
          '*, stores!store_id(store_name), order_items(product_name_snapshot)',
        )
        .eq('buyer_id', buyerId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderSummary>> getIncomingOrders(String storeId) async {
    final data = await _client
        .from('orders')
        .select(
          '*, profiles!buyer_id(username, full_name), order_items(product_name_snapshot)',
        )
        .eq('store_id', storeId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderDetail> getOrderDetail(String orderId) async {
    final data = await _client
        .from('orders')
        .select(
          '*, stores!store_id(store_name), addresses!address_id(label, full_address), order_items(*), order_status_history(*)',
        )
        .eq('id', orderId)
        .single();
    return OrderDetail.fromJson(data);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _client.from('order_status_history').insert({
      'order_id': orderId,
      'status': newStatus,
      'changed_at': DateTime.now().toIso8601String(),
    });
    await _client.from('orders').update({'status': newStatus}).eq('id', orderId);
    if (newStatus == 'Menunggu Pengirim') {
      await _client.from('delivery_jobs').insert({
        'order_id': orderId,
        'status': 'available',
      });
    }
  }

  Future<StoreIncomeSummary> getStoreIncomeSummary(String storeId) async {
    final data = await _client
        .from('orders')
        .select('subtotal')
        .eq('store_id', storeId)
        .eq('status', 'Pesanan Selesai');

    final orders = data as List;
    double totalIncome = 0;
    int completedOrderCount = orders.length;

    for (final order in orders) {
      totalIncome += (order['subtotal'] as num).toDouble();
    }

    double averagePerOrder = completedOrderCount > 0 
        ? totalIncome / completedOrderCount 
        : 0;

    return StoreIncomeSummary(
      totalIncome: totalIncome,
      completedOrderCount: completedOrderCount,
      averagePerOrder: averagePerOrder,
    );
  }
}
