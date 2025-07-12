import 'package:flutter/material.dart';
import 'create_deck_screen.dart';
import 'deck_detail_screen.dart';
import 'package:hive/hive.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> decks = [];
  Map<String, int> cardCounts = {};

  Future<void> fetchDecks() async {
    final userId = supabase.auth.currentUser?.id;
    print("✅ Login user ID: $userId");

    if (userId == null) {
      print("❌ Kullanıcı oturumu yok.");
      return;
    }

    try {
      final response = await supabase
          .from('decks')
          .select()
          .eq('user_id', userId)
          .order('is_pinned', ascending: false)
          .order('created_at');

      final localBox = Hive.box('offline_decks');
      await localBox.put('decks', response);

      setState(() {
        decks = response;
      });

      await fetchCardCounts(userId);
    } catch (e) {
      print("⚠️ Supabase'ten çekilemedi: $e");

      final localBox = Hive.box('offline_decks');
      final localDecks = localBox.get('decks', defaultValue: []);
      setState(() {
        decks = List<Map<String, dynamic>>.from(localDecks);
      });
    }
  }

  Future<void> fetchCardCounts(String userId) async {
    try {
      for (var deck in decks) {
        final response = await supabase
            .from('flashcards')
            .select('id')
            .eq('deck_id', deck['id'])
            .eq('user_id', userId);

        setState(() {
          cardCounts[deck['id']] = response.length;
        });
      }
    } catch (e) {
      print("⚠️ Kart sayısı alınamadı: $e");
    }
  }

  Future<void> deleteDeck(String id) async {
    await supabase.from('flashcards').delete().eq('deck_id', id);
    await supabase.from('decks').delete().eq('id', id);
    fetchDecks();
  }

  Future<void> togglePin(String id, bool currentPinState) async {
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
    syncPendingDecks(); // Hive senkronizasyon fonksiyonu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flashcards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF5B8BDF),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/walpaper1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index];
            final cardCount = cardCounts[deck['id']] ?? 0;

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
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await deleteDeck(deck['id']);
                  return true;
                } else if (direction == DismissDirection.endToStart) {
                  await togglePin(deck['id'], deck['is_pinned'] ?? false);
                  return false;
                }
                return false;
              },
              child: Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(
                    deck['name'] ?? 'İsimsiz Deste',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF5B8BDF),
                        child: Text(
                          '$cardCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (deck['is_pinned'] == true)
                        const Icon(Icons.push_pin, color: Colors.orange),
                    ],
                  ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDeckScreen()),
          );
          fetchDecks(); // yeni deste sonrası güncelle
        },
        backgroundColor: const Color(0xFF5B8BDF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
