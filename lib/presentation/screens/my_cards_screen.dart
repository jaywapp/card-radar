import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userCardsProvider.notifier);
    final cardsAsync = ref.watch(allCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('내 카드 관리')),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('카드 목록을 불러올 수 없습니다')),
        data: (cards) => ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return CheckboxListTile(
              title: Text(card.name),
              subtitle: Text(card.issuer),
              value: notifier.contains(card.id),
              onChanged: (checked) async {
                if (checked == true) {
                  await notifier.addCard(card.id);
                } else {
                  await notifier.removeCard(card.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
