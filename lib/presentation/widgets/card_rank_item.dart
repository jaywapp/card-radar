import 'package:flutter/material.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';

class CardRankItem extends StatelessWidget {
  final RankedCard rankedCard;
  final int rank;

  const CardRankItem({super.key, required this.rankedCard, required this.rank});

  @override
  Widget build(BuildContext context) {
    final card = rankedCard.card;
    final benefit = rankedCard.benefit;
    final hasBenefit = rankedCard.hasBenefit;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: hasBenefit
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Text(
          hasBenefit ? '$rank' : '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasBenefit
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey,
          ),
        ),
      ),
      title: Text(card.name),
      subtitle: Text(card.issuer),
      trailing: hasBenefit
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${benefit!.rate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  benefit.benefitType == 'cashback' ? '캐시백' : '포인트',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (benefit.conditions != null)
                  Text(
                    benefit.conditions!,
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
              ],
            )
          : const Text('혜택 없음',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }
}
