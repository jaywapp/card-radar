import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/repositories/user_card_repository.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';

final userCardRepoProvider = Provider<UserCardRepository>((ref) {
  return UserCardRepository(box: Hive.box<String>('user_cards'));
});

class UserCardsNotifier extends StateNotifier<List<Card>> {
  final UserCardRepository _repo;
  final List<Card> _allCards;

  UserCardsNotifier(this._repo, this._allCards)
      : super(_allCards.where((c) => _repo.cardIds.contains(c.id)).toList());

  Future<void> addCard(String cardId) async {
    await _repo.addCard(cardId);
    state = _allCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  Future<void> removeCard(String cardId) async {
    await _repo.removeCard(cardId);
    state = _allCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  bool contains(String cardId) => _repo.contains(cardId);
}

final userCardsProvider =
    StateNotifierProvider<UserCardsNotifier, List<Card>>((ref) {
  final allCards = ref.watch(allCardsProvider).valueOrNull ?? sampleCards;
  return UserCardsNotifier(ref.read(userCardRepoProvider), allCards);
});
