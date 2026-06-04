import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';

class CardRankingUseCase {
  List<RankedCard> rank({
    required CardCategory category,
    required List<Card> userCards,
    required List<CardBenefit> allBenefits,
  }) {
    if (userCards.isEmpty) return [];

    final withBenefit = <RankedCard>[];
    final withoutBenefit = <RankedCard>[];

    for (final card in userCards) {
      final benefit = allBenefits
          .where((b) => b.cardId == card.id && b.category == category)
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
}
