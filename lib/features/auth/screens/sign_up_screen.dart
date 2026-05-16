import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/register_controller.dart';
import 'package:yellowspotuser/features/auth/domain/app_user.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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
    final ok = await ref.read(RegisterController.provider.notifier).submit(
          username: _usernameController.text.trim(),
          fullname: _fullnameController.text.trim(),
          email: _emailController.text.trim(),
          role: _role.apiValue,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created — check email to set password.')),
      );
      Navigator.of(context).pop();
    } else {
      final err = ref.read(RegisterController.provider).error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      RegisterController.provider.select((s) => s.isLoading),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Join Yellowspot',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Fill in the details to register a new account'),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a username'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your full name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    !(v ?? '').contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.shield_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: UserRole.user, child: Text('User')),
                  DropdownMenuItem(
                      value: UserRole.manager, child: Text('Manager')),
                  DropdownMenuItem(
                      value: UserRole.admin, child: Text('Admin')),
                  DropdownMenuItem(
                      value: UserRole.security, child: Text('Security')),
                ],
                onChanged: (v) => setState(() => _role = v ?? UserRole.user),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  minimumSize: const Size.fromHeight(50),
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
    );
  }
}
