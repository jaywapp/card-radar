import 'package:flutter/material.dart';
import 'package:card_radar/data/models/card.dart' as app;

class CardArtwork extends StatelessWidget {
  final app.Card card;
  final double height;

  const CardArtwork({super.key, required this.card, this.height = 44});

  @override
  Widget build(BuildContext context) {
    final width = height * 1.586;
    if (card.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.network(
            card.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _gradient(width),
          ),
        ),
      );
    }
    return _gradient(width);
  }

  Widget _gradient(double width) {
    final textColor = _textColor();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: _issuerGradient(),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: EdgeInsets.all(height * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _shortIssuer(),
            style: TextStyle(color: textColor, fontSize: height * 0.22, fontWeight: FontWeight.bold, letterSpacing: -0.3),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            card.name,
            style: TextStyle(color: textColor.withValues(alpha: 0.85), fontSize: height * 0.18),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _shortIssuer() => card.issuer
      .replaceAll('카드', '')
      .replaceAll('뱅크', '')
      .replaceAll('국민', '')
      .trim();

  Color _textColor() {
    final i = card.issuer;
    if (i.contains('KB') || i.contains('카카오')) return Colors.black87;
    return Colors.white;
  }

  LinearGradient _issuerGradient() {
    final i = card.issuer;
    if (i.contains('신한')) return const LinearGradient(colors: [Color(0xFF0046FF), Color(0xFF00B0FF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('현대')) return const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF555555)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('KB') || i.contains('국민')) return const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFFF176)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('삼성')) return const LinearGradient(colors: [Color(0xFF1428A0), Color(0xFF0070C0)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('롯데')) return const LinearGradient(colors: [Color(0xFFCC0000), Color(0xFFFF6B6B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('우리')) return const LinearGradient(colors: [Color(0xFF0070C0), Color(0xFF00A0E9)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('하나')) return const LinearGradient(colors: [Color(0xFF00703C), Color(0xFF00A550)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('NH') || i.contains('농협')) return const LinearGradient(colors: [Color(0xFF005A20), Color(0xFF00A040)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('BC')) return const LinearGradient(colors: [Color(0xFF005BAC), Color(0xFF0080CC)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('카카오')) return const LinearGradient(colors: [Color(0xFFFFE000), Color(0xFFFFF9C4)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    if (i.contains('토스')) return const LinearGradient(colors: [Color(0xFF0064FF), Color(0xFF4095FF)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    return const LinearGradient(colors: [Color(0xFF37474F), Color(0xFF607D8B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  }
}
