import 'package:flutter/material.dart';

class ActiveFilterChip {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterChip({required this.label, required this.onRemove});
}