import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/screens/forgot_password_screen.dart';
import 'package:yellowspotuser/features/auth/screens/sign_up_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(
      AuthController.provider,
      (previous, next) {
        next.whenOrNull(
          error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: _LoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(AuthController.provider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      AuthController.provider.select((s) => s.isLoading),
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.yellow,
            child: Icon(Icons.location_on, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 8),
          const Text('Yellowspot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Smart Parking', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Welcome Back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Sign in to continue',
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          _LabeledField(
            label: 'Username',
            controller: _usernameController,
            hint: 'your.username',
            icon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your username' : null,
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: 'Password',
            controller: _passwordController,
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter your password' : null,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                : const Text('Sign In',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('New to Yellowspot?'),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text('Create an Account'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Secured with 256-bit encryption',
                  style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

class _LabeledField extends StatefulWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  /// When true, the field hides input and adds a show/hide eye toggle.
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  @override
  State<_LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<_LabeledField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(_obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                  )
                : null,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }
}
