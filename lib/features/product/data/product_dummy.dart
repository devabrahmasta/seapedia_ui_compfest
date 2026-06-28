class Product {
  final String id;
  final String name;
  final double price;
  final String storeName;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final String description;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.storeName,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
    required this.description,
    required this.category,
  });
}

const dummyCategories = ['Ikan', 'Olahan', 'Rumput Laut', 'Kerang & Udang'];

const dummyProducts = [
  Product(
    id: '1',
    name: 'Ikan Tuna Segar',
    price: 75000,
    storeName: 'Toko Bahari',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
    rating: 4.7,
    reviewCount: 156,
    soldCount: 890,
    description: 'Ikan tuna segar pilihan, ditangkap langsung dari laut dan dikirim dalam kondisi dingin agar kualitas tetap terjaga.',
    category: 'Ikan',
  ),
  Product(
    id: '2',
    name: 'Rumput Laut Kering',
    price: 32000,
    storeName: 'Samudra Tani',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
    rating: 4.5,
    reviewCount: 98,
    soldCount: 540,
    description: 'Rumput laut kering berkualitas, cocok untuk bahan dasar makanan sehat maupun campuran masakan tradisional.',
    category: 'Rumput Laut',
  ),
  Product(
    id: '3',
    name: 'Udang Windu Premium (1kg)',
    price: 145000,
    storeName: 'Hasil Laut Nusantara',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
    rating: 4.8,
    reviewCount: 212,
    soldCount: 1200,
    description: 'Udang windu segar ukuran jumbo, cocok untuk dibakar atau ditumis. Dikirim dengan kemasan dingin agar tetap segar sampai tujuan.',
    category: 'Kerang & Udang',
  ),
  Product(
    id: '4',
    name: 'Kepiting Bakau',
    price: 85000,
    storeName: 'Toko Bahari',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
    rating: 4.6,
    reviewCount: 134,
    soldCount: 670,
    description: 'Kepiting bakau hidup pilihan, daging tebal dan segar, ideal untuk berbagai olahan seafood.',
    category: 'Kerang & Udang',
  ),
  Product(
    id: '5',
    name: 'Kerang Dara Bersih',
    price: 25000,
    storeName: 'Samudra Tani',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
    rating: 4.4,
    reviewCount: 76,
    soldCount: 410,
    description: 'Kerang dara yang sudah dibersihkan, siap masak, praktis untuk berbagai resep rumahan.',
    category: 'Kerang & Udang',
  ),
  Product(
    id: '6',
    name: 'Ikan Salmon Fillet',
    price: 185000,
    storeName: 'Seafood King',
    imageUrl: 'https://placehold.co/400x400/F4F4F4/1A1A1A?text=foto+produk',
    rating: 4.9,
    reviewCount: 304,
    soldCount: 1560,
    description: 'Fillet salmon segar import, tanpa duri, tekstur lembut, cocok untuk sashimi maupun dipanggang.',
    category: 'Ikan',
  ),
];