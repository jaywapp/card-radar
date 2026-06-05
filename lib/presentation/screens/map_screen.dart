import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/merchant_categories.dart';
import 'package:card_radar/core/naver_map_config.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';
import 'package:card_radar/presentation/providers/benefits_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final category = findCategory(q);
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$q" 업체를 찾을 수 없어요')),
      );
      return;
    }
    _showMiniRanking(category);
  }

  void _showMiniRanking(CardCategory category) {
    final userCards = ref.read(userCardsProvider);
    final benefits = ref.read(benefitsProvider).valueOrNull ?? [];
    final ranked = CardRankingUseCase()
        .rank(category: category, userCards: userCards, allBenefits: benefits)
        .where((r) => r.hasBenefit)
        .take(3)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: Row(
                children: [
                  Text(
                    '${category.emoji} ${category.label} 추천 카드',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/ranking', extra: category);
                    },
                    child: const Text('전체보기'),
                  ),
                ],
              ),
            ),
            if (userCards.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('카드를 먼저 등록해 주세요'),
              )
            else if (ranked.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('이 카테고리에 혜택 있는 카드가 없어요'),
              )
            else
              ...ranked.asMap().entries.map((e) {
                final item = e.value;
                final typeLabel =
                    item.benefit!.benefitType == 'cashback' ? '캐시백' : '포인트';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Text('${e.key + 1}'),
                  ),
                  title: Text(item.card.name),
                  subtitle: Text('$typeLabel ${item.benefit!.rate}%'),
                );
              }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('카테고리 선택',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...CardCategory.values.map((cat) => ListTile(
                leading: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(cat.label),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMiniRanking(cat);
                },
              )),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '업체명 검색 (예: 스타벅스, GS25)',
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.white60),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _onSearch(_searchController.text),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: _onSearch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchBar(),
      body: naverMapsConfigured ? _buildMap() : _buildPlaceholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCategoryPicker,
        tooltip: '카테고리로 찾기',
        child: const Icon(Icons.credit_card),
      ),
    );
  }

  Widget _buildMap() {
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(37.5665, 126.9780),
          zoom: 15,
        ),
        locationButtonEnable: true,
      ),
      onMapReady: (controller) {},
      onSymbolTapped: (symbol) => _showCategoryPicker(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('네이버 지도 API 설정 필요',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'console.ncloud.com에서 Client ID를 발급받아\nnaver_map_config.dart에 입력해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.category),
            label: const Text('카테고리로 찾기'),
            onPressed: _showCategoryPicker,
          ),
        ],
      ),
    );
  }
}
