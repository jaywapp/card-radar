import 'package:flutter_test/flutter_test.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';

void main() {
  final cards = [
    const Card(id: 'card-a', name: 'Card A', issuer: 'Bank A'),
    const Card(id: 'card-b', name: 'Card B', issuer: 'Bank B'),
    const Card(id: 'card-c', name: 'Card C', issuer: 'Bank C'),
  ];

  final benefits = [
    const CardBenefit(cardId: 'card-a', category: CardCategory.convenience, benefitType: 'cashback', rate: 5.0),
    const CardBenefit(cardId: 'card-b', category: CardCategory.convenience, benefitType: 'points', rate: 3.0),
    const CardBenefit(cardId: 'card-a', category: CardCategory.cafe, benefitType: 'cashback', rate: 2.0),
  ];

  late CardRankingUseCase useCase;
  setUp(() => useCase = CardRankingUseCase());

  test('카테고리 일치 카드를 rate 내림차순으로 정렬', () {
    final result = useCase.rank(
      category: CardCategory.convenience,
      userCards: cards,
      allBenefits: benefits,
    );
    expect(result[0].card.id, 'card-a');
    expect(result[0].benefit!.rate, 5.0);
    expect(result[1].card.id, 'card-b');
    expect(result[1].benefit!.rate, 3.0);
  });

  test('혜택 없는 카드는 hasBenefit=false로 하단에 위치', () {
    final result = useCase.rank(
      category: CardCategory.convenience,
      userCards: cards,
      allBenefits: benefits,
    );
    expect(result.last.card.id, 'card-c');
    expect(result.last.hasBenefit, false);
  });

  test('해당 카테고리 혜택이 없으면 모두 hasBenefit=false', () {
    final result = useCase.rank(
      category: CardCategory.gasStation,
      userCards: cards,
      allBenefits: benefits,
    );
    expect(result.every((r) => !r.hasBenefit), isTrue);
  });

  test('보유 카드 없으면 빈 목록 반환', () {
    final result = useCase.rank(
      category: CardCategory.convenience,
      userCards: [],
      allBenefits: benefits,
    );
    expect(result, isEmpty);
  });

  final merchantBenefits = [
    const CardBenefit(cardId: 'card-a', category: CardCategory.convenience, benefitType: 'cashback', rate: 5.0, merchants: ['gs25']),
    const CardBenefit(cardId: 'card-b', category: CardCategory.convenience, benefitType: 'points', rate: 3.0, merchants: ['cu']),
  ];

  test('merchantKey가 주어지면 해당 가맹점 혜택만 매칭된다', () {
    final result = useCase.rank(
      category: CardCategory.convenience,
      userCards: cards,
      allBenefits: merchantBenefits,
      merchantKey: 'gs25',
    );
    expect(result.first.card.id, 'card-a');
    expect(result.first.hasBenefit, true);
    expect(result.first.benefit!.rate, 5.0);
    final cardB = result.firstWhere((r) => r.card.id == 'card-b');
    expect(cardB.hasBenefit, false);
  });

  test('merchantKey에 매칭되는 혜택이 없으면 전부 혜택 없음으로 정렬된다', () {
    final result = useCase.rank(
      category: CardCategory.convenience,
      userCards: cards,
      allBenefits: merchantBenefits,
      merchantKey: 'seveneleven',
    );
    expect(result.length, cards.length);
    expect(result.every((r) => !r.hasBenefit), isTrue);
  });
}
