import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userCardsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('내 카드 관리')),
      body: ListView.builder(
        itemCount: sampleCards.length,
        itemBuilder: (context, index) {
          final card = sampleCards[index];
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
    );
  }
}
