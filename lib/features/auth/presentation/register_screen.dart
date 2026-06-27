import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/core/theme/theme.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_text_field.dart';
import 'package:seapedia_ui_compfest/core/widgets/app_button.dart';
import 'package:seapedia_ui_compfest/features/auth/application/auth_provider.dart';
import 'package:seapedia_ui_compfest/core/utils/auth_error_mapper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Set<String> _selectedRoles = {};

  String? _validationError;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _validationError = 'Semua field wajib diisi');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _validationError = 'Password dan konfirmasi tidak sama');
      return;
    }

    if (_selectedRoles.isEmpty) {
      setState(() => _validationError = 'Pilih minimal satu peran');
      return;
    }

    setState(() => _validationError = null);

    ref
        .read(authProvider.notifier)
        .registerWithRoles(
          email: email,
          password: password,
          username: username,
          fullName: fullName,
          roles: _selectedRoles,
        );
  }

  void _toggleRole(String role, bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedRoles.add(role);
      } else {
        _selectedRoles.remove(role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final message = mapAuthError(next.error!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else if (!next.isLoading && next.hasValue && next.value != null) {
        context.go('/login');
      }
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Daftar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Buat akun untuk mulai menggunakan SEAPEDIA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Nama Lengkap',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Username',
                controller: _usernameController,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Konfirmasi Password',
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Peran',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Kamu bisa memilih lebih dari satu peran',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              CheckboxListTile(
                minVerticalPadding: 0,
                title: const Text('Buyer'),
                value: _selectedRoles.contains('buyer'),
                onChanged: (checked) => _toggleRole('buyer', checked),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                minVerticalPadding: 0,
                title: const Text('Seller'),
                value: _selectedRoles.contains('seller'),
                onChanged: (checked) => _toggleRole('seller', checked),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Driver'),
                value: _selectedRoles.contains('driver'),
                onChanged: (checked) => _toggleRole('driver', checked),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _validationError!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: isLoading ? 'Memproses...' : 'Daftar',
                onPressed: isLoading ? null : _handleRegister,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
