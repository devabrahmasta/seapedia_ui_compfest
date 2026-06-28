class Product {
  final String id;
  final String name;
  final double price;
  final String storeName;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.storeName,
    required this.imageUrl,
  });
}

const dummyProducts = [
  Product(
    id: '1',
    name: 'Ikan Tuna Segar',
    price: 75000,
    storeName: 'Toko Bahari',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
  ),
  Product(
    id: '2',
    name: 'Rumput Laut Kering',
    price: 32000,
    storeName: 'Samudra Tani',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
  ),
  Product(
    id: '3',
    name: 'Udang Windu Premium (1kg)',
    price: 145000,
    storeName: 'Hasil Laut Nusantara',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
  ),
  Product(
    id: '4',
    name: 'Kepiting Bakau',
    price: 85000,
    storeName: 'Toko Bahari',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
  ),
  Product(
    id: '5',
    name: 'Kerang Dara Bersih',
    price: 25000,
    storeName: 'Samudra Tani',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
  ),
  Product(
    id: '6',
    name: 'Ikan Salmon Fillet',
    price: 185000,
    storeName: 'Seafood King',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
  ),
];