import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';
import 'package:card_radar/presentation/providers/benefits_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';
import 'package:card_radar/presentation/widgets/card_rank_item.dart';

class RankingScreen extends ConsumerWidget {
  final CardCategory category;
  final String? merchantKey;
  final String? merchantName;

  const RankingScreen({
    super.key,
    required this.category,
    this.merchantKey,
    this.merchantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCards = ref.watch(userCardsProvider);
    final benefitsAsync = ref.watch(benefitsProvider);

    final title = merchantName != null
        ? '$merchantName (${category.label})'
        : '${category.emoji} ${category.label}';

    if (userCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('내 카드를 먼저 등록해 주세요')),
      );
    }

    return benefitsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('데이터를 불러올 수 없습니다')),
      ),
      data: (benefits) {
        final useCase = CardRankingUseCase();
        final ranked = useCase.rank(
          category: category,
          userCards: userCards,
          allBenefits: benefits,
          merchantKey: merchantKey,
        );
        int rank = 1;
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${userCards.length}개 카드 기준',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ),
            ),
          ),
          body: ListView.separated(
            itemCount: ranked.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = ranked[index];
              final displayRank = item.hasBenefit ? rank++ : 0;
              return CardRankItem(rankedCard: item, rank: displayRank);
            },
          ),
        );
      },
    );
  }
}
