import 'package:flutter/material.dart';

class ConfirmationInfoScreen extends StatelessWidget {
  const ConfirmationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilgilendirme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.email, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Kayıt işleminiz başarıyla tamamlandı!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lütfen e-postanızı kontrol edin ve doğrulama bağlantısına tıklayın. '
              'E-posta doğrulamasını tamamladıktan sonra giriş yapabilirsiniz.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Giriş Ekranına Dön'),
            ),
          ],
        ),
      ),
    );
  }
}