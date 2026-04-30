// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/authService_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool emailNotifications = true;
  bool newsletter = false;
  bool testerProgram = false;
  bool acceptedPolicy = false;
  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !acceptedPolicy) return;

    setState(() => isLoading = true);
    try {
      final result = await ref.read(authServiceProvider).registerUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),
        emailNotifications: emailNotifications,
        newsletter: newsletter,
        testerProgram: testerProgram,
      );
      if (result == RegistrationResult.partialSuccess) {
        // Show a dialog or special snackbar
        showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text("Welcome!"),
              content: const Text("Account created successfully, but we couldn't save your preferences. You can update them later in Settings."),
              actions: [TextButton(onPressed: () => context.go('/'), child: const Text("OK"))],
            )
        );
      }
      // GoRouter redirect logic handles the rest!
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the 'from' query param so it survives the transition to/from Login
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    final loginUrl = from != null ? '/login?from=${Uri.encodeComponent(from)}' : '/login';

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Email Notifications"),
              subtitle: const Text("Get notified of new numbers"),
              value: emailNotifications,
              onChanged: (v) => setState(() => emailNotifications = v),
            ),
            SwitchListTile(
              title: const Text("Join Newsletter"),
              value: newsletter,
              onChanged: (v) => setState(() => newsletter = v),
            ),
            SwitchListTile(
              title: const Text("Tester Program"),
              subtitle: const Text("Try new features first"),
              value: testerProgram,
              onChanged: (v) => setState(() => testerProgram = v),
            ),

            CheckboxListTile(
              title: InkWell(
                onTap: () => /* Open URL */ null,
                child: const Text("I accept the Privacy Policy",
                    style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
              ),
              value: acceptedPolicy,
              onChanged: (v) => setState(() => acceptedPolicy = v ?? false),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (isLoading || !acceptedPolicy) ? null : _submit,
              child: isLoading ? const CircularProgressIndicator() : const Text("Register"),
            ),
            TextButton(
              onPressed: () => context.go(loginUrl),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}