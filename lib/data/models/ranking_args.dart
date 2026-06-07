import 'package:card_radar/data/models/category.dart';

class RankingArgs {
  final CardCategory category;
  final String? merchantKey;
  final String? merchantName;

  const RankingArgs({
    required this.category,
    this.merchantKey,
    this.merchantName,
  });
}
