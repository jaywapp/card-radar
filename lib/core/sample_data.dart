import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';

const List<Card> sampleCards = [
  Card(id: 'shinhan-deep-dream', name: '신한 Deep Dream', issuer: '신한카드'),
  Card(id: 'hyundai-zero', name: '현대카드 ZERO', issuer: '현대카드'),
  Card(id: 'kb-flex', name: 'KB 플렉스카드', issuer: 'KB국민카드'),
  Card(id: 'samsung-taptap', name: '삼성 taptap', issuer: '삼성카드'),
  Card(id: 'lotte-dc-plus', name: '롯데 DC PLUS', issuer: '롯데카드'),
  Card(id: 'woori-da', name: '우리 다통장카드', issuer: '우리카드'),
];

const List<CardBenefit> sampleBenefits = [
  // 신한 Deep Dream
  CardBenefit(cardId: 'shinhan-deep-dream', category: CardCategory.convenience, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'shinhan-deep-dream', category: CardCategory.cafe, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'shinhan-deep-dream', category: CardCategory.online, benefitType: 'cashback', rate: 2.0, conditions: '월 3만원 한도'),

  // 현대카드 ZERO
  CardBenefit(cardId: 'hyundai-zero', category: CardCategory.gasStation, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'hyundai-zero', category: CardCategory.transit, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'hyundai-zero', category: CardCategory.mart, benefitType: 'cashback', rate: 2.0),

  // KB 플렉스
  CardBenefit(cardId: 'kb-flex', category: CardCategory.restaurant, benefitType: 'points', rate: 5.0),
  CardBenefit(cardId: 'kb-flex', category: CardCategory.online, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'kb-flex', category: CardCategory.cafe, benefitType: 'points', rate: 2.0),

  // 삼성 taptap
  CardBenefit(cardId: 'samsung-taptap', category: CardCategory.online, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'samsung-taptap', category: CardCategory.mart, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'samsung-taptap', category: CardCategory.convenience, benefitType: 'cashback', rate: 2.0),

  // 롯데 DC PLUS
  CardBenefit(cardId: 'lotte-dc-plus', category: CardCategory.restaurant, benefitType: 'cashback', rate: 4.0),
  CardBenefit(cardId: 'lotte-dc-plus', category: CardCategory.mart, benefitType: 'cashback', rate: 4.0),
  CardBenefit(cardId: 'lotte-dc-plus', category: CardCategory.cafe, benefitType: 'cashback', rate: 2.0),

  // 우리 다통장
  CardBenefit(cardId: 'woori-da', category: CardCategory.transit, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'woori-da', category: CardCategory.gasStation, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'woori-da', category: CardCategory.pharmacy, benefitType: 'cashback', rate: 2.0),
];
