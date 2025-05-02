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
    final response = await supabase
        .from('decks')
        .select()
        .order('is_pinned', ascending: false) // Sabitlenenler üstte
        .order('created_at');
    setState(() {
      decks = response;
    });
  }

  Future<void> deleteDeck(String id) async {
    // Önce ilişkili flashcard'ları sil
    await supabase.from('flashcards').delete().eq('deck_id', id);

    // Ardından desteyi sil
    await supabase.from('decks').delete().eq('id', id);
    fetchDecks();
  }

  Future<void> togglePin(String id, bool currentPinState) async {
    // Sabitleme veya sabitlenmeyi kaldırma
    await supabase
        .from('decks')
        .update({'is_pinned': !currentPinState})
        .eq('id', id);
    fetchDecks();
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
      body: ListView.builder(
        itemCount: decks.length,
        itemBuilder: (context, index) {
          final deck = decks[index];
          return Dismissible(
            key: Key(deck['id']),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.blue,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                deck['is_pinned'] ? Icons.push_pin_outlined : Icons.push_pin,
                color: Colors.white,
              ),
            ),
            // Sağa kaydırınca sil, sola kaydırınca sabitle
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // sağa kaydırma → sil
                await deleteDeck(deck['id']);
                return true;
              } else if (direction == DismissDirection.endToStart) {
                // sola kaydırma → sabitle
                await togglePin(deck['id'], deck['is_pinned'] ?? false);
                return false; // kart silinmesin, sadece güncellensin
              }
              return false;
            },
            child: Card(
              child: ListTile(
                title: Text(deck['name'] ?? 'İsimsiz Deste'),
                trailing: deck['is_pinned'] == true
                    ? const Icon(Icons.push_pin, color: Colors.orange)
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeckDetailScreen(
                      deckId: deck['id'],
                      deckName: deck['name'],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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