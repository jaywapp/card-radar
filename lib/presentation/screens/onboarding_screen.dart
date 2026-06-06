import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '카드명 또는 카드사 검색',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: cardsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('카드 목록을 불러올 수 없습니다')),
                  data: (cards) {
                    final filtered = _query.isEmpty
                        ? cards
                        : cards
                            .where((c) =>
                                c.name.toLowerCase().contains(_query) ||
                                c.issuer.toLowerCase().contains(_query))
                            .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('검색 결과가 없습니다',
                            style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final card = filtered[index];
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
                    );
                  },
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
