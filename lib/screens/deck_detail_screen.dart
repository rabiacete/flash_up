// screens/deck_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'study_screen.dart';

class DeckDetailScreen extends StatefulWidget {
  final String deckId;
  final String deckName;
  const DeckDetailScreen({super.key, required this.deckId, required this.deckName});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> cards = [];
  final TextEditingController frontController = TextEditingController();
  final TextEditingController backController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  Future<void> fetchCards() async {
    final response = await supabase
        .from('flashcards')
        .select()
        .eq('deck_id', widget.deckId)
        .order('created_at');
    setState(() {
      cards = response;
    });
  }

  Future<void> addCard() async {
    if (frontController.text.isEmpty || backController.text.isEmpty) return;
    await supabase.from('flashcards').insert({
      'deck_id': widget.deckId,
      'front': frontController.text,
      'back': backController.text,
      'example_sentence': exampleController.text,
    });
    frontController.clear();
    backController.clear();
    exampleController.clear();
    fetchCards();
  }

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deckName), actions: [
        IconButton(
          icon: const Icon(Icons.school),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudyScreen(cards: cards),
            ),
          ),
        )
      ]),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(controller: frontController, decoration: const InputDecoration(labelText: 'Ön Yüz')),
              TextField(controller: backController, decoration: const InputDecoration(labelText: 'Arka Yüz')),
              TextField(controller: exampleController, decoration: const InputDecoration(labelText: 'Örnek Cümle (isteğe bağlı)')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: addCard, child: const Text('Kelimeyi Kaydet'))
            ]),
          ),
          ...cards.map((card) => ExpansionTile(
                title: Text(card['front']),
                children: [
                  ListTile(title: Text('Arka: ${card['back']}')),
                  if (card['example_sentence'] != null && card['example_sentence'].isNotEmpty)
                    ListTile(title: Text('Cümle: ${card['example_sentence']}')),
                ],
              ))
        ],
      ),
    );
  }
}