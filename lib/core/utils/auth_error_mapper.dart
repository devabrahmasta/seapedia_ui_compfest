import 'package:supabase_flutter/supabase_flutter.dart';

String mapAuthError(Object error) {
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Email atau password salah';
      case 'user_already_exists':
        return 'Email sudah terdaftar, coba login';
      case 'weak_password':
        return 'Password minimal 6 karakter';
      case 'email_address_invalid':
        return 'Format email tidak valid';
      case 'email_not_confirmed':
        return 'Email belum dikonfirmasi';
      default:
        return error.message;
    }
  }

  if (error is PostgrestException) {
    if (error.code == '23505') {
      if (error.message.contains('username')) return 'Username sudah digunakan';
      if (error.message.contains('store_name')) {
        return 'Nama toko sudah digunakan';
      }
      return 'Data sudah digunakan';
    }
    return 'Terjadi kesalahan, coba lagi';
  }

  return 'Terjadi kesalahan, coba lagi';
}
