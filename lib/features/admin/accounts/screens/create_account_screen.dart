import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/register_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

/// Admin-side flow to register a new account via /auth/register.
/// Uses [RegisterController] (autoDispose) — keeps the admin's own session
/// completely isolated from this one-shot action.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _role = UserRole.user;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ok = await ref.read(RegisterController.provider.notifier).submit(
          username: _usernameController.text.trim(),
          fullname: _fullnameController.text.trim(),
          email: _emailController.text.trim(),
          role: _role.apiValue,
        );

    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );
      navigator.pop();
    } else {
      final err = ref.read(RegisterController.provider).error;
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      RegisterController.provider.select((s) => s.isLoading),
    );
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Create Account',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                    'Register a new user, manager or admin for the community.',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Username required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fullnameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Full name required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => !(v ?? '').contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.shield_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: UserRole.user, child: Text('User')),
                    DropdownMenuItem(
                        value: UserRole.manager, child: Text('Manager')),
                    DropdownMenuItem(
                        value: UserRole.admin, child: Text('Admin')),
                    DropdownMenuItem(
                        value: UserRole.security, child: Text('Security')),
                  ],
                  onChanged: (v) =>
                      setState(() => _role = v ?? UserRole.user),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Create Account',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
