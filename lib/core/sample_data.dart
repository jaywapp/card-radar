import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';

const List<Card> sampleCards = [
  // 신한카드
  Card(id: 'shinhan-deep-dream', name: '신한 Deep Dream', issuer: '신한카드', applyUrl: 'https://www.shinhancard.com/pconts/html/card/apply/credit/1196838_2203.html'),
  Card(id: 'shinhan-sline', name: '신한 S-Line', issuer: '신한카드', applyUrl: 'https://www.shinhancard.com'),
  Card(id: 'shinhan-mrlife', name: '신한 Mr.Life', issuer: '신한카드', applyUrl: 'https://www.shinhancard.com'),

  // 현대카드
  Card(id: 'hyundai-zero', name: '현대카드 ZERO', issuer: '현대카드', applyUrl: 'https://www.hyundaicard.com/cpc/si/CPCSIE0010_01.hc'),
  Card(id: 'hyundai-m', name: '현대카드 M', issuer: '현대카드', applyUrl: 'https://www.hyundaicard.com'),
  Card(id: 'hyundai-shopping', name: '현대카드 SHOPPING', issuer: '현대카드', applyUrl: 'https://www.hyundaicard.com'),

  // KB국민카드
  Card(id: 'kb-flex', name: 'KB 플렉스카드', issuer: 'KB국민카드', applyUrl: 'https://card.kbcard.com/CRD/DISI/LPCDISIHMPG0076.cms'),
  Card(id: 'kb-tantan', name: 'KB 탄탄대로카드', issuer: 'KB국민카드', applyUrl: 'https://card.kbcard.com'),
  Card(id: 'kb-nori', name: 'KB 노리 1.5', issuer: 'KB국민카드', applyUrl: 'https://card.kbcard.com'),

  // 삼성카드
  Card(id: 'samsung-taptap', name: '삼성 taptap', issuer: '삼성카드', applyUrl: 'https://www.samsungcard.com/home/card/cardinfo/PGBPCARDCardInfo0201V.do?CSTSQNO=1002020'),
  Card(id: 'samsung-id-simple', name: '삼성 iD SIMPLE', issuer: '삼성카드', applyUrl: 'https://www.samsungcard.com'),
  Card(id: 'samsung-7', name: '삼성카드 7', issuer: '삼성카드', applyUrl: 'https://www.samsungcard.com'),

  // 롯데카드
  Card(id: 'lotte-dc-plus', name: '롯데 DC PLUS', issuer: '롯데카드', applyUrl: 'https://www.lottecard.co.kr/app/LPCDCBCA_V100.lc'),
  Card(id: 'lotte-likit', name: '롯데 LIKIT', issuer: '롯데카드', applyUrl: 'https://www.lottecard.co.kr'),

  // 우리카드
  Card(id: 'woori-da', name: '우리 다통장카드', issuer: '우리카드', applyUrl: 'https://pc.wooricard.com/dcpc/yh1/crd/crdIssueMgmt/H1CRD101M1/selectCrdIssuDtl.do'),
  Card(id: 'woori-da-big', name: '우리 Da Big카드', issuer: '우리카드', applyUrl: 'https://pc.wooricard.com'),

  // 하나카드
  Card(id: 'hana-1q', name: '하나 1Q카드', issuer: '하나카드', applyUrl: 'https://www.hanacard.co.kr/OPI30000000N.web'),
  Card(id: 'hana-moa', name: '하나 모아', issuer: '하나카드', applyUrl: 'https://www.hanacard.co.kr'),

  // NH농협카드
  Card(id: 'nh-all', name: 'NH올원카드 올바른FLEX', issuer: 'NH농협카드', applyUrl: 'https://card.nonghyup.com'),
];

