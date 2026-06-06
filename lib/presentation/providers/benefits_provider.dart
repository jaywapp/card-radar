import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/core/supabase_config.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/repositories/card_benefit_remote_repository.dart';

final benefitsProvider = FutureProvider<List<CardBenefit>>((ref) async {
  if (!supabaseConfigured) return sampleBenefits;
  try {
    final repo = CardBenefitRemoteRepository(Supabase.instance.client);
    final benefits = await repo.fetchBenefits();
    return benefits.isEmpty ? sampleBenefits : benefits;
  } catch (_) {
    return sampleBenefits;
  }
});

final remoteCardsProvider = FutureProvider<List<Card>>((ref) async {
  if (!supabaseConfigured) return sampleCards;
  try {
    final repo = CardBenefitRemoteRepository(Supabase.instance.client);
    final cards = await repo.fetchCards();
    return cards.isEmpty ? sampleCards : cards;
  } catch (_) {
    return sampleCards;
  }
});
