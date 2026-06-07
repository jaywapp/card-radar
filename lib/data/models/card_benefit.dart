import 'package:card_radar/data/models/category.dart';

class CardBenefit {
  final String cardId;
  final CardCategory category;
  final String benefitType; // 'cashback' | 'points'
  final double rate;
  final String? conditions;
  final List<String>? merchants; // null이면 업종 전체 적용

  const CardBenefit({
    required this.cardId,
    required this.category,
    required this.benefitType,
    required this.rate,
    this.conditions,
    this.merchants,
  });
}
