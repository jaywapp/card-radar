import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        actions: [
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '어디서 결제하나요?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (userCards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('카드를 먼저 등록해 주세요',
                  style: TextStyle(color: Colors.grey)),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: CardCategory.values.length,
              itemBuilder: (context, index) {
                final category = CardCategory.values[index];
                return _CategoryCard(category: category);
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
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/ranking', extra: category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              category.label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
