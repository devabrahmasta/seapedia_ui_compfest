import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/features/cart/data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(Supabase.instance.client);
});

class CartState {
  final Cart? cart;
  final List<CartItemWithProduct> items;

  const CartState({this.cart, this.items = const []});

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.productPrice * item.quantity);

  bool get isEmpty => items.isEmpty;
}

class CartNotifier extends AsyncNotifier<CartState> {
  @override
  Future<CartState> build() async {
    final session = ref.watch(authProvider).value;
    if (session == null) return const CartState();

    final repo = ref.watch(cartRepositoryProvider);
    final cart = await repo.getOrCreateCart(session.user.id);
    final items = await repo.getCartItems(cart.id);
    return CartState(cart: cart, items: items);
  }

  Future<void> addItem({
    required String productId,
    required String storeId,
    required String storeName,
  }) async {
    final session = ref.read(authProvider).value;
    if (session == null) return;

    final repo = ref.read(cartRepositoryProvider);
    await repo.addItem(
      buyerId: session.user.id,
      productId: productId,
      storeId: storeId,
      storeName: storeName,
    );
    ref.invalidateSelf();
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) return;
    final repo = ref.read(cartRepositoryProvider);
    await repo.updateQuantity(cartItemId: cartItemId, quantity: quantity);
    ref.invalidateSelf();
  }

  Future<void> removeItem(String cartItemId) async {
    final cartId = state.value?.cart?.id;
    if (cartId == null) return;
    final repo = ref.read(cartRepositoryProvider);
    await repo.removeItem(cartItemId: cartItemId, cartId: cartId);
    ref.invalidateSelf();
  }

  Future<void> clearCart() async {
    final cartId = state.value?.cart?.id;
    if (cartId == null) return;
    final repo = ref.read(cartRepositoryProvider);
    await repo.clearCart(cartId);
    ref.invalidateSelf();
  }

  Future<void> clearAndAddItem({
    required String productId,
    required String storeId,
    required String storeName,
  }) async {
    await clearCart();
    await addItem(productId: productId, storeId: storeId, storeName: storeName);
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
