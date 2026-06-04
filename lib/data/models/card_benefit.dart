import 'package:card_radar/data/models/category.dart';

class CardBenefit {
  final String cardId;
  final CardCategory category;
  final String benefitType; // 'cashback' | 'points'
  final double rate;
  final String? conditions;

  const CardBenefit({
    required this.cardId,
    required this.category,
    required this.benefitType,
    required this.rate,
    this.conditions,
  });
}
