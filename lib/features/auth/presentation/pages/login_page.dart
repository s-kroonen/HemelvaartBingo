// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> register() async {
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    final registerUrl = from != null ? '/register?from=${Uri.encodeComponent(from)}' : '/register';
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),

            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: const Text("Login"),
            ),

            TextButton(
              onPressed: () => context.go(registerUrl),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}