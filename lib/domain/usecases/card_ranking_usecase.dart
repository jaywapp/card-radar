import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';

class CardRankingUseCase {
  List<RankedCard> rank({
    required CardCategory category,
    required List<Card> userCards,
    required List<CardBenefit> allBenefits,
    String? merchantKey,
  }) {
    if (userCards.isEmpty) return [];

    final withBenefit = <RankedCard>[];
    final withoutBenefit = <RankedCard>[];

    for (final card in userCards) {
      final benefit = allBenefits
          .where((b) => _matches(b, card.id, category, merchantKey))
          .fold<CardBenefit?>(
              null, (best, b) => best == null || b.rate > best.rate ? b : best);

      if (benefit != null) {
        withBenefit.add(RankedCard(card: card, benefit: benefit, hasBenefit: true));
      } else {
        withoutBenefit.add(RankedCard(card: card, hasBenefit: false));
      }
    }

    withBenefit.sort((a, b) => b.benefit!.rate.compareTo(a.benefit!.rate));
    return [...withBenefit, ...withoutBenefit];
  }

  bool _matches(CardBenefit b, String cardId, CardCategory category, String? merchantKey) {
    if (b.cardId != cardId || b.category != category) return false;
    if (merchantKey != null && b.merchants != null) {
      return b.merchants!.contains(merchantKey);
    }
    return true;
  }
}
