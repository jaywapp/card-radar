enum CardCategory {
  convenience('편의점', '🏪'),
  cafe('카페', '☕'),
  restaurant('식당', '🍽️'),
  gasStation('주유소', '⛽'),
  transit('대중교통', '🚌'),
  online('온라인쇼핑', '🛒'),
  mart('마트', '🛍️'),
  pharmacy('약국', '💊');

  final String label;
  final String emoji;
  const CardCategory(this.label, this.emoji);
}
