import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/supabase_service.dart'; // supabase client buradan gelecek

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Hive başlatılıyor ve kutular açılıyor
  await Hive.initFlutter();
  await Hive.openBox('offline_decks');
  await Hive.openBox('offline_flashcards');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    return MaterialApp(
      title: 'Email Doğrulama',
      debugShowCheckedModeBanner: false,
      home: session != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}