const List<CardBenefit> sampleBenefits = [
  // 신한 Deep Dream
  CardBenefit(cardId: 'shinhan-deep-dream', category: CardCategory.convenience, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'shinhan-deep-dream', category: CardCategory.cafe, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'shinhan-deep-dream', category: CardCategory.online, benefitType: 'cashback', rate: 2.0, conditions: '월 3만원 한도'),

  // 신한 S-Line
  CardBenefit(cardId: 'shinhan-sline', category: CardCategory.transit, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'shinhan-sline', category: CardCategory.gasStation, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'shinhan-sline', category: CardCategory.pharmacy, benefitType: 'cashback', rate: 2.0),

  // 신한 Mr.Life
  CardBenefit(cardId: 'shinhan-mrlife', category: CardCategory.mart, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'shinhan-mrlife', category: CardCategory.pharmacy, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'shinhan-mrlife', category: CardCategory.cafe, benefitType: 'cashback', rate: 2.0),

  // 현대카드 ZERO
  CardBenefit(cardId: 'hyundai-zero', category: CardCategory.gasStation, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'hyundai-zero', category: CardCategory.transit, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'hyundai-zero', category: CardCategory.mart, benefitType: 'cashback', rate: 2.0),

  // 현대카드 M
  CardBenefit(cardId: 'hyundai-m', category: CardCategory.restaurant, benefitType: 'points', rate: 5.0),
  CardBenefit(cardId: 'hyundai-m', category: CardCategory.cafe, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'hyundai-m', category: CardCategory.mart, benefitType: 'points', rate: 2.0),

  // 현대카드 SHOPPING
  CardBenefit(cardId: 'hyundai-shopping', category: CardCategory.online, benefitType: 'cashback', rate: 7.0, conditions: '월 30만원 이상'),
  CardBenefit(cardId: 'hyundai-shopping', category: CardCategory.mart, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'hyundai-shopping', category: CardCategory.convenience, benefitType: 'cashback', rate: 2.0),

  // KB 플렉스
  CardBenefit(cardId: 'kb-flex', category: CardCategory.restaurant, benefitType: 'points', rate: 5.0),
  CardBenefit(cardId: 'kb-flex', category: CardCategory.online, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'kb-flex', category: CardCategory.cafe, benefitType: 'points', rate: 2.0),

  // KB 탄탄대로
  CardBenefit(cardId: 'kb-tantan', category: CardCategory.gasStation, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'kb-tantan', category: CardCategory.convenience, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'kb-tantan', category: CardCategory.transit, benefitType: 'cashback', rate: 2.0),

  // KB 노리
  CardBenefit(cardId: 'kb-nori', category: CardCategory.restaurant, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'kb-nori', category: CardCategory.cafe, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'kb-nori', category: CardCategory.convenience, benefitType: 'cashback', rate: 3.0),

  // 삼성 taptap
  CardBenefit(cardId: 'samsung-taptap', category: CardCategory.online, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'samsung-taptap', category: CardCategory.mart, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'samsung-taptap', category: CardCategory.convenience, benefitType: 'cashback', rate: 2.0),

  // 삼성 iD SIMPLE
  CardBenefit(cardId: 'samsung-id-simple', category: CardCategory.convenience, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'samsung-id-simple', category: CardCategory.transit, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'samsung-id-simple', category: CardCategory.gasStation, benefitType: 'cashback', rate: 3.0),

  // 삼성카드 7
  CardBenefit(cardId: 'samsung-7', category: CardCategory.mart, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'samsung-7', category: CardCategory.restaurant, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'samsung-7', category: CardCategory.pharmacy, benefitType: 'cashback', rate: 2.0),

  // 롯데 DC PLUS
  CardBenefit(cardId: 'lotte-dc-plus', category: CardCategory.restaurant, benefitType: 'cashback', rate: 4.0),
  CardBenefit(cardId: 'lotte-dc-plus', category: CardCategory.mart, benefitType: 'cashback', rate: 4.0),
  CardBenefit(cardId: 'lotte-dc-plus', category: CardCategory.cafe, benefitType: 'cashback', rate: 2.0),

  // 롯데 LIKIT
  CardBenefit(cardId: 'lotte-likit', category: CardCategory.online, benefitType: 'points', rate: 4.0),
  CardBenefit(cardId: 'lotte-likit', category: CardCategory.convenience, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'lotte-likit', category: CardCategory.restaurant, benefitType: 'points', rate: 2.0),

  // 우리 다통장
  CardBenefit(cardId: 'woori-da', category: CardCategory.transit, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'woori-da', category: CardCategory.gasStation, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'woori-da', category: CardCategory.pharmacy, benefitType: 'cashback', rate: 2.0),

  // 우리 Da Big
  CardBenefit(cardId: 'woori-da-big', category: CardCategory.mart, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'woori-da-big', category: CardCategory.restaurant, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'woori-da-big', category: CardCategory.online, benefitType: 'cashback', rate: 2.0),

  // 하나 1Q
  CardBenefit(cardId: 'hana-1q', category: CardCategory.online, benefitType: 'points', rate: 5.0),
  CardBenefit(cardId: 'hana-1q', category: CardCategory.mart, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'hana-1q', category: CardCategory.convenience, benefitType: 'points', rate: 2.0),

  // 하나 모아
  CardBenefit(cardId: 'hana-moa', category: CardCategory.restaurant, benefitType: 'cashback', rate: 4.0),
  CardBenefit(cardId: 'hana-moa', category: CardCategory.cafe, benefitType: 'cashback', rate: 4.0),
  CardBenefit(cardId: 'hana-moa', category: CardCategory.transit, benefitType: 'cashback', rate: 2.0),

  // NH 올원 FLEX
  CardBenefit(cardId: 'nh-all', category: CardCategory.convenience, benefitType: 'cashback', rate: 5.0),
  CardBenefit(cardId: 'nh-all', category: CardCategory.cafe, benefitType: 'cashback', rate: 3.0),
  CardBenefit(cardId: 'nh-all', category: CardCategory.transit, benefitType: 'cashback', rate: 2.0),
];
