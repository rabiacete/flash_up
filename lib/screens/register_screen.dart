import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'confirmation_info_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> register() async {
    try {
      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConfirmationInfoScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kayıt sırasında bir hata oluştu: ${e.toString()}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}