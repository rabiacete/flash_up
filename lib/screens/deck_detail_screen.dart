import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'study_screen.dart';
import 'package:uuid/uuid.dart';
import '../services/supabase_service.dart';

class DeckDetailScreen extends StatefulWidget {
  final String deckId;
  final String deckName;
  const DeckDetailScreen({super.key, required this.deckId, required this.deckName});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  List<dynamic> cards = [];
  final TextEditingController frontController = TextEditingController();
  final TextEditingController backController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> fetchCards() async {
    final box = Hive.box('offline_flashcards');
    final deckId = widget.deckId;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print("❌ Giriş yapılmamış, kartlar yüklenemedi.");
      return;
    }

    final cachedCards = box.get(deckId, defaultValue: []);
    setState(() {
      cards = List.from(cachedCards);
    });

    if (await isOnline()) {
      try {
        final response = await supabase
            .from('flashcards')
            .select()
            .eq('deck_id', deckId)
            .eq('user_id', userId)
            .order('created_at');

        await box.put(deckId, response);
        setState(() {
          cards = response;
        });
      } catch (e) {
        print("⚠️ Supabase flashcard fetch hatası: $e");
      }
    }
  }

  Future<void> addCard() async {
    if (frontController.text.isEmpty || backController.text.isEmpty) return;
    final userId = supabase.auth.currentUser!.id;
    final newCard = {
      'id': const Uuid().v4(),
      'deck_id': widget.deckId,
      'front': frontController.text,
      'back': backController.text,
      'example_sentence': exampleController.text,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final box = Hive.box('offline_flashcards');
    final localCards = List<Map<String, dynamic>>.from(box.get(widget.deckId, defaultValue: []));
    localCards.add(newCard);
    await box.put(widget.deckId, localCards);

    if (await isOnline()) {
      try {
        await supabase.from('flashcards').insert(newCard);
      } catch (_) {}
    }

    frontController.clear();
    backController.clear();
    exampleController.clear();
    fetchCards();
  }

  Future<void> editCard(Map<String, dynamic> card) async {
    final editedCard = {
      ...card,
      'front': frontController.text.isNotEmpty ? frontController.text : card['front'],
      'back': backController.text.isNotEmpty ? backController.text : card['back'],
      'example_sentence': exampleController.text.isNotEmpty
          ? exampleController.text
          : card['example_sentence'],
    };

    final box = Hive.box('offline_flashcards');
    final deckId = widget.deckId;
    final localCards = List.from(box.get(deckId, defaultValue: []));

    if (await isOnline()) {
      try {
        await supabase.from('flashcards').update(editedCard).eq('id', card['id']);
      } catch (_) {}
    }

    final index = localCards.indexWhere((c) => c['id'] == card['id']);
    if (index != -1) localCards[index] = editedCard;
    await box.put(deckId, localCards);
    fetchCards();
  }

  Future<void> deleteCard(String cardId) async {
    final box = Hive.box('offline_flashcards');
    final localCards =
        List<Map<String, dynamic>>.from(box.get(widget.deckId, defaultValue: []));
    localCards.removeWhere((card) => card['id'] == cardId);
    await box.put(widget.deckId, localCards);

    if (await isOnline()) {
      try {
        await supabase.from('flashcards').delete().eq('id', cardId);
      } catch (_) {}
    }

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
      backgroundColor: const Color(0xFF5B8BDF),
      appBar: AppBar(
        title: Text(
          widget.deckName,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5B8BDF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.school, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudyScreen(cards: cards)),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(
                controller: frontController,
                decoration: const InputDecoration(
                  labelText: 'Ön Yüz',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: backController,
                decoration: const InputDecoration(
                  labelText: 'Arka Yüz',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: exampleController,
                decoration: const InputDecoration(
                  labelText: 'Örnek Cümle (isteğe bağlı)',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addCard,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFFFFF)),
                child: const Text('Kelimeyi Kaydet'),
              )
            ]),
          ),
          ...cards.map((card) => ExpansionTile(
                title: Text(card['front'], style: const TextStyle(color: Colors.white)),
                children: [
                  ListTile(
                    title: Text('✅ ${card['back']}', style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        frontController.text = card['front'];
                        backController.text = card['back'];
                        exampleController.text = card['example_sentence'] ?? '';
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('EDIT✍️'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: frontController,
                                  decoration: const InputDecoration(labelText: 'Ön Yüz'),
                                ),
                                TextField(
                                  controller: backController,
                                  decoration: const InputDecoration(labelText: 'Arka Yüz'),
                                ),
                                TextField(
                                  controller: exampleController,
                                  decoration:
                                      const InputDecoration(labelText: 'Cümle (isteğe bağlı)'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  editCard(card);
                                  Navigator.pop(context);
                                },
                                child: const Text('Kaydet'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (card['example_sentence'] != null &&
                      card['example_sentence'].isNotEmpty)
                    ListTile(
                      title: Text('SENTENCE: ${card['example_sentence']}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ListTile(
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => deleteCard(card['id']),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
