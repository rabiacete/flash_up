import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/email_verified_screen.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DeeplinkHandler(),
    );
  }
}

class DeeplinkHandler extends StatefulWidget {
  const DeeplinkHandler({super.key});

  @override
  State<DeeplinkHandler> createState() => _DeeplinkHandlerState();
}

class _DeeplinkHandlerState extends State<DeeplinkHandler> {
  StreamSubscription? _deeplinkSub;

  @override
  void initState() {
    super.initState();
    _handleInitialUri();
    _deeplinkSub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeeplinkUri(uri);
      }
    });
  }

  /// İlk açılıştaki URI'yi kontrol etmek için
  Future<void> _handleInitialUri() async {
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeeplinkUri(initialUri);
      }
    } catch (e) {
      debugPrint('Deeplink Hatası: $e');
    }
  }

  /// Deeplink URI'sine göre yönlendirme
  void _handleDeeplinkUri(Uri uri) {
    // Eğer doğrulama linki geldiyse
    if (uri.scheme == 'myapp' && uri.host == 'email-verified') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerifiedScreen()),
      );
    }
  }

  @override
  void dispose() {
    _deeplinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return session != null ? const HomeScreen() : const LoginScreen();
  }
}