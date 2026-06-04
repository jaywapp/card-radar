import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';

class RankedCard {
  final Card card;
  final CardBenefit? benefit;
  final bool hasBenefit;

  const RankedCard({
    required this.card,
    this.benefit,
    required this.hasBenefit,
  });
}
