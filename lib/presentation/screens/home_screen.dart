import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCards = ref.watch(userCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드레이더'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '업체 검색',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.credit_card),
            tooltip: '내 카드 관리',
            onPressed: () => context.push('/my-cards'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              '어디서 결제하나요?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (userCards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('카드를 먼저 등록해 주세요'),
                  subtitle: const Text('우측 상단에서 카드를 추가할 수 있어요'),
                  onTap: () => context.push('/my-cards'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${userCards.length}개 카드 등록됨',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: CardCategory.values.length,
              itemBuilder: (context, index) {
                final category = CardCategory.values[index];
                final benefitCount = userCards.isEmpty
                    ? 0
                    : userCards.where((card) => sampleBenefits.any(
                        (b) => b.cardId == card.id && b.category == category,
                      )).length;
                return _CategoryCard(
                  category: category,
                  benefitCount: benefitCount,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CardCategory category;
  final int benefitCount;

  const _CategoryCard({
    required this.category,
    required this.benefitCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/ranking', extra: category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: benefitCount > 0
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.emoji,
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 6),
                  Text(
                    category.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (benefitCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$benefitCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
