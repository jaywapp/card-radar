import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';
import 'package:card_radar/presentation/widgets/card_artwork.dart';

class CardRankItem extends StatelessWidget {
  final RankedCard rankedCard;
  final int rank;

  const CardRankItem({super.key, required this.rankedCard, required this.rank});

  Future<void> _launchApplyUrl(BuildContext context) async {
    final url = rankedCard.card.applyUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = rankedCard.card;
    final benefit = rankedCard.benefit;
    final hasBenefit = rankedCard.hasBenefit;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CardArtwork(card: card, height: 44),
          if (hasBenefit && rank > 0)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(card.issuer, style: const TextStyle(fontSize: 12)),
      trailing: hasBenefit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
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
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (benefit.conditions != null)
                      Text(
                        benefit.conditions!,
                        style: const TextStyle(fontSize: 10, color: Colors.orange),
                      ),
                  ],
                ),
                if (card.applyUrl != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _launchApplyUrl(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('신청', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            )
          : const Text('혜택 없음',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }
}
