import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ProductRepository {
  ProductRepository(this._client);
  
  final SupabaseClient _client;

  Future<List<Product>> fetchMyProducts(String storeId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .order('created_at', ascending: false);
        
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> createProduct({
    required String storeId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    final response = await _client.from('products').insert({
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    }).select().single();
    
    return Product.fromJson(response);
  }

  Future<Product> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    final response = await _client.from('products').update({
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    }).eq('id', productId).select().single();
    
    return Product.fromJson(response);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  Future<String> uploadProductImage(String storeId, File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$storeId.$fileExt';
    final filePath = '$storeId/$fileName';
    
    await _client.storage.from('products').upload(filePath, file);
    return _client.storage.from('products').getPublicUrl(filePath);
  }
}