import 'package:flutter/material.dart';
import 'package:card_radar/data/models/category.dart';

class RankingScreen extends StatelessWidget {
  final CardCategory category;

  const RankingScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Ranking: ${category.label}')),
    );
  }
}
