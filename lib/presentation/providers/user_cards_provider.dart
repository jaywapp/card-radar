import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/repositories/user_card_repository.dart';

final userCardRepoProvider = Provider<UserCardRepository>((ref) {
  return UserCardRepository(box: Hive.box<String>('user_cards'));
});

class UserCardsNotifier extends StateNotifier<List<Card>> {
  final UserCardRepository _repo;

  UserCardsNotifier(this._repo)
      : super(sampleCards.where((c) => _repo.cardIds.contains(c.id)).toList());

  Future<void> addCard(String cardId) async {
    await _repo.addCard(cardId);
    state = sampleCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  Future<void> removeCard(String cardId) async {
    await _repo.removeCard(cardId);
    state = sampleCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  bool contains(String cardId) => _repo.contains(cardId);
}

final userCardsProvider =
    StateNotifierProvider<UserCardsNotifier, List<Card>>((ref) {
  return UserCardsNotifier(ref.read(userCardRepoProvider));
});
