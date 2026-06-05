class Card {
  final String id;
  final String name;
  final String issuer;
  final String? applyUrl;

  const Card({
    required this.id,
    required this.name,
    required this.issuer,
    this.applyUrl,
  });
}
