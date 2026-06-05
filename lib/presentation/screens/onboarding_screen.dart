import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userCardsProvider.notifier);
    final userCards = ref.watch(userCardsProvider);
    final cardsAsync = ref.watch(allCardsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('👋 보유 카드를 선택해 주세요',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('결제 시 가장 유리한 카드를 추천해 드려요',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Expanded(
                child: cardsAsync.when(
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
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: userCards.isEmpty ? null : () => context.go('/home'),
                  child: const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
