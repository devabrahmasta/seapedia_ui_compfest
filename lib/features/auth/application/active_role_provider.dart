import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeRoleProvider = NotifierProvider<ActiveRoleNotifier, String?>(() {
  return ActiveRoleNotifier();
});

class ActiveRoleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setRole(String role) {
    state = role;
  }

  void clear() {
    state = null;
  }
}