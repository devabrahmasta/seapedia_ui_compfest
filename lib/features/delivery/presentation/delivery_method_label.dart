import 'package:flutter/material.dart';

const _deliveryMethodLabels = {
  'instant': 'Instant',
  'next_day': 'Next Day',
  'regular': 'Reguler',
};

const _deliveryMethodIcons = {
  'instant': Icons.bolt,
  'next_day': Icons.wb_sunny_outlined,
  'regular': Icons.local_shipping_outlined,
};

String deliveryMethodLabel(String method) =>
    _deliveryMethodLabels[method] ?? method;

IconData deliveryMethodIcon(String method) =>
    _deliveryMethodIcons[method] ?? Icons.local_shipping_outlined;
