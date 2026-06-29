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

class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  // Biaya pengiriman per metode (keputusan bisnis — lihat README)
  static const deliveryFees = {
    'instant': 25000.0,
    'next_day': 15000.0,
    'regular': 9000.0,
  };

  // Checkout dilakukan di Flutter repository level (bukan Postgres Function)
  // karena pola ini konsisten dengan codebase yang ada (lihat WalletRepository).
  // Validasi stok dan saldo dilakukan SEBELUM semua mutasi sehingga
  // kegagalan validasi tidak meninggalkan data parsial di database.
  Future<Order> checkout({
    required String buyerId,
    required String cartId,
    required String storeId,
    required String addressId,
    required String deliveryMethod,
    required String walletId,
    required double walletBalance,
  }) async {
    // 1. Fetch cart items beserta data produk terkini
    final rawItems = await _client
        .from('cart_items')
        .select('quantity, products(id, name, price, stock)')
        .eq('cart_id', cartId);

    final items = rawItems as List;
    if (items.isEmpty) throw Exception('Keranjang kosong');

    // 2. Validasi stok semua item SEBELUM mutasi apapun
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

    // 3. Hitung harga
    double subtotal = 0;
    for (final item in items) {
      subtotal +=
          (item['products']['price'] as num).toDouble() *
          (item['quantity'] as int);
    }
    final deliveryFee = deliveryFees[deliveryMethod]!;
    final ppn = subtotal * 0.12;
    final total = subtotal + deliveryFee + ppn;

    // 4. Validasi saldo wallet SEBELUM mutasi apapun
    if (walletBalance < total) {
      throw InsufficientBalanceException(
        balance: walletBalance,
        required: total,
      );
    }

    // 5. Insert order
    final orderData = await _client
        .from('orders')
        .insert({
          'buyer_id': buyerId,
          'store_id': storeId,
          'address_id': addressId,
          'delivery_method': deliveryMethod,
          'subtotal': subtotal,
          'discount_amount': 0,
          'delivery_fee': deliveryFee,
          'ppn': ppn,
          'total': total,
          'status': 'Sedang Dikemas',
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    // 6. Insert order_items (snapshot nama dan harga)
    await _client.from('order_items').insert(
      items
          .map(
            (item) => {
              'order_id': orderId,
              'product_id': item['products']['id'] as String,
              'product_name_snapshot': item['products']['name'] as String,
              'price_snapshot':
                  (item['products']['price'] as num).toDouble(),
              'quantity': item['quantity'] as int,
            },
          )
          .toList(),
    );

    // 7. Insert order_status_history
    await _client.from('order_status_history').insert({
      'order_id': orderId,
      'status': 'Sedang Dikemas',
      'changed_at': DateTime.now().toIso8601String(),
    });

    // 8. Kurangi stok tiap produk
    for (final item in items) {
      final productId = item['products']['id'] as String;
      final currentStock = item['products']['stock'] as int;
      await _client
          .from('products')
          .update({'stock': currentStock - (item['quantity'] as int)})
          .eq('id', productId);
    }

    // 9. Potong saldo wallet + catat transaksi
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

    // 10. Kosongkan cart
    await _client.from('cart_items').delete().eq('cart_id', cartId);
    await _client
        .from('carts')
        .update({'store_id': null})
        .eq('id', cartId);

    return Order.fromJson(orderData);
  }
}
