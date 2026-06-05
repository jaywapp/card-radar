import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/naver_map_config.dart';
import 'package:card_radar/data/models/category.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!naverMapsConfigured) {
      return _buildPlaceholder(context);
    }
    return _buildMap(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 업체 지도')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '네이버 지도 API 설정 필요',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'console.ncloud.com에서 Client ID를 발급받아\nnaver_map_config.dart에 입력해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('업체명으로 검색하기'),
              onPressed: () => context.push('/search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 업체 지도')),
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5665, 126.9780), // 서울 시청
            zoom: 14,
          ),
          locationButtonEnable: true,
        ),
        onMapReady: (controller) {},
        onSymbolTapped: (symbol) {
          _showCategoryPicker(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryPicker(context),
        child: const Icon(Icons.credit_card),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
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
                leading: Text(cat.emoji,
                    style: const TextStyle(fontSize: 24)),
                title: Text(cat.label),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/ranking', extra: cat);
                },
              )),
        ],
      ),
    );
  }
}
