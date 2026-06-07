import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';

class CardBenefitRemoteRepository {
  final SupabaseClient _client;

  CardBenefitRemoteRepository(this._client);

  Future<List<Card>> fetchCards() async {
    final rows = await _client.from('cards').select();
    return rows.map((r) => Card(
          id: r['id'] as String,
          name: r['name'] as String,
          issuer: r['issuer'] as String,
          applyUrl: r['apply_url'] as String?,
          imageUrl: r['image_url'] as String?,
        )).toList();
  }

  Future<List<CardBenefit>> fetchBenefits() async {
    final rows = await _client.from('card_benefits').select();
    return rows.map((r) {
      final categoryStr = r['category'] as String;
      final category = CardCategory.values.firstWhere(
        (c) => c.name == categoryStr,
        orElse: () => CardCategory.restaurant,
      );
      return CardBenefit(
        cardId: r['card_id'] as String,
        category: category,
        benefitType: r['benefit_type'] as String,
        rate: (r['rate'] as num).toDouble(),
        conditions: r['conditions'] as String?,
        merchants: (r['merchants'] as List<dynamic>?)?.cast<String>(),
      );
    }).toList();
  }
}
