import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/card.dart' as app;
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/benefits_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

void showMerchantCardSheet(
  BuildContext context, {
  required String? merchantName,
  required CardCategory category,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => _SheetBody(
        merchantName: merchantName,
        category: category,
        scrollController: scrollController,
      ),
    ),
  );
}

class _SheetBody extends ConsumerWidget {
  final String? merchantName;
  final CardCategory category;
  final ScrollController scrollController;

  const _SheetBody({
    required this.merchantName,
    required this.category,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCards = ref.watch(userCardsProvider);
    final benefits = ref.watch(benefitsProvider).valueOrNull ?? sampleBenefits;
    final allCards = ref.watch(allCardsProvider).valueOrNull ?? sampleCards;

    final ranked = CardRankingUseCase().rank(
      category: category,
      userCards: userCards,
      allBenefits: benefits,
    );

    final userCardIds = userCards.map((c) => c.id).toSet();
    final suggested = _suggestedCards(allCards, benefits, userCardIds);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _handle(),
        _header(context),
        if (userCards.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('카드를 먼저 등록해 주세요', textAlign: TextAlign.center),
          )
        else ...[
          _sectionLabel(context, '내 카드 추천'),
          ...ranked.take(5).toList().asMap().entries.map(
                (e) => _userCardTile(context, e.value, e.key + 1),
              ),
          if (ranked.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/ranking', extra: category);
                },
                child: const Text('전체 보기'),
              ),
            ),
        ],
        if (suggested.isNotEmpty) ...[
          const Divider(height: 32),
          _sectionLabel(context, '이런 카드 어때요?'),
          ...suggested.map((e) => _suggestedCardTile(context, e.$1, e.$2)),
        ],
      ],
    );
  }

  List<(app.Card, CardBenefit)> _suggestedCards(
    List<app.Card> all,
    List<CardBenefit> benefits,
    Set<String> userIds,
  ) {
    final result = <(app.Card, CardBenefit)>[];
    for (final card in all) {
      if (userIds.contains(card.id)) continue;
      final best = benefits
          .where((b) => b.cardId == card.id && b.category == category)
          .fold<CardBenefit?>(
              null, (b, e) => b == null || e.rate > b.rate ? e : b);
      if (best != null) result.add((card, best));
    }
    result.sort((a, b) => b.$2.rate.compareTo(a.$2.rate));
    return result.take(3).toList();
  }

  Widget _handle() => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (merchantName != null)
                  Text(merchantName!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: merchantName != null ? 13 : 18,
                    color: merchantName != null ? Colors.grey : null,
                    fontWeight: merchantName != null
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

  Widget _userCardTile(BuildContext context, RankedCard item, int rank) {
    final isTop = rank == 1 && item.hasBenefit;
    return ListTile(
      tileColor: isTop
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25)
          : null,
      leading: CircleAvatar(
        backgroundColor: item.hasBenefit
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Text(
          item.hasBenefit ? '$rank' : '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item.hasBenefit
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey,
          ),
        ),
      ),
      title: Row(
        children: [
          Text(item.card.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          if (isTop) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 14, color: Colors.amber),
          ],
        ],
      ),
      subtitle: Text(item.card.issuer,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: item.hasBenefit
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.benefit!.rate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  item.benefit!.benefitType == 'cashback' ? '캐시백' : '포인트',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            )
          : const Text('혜택 없음',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget _suggestedCardTile(BuildContext context, app.Card card, CardBenefit benefit) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade100,
        child: const Icon(Icons.add_card, color: Colors.orange, size: 20),
      ),
      title: Text(card.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(card.issuer,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${benefit.rate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                benefit.benefitType == 'cashback' ? '캐시백' : '포인트',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          if (card.applyUrl != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _launch(context, card.applyUrl!),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('신청', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('링크를 열 수 없습니다')));
      }
    }
  }
}
