import 'package:supabase_flutter/supabase_flutter.dart';

class CartDifferentStoreException implements Exception {
  final String currentStoreName;
  final String newStoreName;

  const CartDifferentStoreException({
    required this.currentStoreName,
    required this.newStoreName,
  });
}

class Cart {
  final String id;
  final String buyerId;
  final String? storeId;
  final String? storeName;

  const Cart({
    required this.id,
    required this.buyerId,
    this.storeId,
    this.storeName,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json['id'] as String,
    buyerId: json['buyer_id'] as String,
    storeId: json['store_id'] as String?,
    storeName: json['stores']?['store_name'] as String?,
  );
}

class CartItemWithProduct {
  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final String productName;
  final double productPrice;
  final String? productImageUrl;

  const CartItemWithProduct({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productPrice,
    this.productImageUrl,
  });

  factory CartItemWithProduct.fromJson(Map<String, dynamic> json) =>
      CartItemWithProduct(
        id: json['id'] as String,
        cartId: json['cart_id'] as String,
        productId: json['product_id'] as String,
        quantity: json['quantity'] as int,
        productName: json['products']['name'] as String,
        productPrice: (json['products']['price'] as num).toDouble(),
        productImageUrl: json['products']['image_url'] as String?,
      );
}

class CartRepository {
  CartRepository(this._client);

  final SupabaseClient _client;

  Future<Cart> getOrCreateCart(String buyerId) async {
    final existing = await _client
        .from('carts')
        .select('*, stores(store_name)')
        .eq('buyer_id', buyerId)
        .maybeSingle();

    if (existing != null) return Cart.fromJson(existing);

    final created = await _client
        .from('carts')
        .insert({'buyer_id': buyerId})
        .select('*, stores(store_name)')
        .single();

    return Cart.fromJson(created);
  }

  Future<List<CartItemWithProduct>> getCartItems(String cartId) async {
    final data = await _client
        .from('cart_items')
        .select('*, products(name, price, image_url)')
        .eq('cart_id', cartId)
        .order('id');

    return (data as List)
        .map((e) => CartItemWithProduct.fromJson(e))
        .toList();
  }

  Future<void> addItem({
    required String buyerId,
    required String productId,
    required String storeId,
    required String storeName,
  }) async {
    final cart = await getOrCreateCart(buyerId);

    if (cart.storeId != null && cart.storeId != storeId) {
      throw CartDifferentStoreException(
        currentStoreName: cart.storeName ?? 'Toko lain',
        newStoreName: storeName,
      );
    }

    if (cart.storeId == null) {
      await _client
          .from('carts')
          .update({'store_id': storeId})
          .eq('id', cart.id);
    }

    final existing = await _client
        .from('cart_items')
        .select()
        .eq('cart_id', cart.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('cart_items')
          .update({'quantity': (existing['quantity'] as int) + 1})
          .eq('id', existing['id'] as String);
    } else {
      await _client.from('cart_items').insert({
        'cart_id': cart.id,
        'product_id': productId,
        'quantity': 1,
      });
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  Future<void> removeItem({
    required String cartItemId,
    required String cartId,
  }) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);

    final remaining = await _client
        .from('cart_items')
        .select('id')
        .eq('cart_id', cartId);

    if ((remaining as List).isEmpty) {
      await _client
          .from('carts')
          .update({'store_id': null})
          .eq('id', cartId);
    }
  }

  Future<void> clearCart(String cartId) async {
    await _client.from('cart_items').delete().eq('cart_id', cartId);
    await _client
        .from('carts')
        .update({'store_id': null})
        .eq('id', cartId);
  }
}
