import 'package:flutter/material.dart';

IconData orderStatusIcon(String status) {
  switch (status) {
    case 'Menunggu Pengirim':
      return Icons.access_time_outlined;
    case 'Sedang Dikirim':
      return Icons.local_shipping_outlined;
    case 'Pesanan Selesai':
      return Icons.check_circle_outline;
    case 'Dikembalikan':
      return Icons.assignment_return_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}
