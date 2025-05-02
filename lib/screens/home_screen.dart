// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_deck_screen.dart';
import 'deck_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> decks = [];

  Future<void> fetchDecks() async {
    final response = await supabase.from('decks').select().order('created_at');
    setState(() {
      decks = response;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: ListView(
        children: decks
            .map((deck) => ListTile(
                  title: Text(deck['name']),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeckDetailScreen(deckId: deck['id'], deckName: deck['name']),
                    ),
                  ),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDeckScreen()),
          );
          fetchDecks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
