import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(AuthController.provider).asData?.value;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(AuthController.provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await ref
                            .read(AuthController.provider.notifier)
                            .updateUser(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                            );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Profile updated successfully!')),
                        );
                        navigator.pop();
                      },
                child: authState.isLoading ? const CircularProgressIndicator() : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
