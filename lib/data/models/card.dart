class Card {
  final String id;
  final String name;
  final String issuer;
  final String? applyUrl;
  final String? imageUrl;

  const Card({
    required this.id,
    required this.name,
    required this.issuer,
    this.applyUrl,
    this.imageUrl,
  });
}
