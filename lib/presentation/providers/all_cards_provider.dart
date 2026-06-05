import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/core/supabase_config.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/repositories/card_benefit_remote_repository.dart';

final allCardsProvider = FutureProvider<List<Card>>((ref) async {
  if (!supabaseConfigured) return sampleCards;
  try {
    final repo = CardBenefitRemoteRepository(Supabase.instance.client);
    return await repo.fetchCards();
  } catch (_) {
    return sampleCards;
  }
});
