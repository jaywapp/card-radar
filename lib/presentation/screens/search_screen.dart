import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/merchant_categories.dart';
import 'package:card_radar/data/models/category.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<MapEntry<String, CardCategory>> _results = [];

  void _onChanged(String query) {
    setState(() {
      _results = searchMerchants(query);
    });
  }

  void _onSubmit(String query) {
    final category = findCategory(query);
    if (category != null) {
      context.push('/ranking', extra: category);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '업체명 검색 (예: 스타벅스, 이마트)',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: _onSubmit,
        ),
      ),
      body: _results.isEmpty && _controller.text.isEmpty
          ? _buildSuggestions()
          : _results.isEmpty
              ? _buildNoResult()
              : _buildResults(),
    );
  }

  Widget _buildSuggestions() {
    final examples = [
      ('스타벅스', CardCategory.cafe),
      ('이마트', CardCategory.mart),
      ('GS25', CardCategory.convenience),
      ('쿠팡', CardCategory.online),
      ('맥도날드', CardCategory.restaurant),
      ('SK주유소', CardCategory.gasStation),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('자주 찾는 업체',
              style: Theme.of(context).textTheme.labelLarge),
        ),
        ...examples.map((e) => ListTile(
              leading: Text(e.$2.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(e.$1),
              subtitle: Text(e.$2.label),
              onTap: () => context.push('/ranking', extra: e.$2),
            )),
      ],
    );
  }

  Widget _buildNoResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('"${_controller.text}" 검색 결과 없음',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          const Text('카테고리를 직접 선택해 주세요',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final entry = _results[index];
        return ListTile(
          leading: Text(entry.value.emoji,
              style: const TextStyle(fontSize: 24)),
          title: Text(entry.key),
          subtitle: Text(entry.value.label),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/ranking', extra: entry.value),
        );
      },
    );
  }
}
