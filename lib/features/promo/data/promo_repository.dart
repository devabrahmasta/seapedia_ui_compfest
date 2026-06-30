import 'package:supabase_flutter/supabase_flutter.dart';

class PromoNotFoundException implements Exception {
  final String code;
  const PromoNotFoundException(this.code);
}

class PromoExpiredException implements Exception {
  final String code;
  const PromoExpiredException(this.code);
}

class PromoUsageLimitExceededException implements Exception {
  final String code;
  const PromoUsageLimitExceededException(this.code);
}

enum PromoSource { voucher, promo }

class PromoCode {
  final String id;
  final String code;
  final double discountValue;
  final String discountType;
  final DateTime expiryDate;
  final int? usageLimit;
  final int? usageCount;
  final PromoSource source;

  const PromoCode({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.discountType,
    required this.expiryDate,
    required this.usageLimit,
    required this.usageCount,
    required this.source,
  });

  factory PromoCode.fromVoucherJson(Map<String, dynamic> json) => PromoCode(
    id: json['id'] as String,
    code: json['code'] as String,
    discountValue: (json['discount_value'] as num).toDouble(),
    discountType: json['discount_type'] as String,
    expiryDate: DateTime.parse(json['expiry_date'] as String),
    usageLimit: json['usage_limit'] as int?,
    usageCount: json['usage_count'] as int?,
    source: PromoSource.voucher,
  );

  factory PromoCode.fromPromoJson(Map<String, dynamic> json) => PromoCode(
    id: json['id'] as String,
    code: json['code'] as String,
    discountValue: (json['discount_value'] as num).toDouble(),
    discountType: json['discount_type'] as String,
    expiryDate: DateTime.parse(json['expiry_date'] as String),
    usageLimit: null,
    usageCount: null,
    source: PromoSource.promo,
  );

  double calculateDiscount(double subtotal) {
    final raw = discountType == 'percentage'
        ? subtotal * (discountValue / 100)
        : discountValue;
    if (raw <= 0) return 0;
    return raw > subtotal ? subtotal : raw;
  }
}

class PromoRepository {
  PromoRepository(this._client);

  final SupabaseClient _client;

  Future<List<PromoCode>> getAvailablePromos() async {
    final now = DateTime.now().toIso8601String();

    final vouchersRaw = await _client
        .from('vouchers')
        .select()
        .gt('expiry_date', now);
    final promosRaw = await _client
        .from('promos')
        .select()
        .gt('expiry_date', now);

    final vouchers = (vouchersRaw as List)
        .map((e) => PromoCode.fromVoucherJson(e as Map<String, dynamic>))
        .where((v) => (v.usageCount ?? 0) < (v.usageLimit ?? 1));

    final promos = (promosRaw as List).map(
      (e) => PromoCode.fromPromoJson(e as Map<String, dynamic>),
    );

    return [...vouchers, ...promos];
  }

  Future<PromoCode> validateCode(String code) async {
    final trimmed = code.trim();

    final voucherRaw = await _client
        .from('vouchers')
        .select()
        .eq('code', trimmed)
        .maybeSingle();

    if (voucherRaw != null) {
      final voucher = PromoCode.fromVoucherJson(voucherRaw);
      if (voucher.expiryDate.isBefore(DateTime.now())) {
        throw PromoExpiredException(trimmed);
      }
      if ((voucher.usageCount ?? 0) >= (voucher.usageLimit ?? 0)) {
        throw PromoUsageLimitExceededException(trimmed);
      }
      return voucher;
    }

    final promoRaw = await _client
        .from('promos')
        .select()
        .eq('code', trimmed)
        .maybeSingle();

    if (promoRaw != null) {
      final promo = PromoCode.fromPromoJson(promoRaw);
      if (promo.expiryDate.isBefore(DateTime.now())) {
        throw PromoExpiredException(trimmed);
      }
      return promo;
    }

    throw PromoNotFoundException(trimmed);
  }

  Future<void> createVoucher({
    required String code,
    required double discountValue,
    required String discountType,
    required int usageLimit,
    required DateTime expiryDate,
  }) async {
    await _client.from('vouchers').insert({
      'code': code.trim(),
      'discount_value': discountValue,
      'discount_type': discountType,
      'usage_limit': usageLimit,
      'usage_count': 0,
      'expiry_date': expiryDate.toIso8601String(),
    });
  }

  Future<void> createPromo({
    required String code,
    required double discountValue,
    required String discountType,
    required DateTime expiryDate,
  }) async {
    await _client.from('promos').insert({
      'code': code.trim(),
      'discount_value': discountValue,
      'discount_type': discountType,
      'expiry_date': expiryDate.toIso8601String(),
    });
  }

  Future<List<PromoCode>> getAllVouchers() async {
    final response = await _client
        .from('vouchers')
        .select()
        .order('expiry_date', ascending: false);
    return (response as List)
        .map((e) => PromoCode.fromVoucherJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PromoCode>> getAllPromos() async {
    final response = await _client
        .from('promos')
        .select()
        .order('expiry_date', ascending: false);
    return (response as List)
        .map((e) => PromoCode.fromPromoJson(e as Map<String, dynamic>))
        .toList();
  }
}
