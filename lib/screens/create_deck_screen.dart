// screens/create_deck_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateDeckScreen extends StatefulWidget {
  const CreateDeckScreen({super.key});

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();

  Future<void> createDeck() async {
    if (_controller.text.isEmpty) return;
    await supabase.from('decks').insert({'name': _controller.text});
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
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Deste Adı')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: createDeck, child: const Text('Deste Oluştur')),
          ],
        ),
      ),
    );
  }
}
