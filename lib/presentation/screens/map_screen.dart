import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:card_radar/core/merchant_categories.dart';
import 'package:card_radar/core/naver_map_config.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/presentation/widgets/merchant_card_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _searchController = TextEditingController();
  List<MapEntry<String, CardCategory>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final results = searchMerchants(query);
    setState(() {
      _suggestions = results.take(6).toList();
    });
  }

  void _onSearch(String query) {
    final q = query.trim();
    _clearSearch();
    if (q.isEmpty) return;
    final category = findCategory(q);
    if (category != null) {
      showMerchantCardSheet(context, merchantName: q, category: category);
    } else {
      // 매칭 실패 시 카테고리 직접 선택으로 fallback
      _showCategoryPicker();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = []);
  }

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('어떤 업종인가요?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...CardCategory.values.map((cat) => ListTile(
                leading: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(cat.label),
                onTap: () {
                  Navigator.pop(ctx);
                  showMerchantCardSheet(context,
                      merchantName: null, category: cat);
                },
              )),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    return AppBar(
      backgroundColor: colorScheme.primary,
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '업체명 검색 (예: 스타벅스, GS25)',
          border: InputBorder.none,
          hintStyle: TextStyle(color: onPrimary.withValues(alpha: 0.6)),
          suffixIcon: _suggestions.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: onPrimary),
                  onPressed: _clearSearch,
                )
              : IconButton(
                  icon: Icon(Icons.search, color: onPrimary),
                  onPressed: () => _onSearch(_searchController.text),
                ),
        ),
        style: TextStyle(color: onPrimary),
        onChanged: _onSearchChanged,
        onSubmitted: _onSearch,
      ),
      iconTheme: IconThemeData(color: onPrimary),
    );
  }

  Widget _buildSuggestions() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 8,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final entry = _suggestions[index];
            return ListTile(
              dense: true,
              leading: Text(entry.value.emoji,
                  style: const TextStyle(fontSize: 20)),
              title: Text(entry.key),
              trailing: Text(entry.value.label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12)),
              onTap: () => _onSearch(entry.key),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchBar(),
      body: Stack(
        children: [
          naverMapsConfigured ? _buildMap() : _buildPlaceholder(),
          if (_suggestions.isNotEmpty) _buildSuggestions(),
        ],
      ),
      floatingActionButton: _suggestions.isEmpty
          ? FloatingActionButton(
              onPressed: _showCategoryPicker,
              tooltip: '카테고리로 찾기',
              child: const Icon(Icons.credit_card),
            )
          : null,
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
