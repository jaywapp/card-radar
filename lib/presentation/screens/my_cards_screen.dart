import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/kftc_import_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class MyCardsScreen extends ConsumerStatefulWidget {
  const MyCardsScreen({super.key});

  @override
  ConsumerState<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends ConsumerState<MyCardsScreen> {
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
    final cardsAsync = ref.watch(allCardsProvider);
    final importState = ref.watch(kftcImportProvider);

    ref.listen(kftcImportProvider, (_, next) {
      if (next.status == KftcImportStatus.success ||
          next.status == KftcImportStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? '')),
        );
        ref.read(kftcImportProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 카드 관리'),
        actions: [
          _ImportButton(importState: importState),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
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
          ),
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
        ],
      ),
    );
  }
}

class _ImportButton extends ConsumerWidget {
  final KftcImportState importState;
  const _ImportButton({required this.importState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = importState.status == KftcImportStatus.loading ||
        importState.status == KftcImportStatus.waitingCallback;

    return isLoading
        ? const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: '내 카드 불러오기 (오픈뱅킹)',
            onPressed: () => ref.read(kftcImportProvider.notifier).startOAuth(),
          );
  }
}
