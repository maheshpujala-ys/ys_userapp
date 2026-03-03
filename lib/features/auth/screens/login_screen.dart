import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/screens/sign_up_screen.dart';
import 'package:yellowspotuser/features/auth/screens/forgot_password_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(
      AuthController.provider,
      (previous, next) {
        next.maybeWhen(
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
          orElse: () {},
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  final _emailController = TextEditingController(text: 'user@test.com');
  final _passwordController = TextEditingController(text: 'password');
  bool _rememberMe = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(AuthController.provider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(AuthController.provider);

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
          const Text('Yellowspot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Smart Parking', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Welcome Back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Sign in to access your parking account', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          _buildTextField(controller: _emailController, label: 'Email Address', hint: 'your.email@example.com', icon: Icons.email_outlined, validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your email';
            if (!value.contains('@')) return 'Please enter a valid email';
            return null;
          }),
          const SizedBox(height: 16),
          _buildTextField(controller: _passwordController, label: 'Password', hint: 'Enter your password', icon: Icons.lock_outline, obscureText: true, validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your password';
            return null;
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(value: _rememberMe, onChanged: (value) => setState(() => _rememberMe = value!)),
                  const Text('Remember me'),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: authState.isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: authState.isLoading
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black))
                : const Text('Sign In', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _emailController.text = 'admin@test.com';
              _passwordController.text = 'password';
            },
            child: const Text('Login as Admin'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [              const Text('New to Yellowspot?'),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text('Create an Account'),
              ),            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.lock_person_outlined, size: 16, color: Colors.grey), SizedBox(width: 8), Text('Secured with 256-bit encryption', style: TextStyle(color: Colors.grey))],
          )
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, bool obscureText = false, FormFieldValidator<String>? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: obscureText ? const Icon(Icons.visibility_off_outlined) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }
}
