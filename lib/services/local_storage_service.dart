import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart'; // Yeni supabase import'u

/// OFFLINE MOD: Yeni deste oluşturulduğunda local Hive’a kaydedilir.
Future<void> saveDeckOffline(String name) async {
  final box = await Hive.openBox('offline_decks');
  final List decks = box.get('pending_decks', defaultValue: []);
  final userId = supabase.auth.currentUser?.id;

  decks.add({
    'id': const Uuid().v4(),
    'name': name,
    'is_pinned': false,
    'created_at': DateTime.now().toIso8601String(),
    'user_id': userId,
    'sync': false,
  });

  await box.put('pending_decks', decks);
}

/// ONLINE OLUNDUĞUNDA: Hive’daki pending_decks verisi Supabase’e gönderilir.
Future<void> syncPendingDecks() async {
  final box = await Hive.openBox('offline_decks');
  final pendingDecks = List<Map<String, dynamic>>.from(
    box.get('pending_decks', defaultValue: []),
  );

  final syncedDecks = [];

  for (final deck in pendingDecks) {
    try {
      await supabase.from('decks').insert({
        'name': deck['name'],
        'is_pinned': deck['is_pinned'],
        'created_at': deck['created_at'],
        'user_id': deck['user_id'],
      });
      syncedDecks.add(deck);
    } catch (_) {
      // Sync hatası alırsa, bu deck kalır
    }
  }

  // Başarıyla gönderilenleri temizle
  pendingDecks.removeWhere((deck) => syncedDecks.contains(deck));
  await box.put('pending_decks', pendingDecks);
}
