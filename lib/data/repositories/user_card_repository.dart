import 'package:hive_ce/hive.dart';

class UserCardRepository {
  final Box<String> box;
  static const _key = 'card_ids';

  UserCardRepository({required this.box});

  List<String> get cardIds {
    final stored = box.get(_key);
    if (stored == null || stored.isEmpty) return [];
    return stored.split(',');
  }

  Future<void> addCard(String cardId) async {
    final ids = {...cardIds, cardId}.toList();
    await box.put(_key, ids.join(','));
  }

  Future<void> removeCard(String cardId) async {
    final ids = cardIds.where((id) => id != cardId).toList();
    await box.put(_key, ids.join(','));
  }

  bool contains(String cardId) => cardIds.contains(cardId);
}
