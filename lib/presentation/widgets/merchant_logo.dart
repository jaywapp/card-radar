import 'package:flutter/material.dart';
import 'package:card_radar/core/merchant_categories.dart';

class MerchantLogo extends StatelessWidget {
  final String? merchantKey;
  final String fallbackEmoji;
  final double size;

  const MerchantLogo({
    super.key,
    this.merchantKey,
    required this.fallbackEmoji,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final domain = merchantKey != null ? merchantDomainMap[merchantKey] : null;
    if (domain == null) return _emoji();

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          'https://logo.clearbit.com/$domain',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _emoji(),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _emoji(),
        ),
      ),
    );
  }

  Widget _emoji() => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(fallbackEmoji, style: TextStyle(fontSize: size * 0.65)),
        ),
      );
}
