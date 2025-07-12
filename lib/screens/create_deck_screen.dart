import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';

class CreateDeckScreen extends StatefulWidget {
  const CreateDeckScreen({super.key});

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> createDeck() async {
    if (_controller.text.isEmpty) return;
    final name = _controller.text;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı oturumu bulunamadı.")),
      );
      return;
    }

    if (await isOnline()) {
      try {
        await supabase.from('decks').insert({
          'name': name,
          'user_id': userId,
        });
      } catch (e) {
        print("⚠️ Supabase deck insert hatası: $e");
      }
    } else {
      await saveDeckOffline(name); // 🔄 Local Hive’a kaydet
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Deste Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Deste Adı'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createDeck,
              child: const Text('Deste Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
