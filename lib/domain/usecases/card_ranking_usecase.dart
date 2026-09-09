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
    final bestByCard = <String, CardBenefit>{};
    for (final benefit in allBenefits) {
      if (!_matches(benefit, benefit.cardId, category, merchantKey)) continue;
      final best = bestByCard[benefit.cardId];
      if (best == null || benefit.rate > best.rate) {
        bestByCard[benefit.cardId] = benefit;
      }
    }

    for (final card in userCards) {
      final benefit = bestByCard[card.id];

      if (benefit != null) {
        withBenefit.add(
          RankedCard(card: card, benefit: benefit, hasBenefit: true),
        );
      } else {
        withoutBenefit.add(RankedCard(card: card, hasBenefit: false));
      }
    }

    withBenefit.sort((a, b) => b.benefit!.rate.compareTo(a.benefit!.rate));
    return [...withBenefit, ...withoutBenefit];
  }

  bool _matches(
    CardBenefit b,
    String cardId,
    CardCategory category,
    String? merchantKey,
  ) {
    if (b.cardId != cardId || b.category != category) return false;
    if (merchantKey != null && b.merchants != null) {
      return b.merchants!.contains(merchantKey);
    }
    return true;
  }
}
