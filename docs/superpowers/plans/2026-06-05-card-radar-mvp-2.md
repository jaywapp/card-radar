# 카드레이더 MVP 2 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** PC 없이 코드만으로 완결 가능한 앱 완성도 향상 — 카드 데이터 확대, 카드사 신청 딥링크, UI polish, README, v1.1.0 릴리스

**Architecture:** MVP A 구조 유지. Card 모델에 applyUrl 추가. sample_data를 20개 카드로 확대. url_launcher로 외부 링크 오픈.

**Tech Stack:** 기존 스택 + url_launcher ^6.3.0

---

## File Map (변경/추가)

```
lib/
├── core/
│   └── sample_data.dart          # 6개 → 20개 카드 + 실제 혜택 기반 데이터
├── data/
│   └── models/
│       └── card.dart             # applyUrl 필드 추가
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart      # 카테고리별 혜택카드 수 배지 추가
│   │   └── ranking_screen.dart   # "신청하기" 버튼 추가
│   └── widgets/
│       └── card_rank_item.dart   # "신청하기" 버튼 UI
pubspec.yaml                      # url_launcher 추가
README.md                         # 신규 작성
```

---

## Task 1: url_launcher 의존성 추가

**Files:** `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: pubspec.yaml에 url_launcher 추가**

`dependencies` 섹션에 추가:
```yaml
url_launcher: ^6.3.0
```

- [ ] **Step 2: flutter pub get**

```bash
flutter pub get
```

- [ ] **Step 3: AndroidManifest.xml에 queries 추가**

`android/app/src/main/AndroidManifest.xml`의 `<manifest>` 태그 바로 안에 추가:
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

- [ ] **Step 4: Commit**
```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml
git commit -m "chore: add url_launcher dependency"
```

---

## Task 2: Card 모델에 applyUrl 추가 + 카드 데이터 20개로 확대

**Files:** `lib/data/models/card.dart`, `lib/core/sample_data.dart`

- [ ] **Step 1: card.dart에 applyUrl 추가**

```dart
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
```

- [ ] **Step 2: sample_data.dart — 20개 카드 + 60개 혜택으로 확대**

```dart
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
  Card(id: 'nh-payco', name: 'NH페이코 포인트카드', issuer: 'NH농협카드', applyUrl: 'https://card.nonghyup.com'),
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

  // NH페이코
  CardBenefit(cardId: 'nh-payco', category: CardCategory.online, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'nh-payco', category: CardCategory.restaurant, benefitType: 'points', rate: 3.0),
  CardBenefit(cardId: 'nh-payco', category: CardCategory.mart, benefitType: 'points', rate: 2.0),
];
```

- [ ] **Step 3: flutter analyze**
```bash
flutter analyze lib/core/sample_data.dart lib/data/models/card.dart
```

- [ ] **Step 4: Commit**
```bash
git add lib/data/models/card.dart lib/core/sample_data.dart
git commit -m "feat: expand card data to 20 cards with apply URLs"
```

---

## Task 3: 순위 화면 "신청하기" 버튼 + CardRankItem UI 개선

**Files:** `lib/presentation/widgets/card_rank_item.dart`, `lib/presentation/screens/ranking_screen.dart`

- [ ] **Step 1: card_rank_item.dart 개선**

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';

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
```

- [ ] **Step 2: flutter analyze**
```bash
flutter analyze lib/presentation/widgets/card_rank_item.dart
```

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/widgets/card_rank_item.dart
git commit -m "feat: add apply URL button to CardRankItem"
```

---

## Task 4: 홈 화면 카테고리 배지 + UI polish

**Files:** `lib/presentation/screens/home_screen.dart`

- [ ] **Step 1: home_screen.dart 개선**

카테고리 카드에 "혜택 있는 내 카드 수" 배지 표시:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCards = ref.watch(userCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드레이더'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            tooltip: '내 카드 관리',
            onPressed: () => context.push('/my-cards'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              '어디서 결제하나요?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (userCards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('카드를 먼저 등록해 주세요'),
                  subtitle: const Text('우측 상단에서 카드를 추가할 수 있어요'),
                  onTap: () => context.push('/my-cards'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${userCards.length}개 카드 등록됨',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: CardCategory.values.length,
              itemBuilder: (context, index) {
                final category = CardCategory.values[index];
                final benefitCount = userCards.isEmpty
                    ? 0
                    : userCards.where((card) => sampleBenefits.any(
                        (b) => b.cardId == card.id && b.category == category,
                      )).length;
                return _CategoryCard(
                  category: category,
                  benefitCount: benefitCount,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CardCategory category;
  final int benefitCount;

  const _CategoryCard({
    required this.category,
    required this.benefitCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/ranking', extra: category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: benefitCount > 0
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.emoji,
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 6),
                  Text(
                    category.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (benefitCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$benefitCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: flutter analyze**
```bash
flutter analyze lib/presentation/screens/home_screen.dart
```

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/screens/home_screen.dart
git commit -m "feat: add benefit count badge to category cards"
```

---

## Task 5: README 작성 + 전체 테스트 + v1.1.0 릴리스

**Files:** `README.md`

- [ ] **Step 1: README.md 작성**

```markdown
# 카드레이더 (CardRadar)

> 결제할 때 가장 유리한 카드를 바로 찾아주는 앱

[![Release](https://img.shields.io/github/v/release/jaywapp/card-radar)](https://github.com/jaywapp/card-radar/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)

## 주요 기능

- 🏪 **카테고리별 추천** — 편의점, 카페, 식당, 주유소 등 8개 카테고리
- 💳 **내 카드 등록** — 보유 카드를 등록하면 맞춤 혜택 순위 제공
- 💰 **혜택 비교** — 캐시백/포인트 비율 기준 카드 내림차순 정렬
- 🔗 **바로 신청** — 혜택 좋은 카드 바로 신청 링크 연결

## 지원 카드 (20개)

| 카드사 | 카드명 |
|--------|--------|
| 신한카드 | Deep Dream, S-Line, Mr.Life |
| 현대카드 | ZERO, M, SHOPPING |
| KB국민카드 | 플렉스카드, 탄탄대로, 노리 1.5 |
| 삼성카드 | taptap, iD SIMPLE, 삼성카드 7 |
| 롯데카드 | DC PLUS, LIKIT |
| 우리카드 | 다통장카드, Da Big카드 |
| 하나카드 | 1Q카드, 모아 |
| NH농협카드 | 올원카드 올바른FLEX, 페이코 포인트카드 |

## 설치 방법

[Releases](https://github.com/jaywapp/card-radar/releases)에서 최신 `app-release.apk` 다운로드 후 설치

## 기술 스택

- **Flutter** 3.x
- **Riverpod** 2.x (상태 관리)
- **Hive CE** (로컬 저장소)
- **Go Router** (화면 전환)
- **GitHub Actions** (CI/CD — APK 자동 빌드)

## 실행 방법

```bash
flutter pub get
flutter run
```

## 빌드

```bash
flutter build apk --release
```

## 로드맵

- [ ] Supabase 연동 (실시간 혜택 DB)
- [ ] 네이버 지도 연동 (주변 업체 탐색)
- [ ] Play Store 배포
```

- [ ] **Step 2: 전체 테스트**
```bash
flutter test
```
Expected: 모든 테스트 PASS

- [ ] **Step 3: Commit**
```bash
git add README.md
git commit -m "docs: add README"
git push
```

- [ ] **Step 4: v1.1.0 태그 + 릴리스 트리거**
```bash
git tag v1.1.0
git push origin v1.1.0
```

- [ ] **Step 5: Actions 완료 확인**
```bash
gh run watch $(gh run list --limit 1 --json databaseId -q '.[0].databaseId')
gh release list
```
Expected: v1.1.0 릴리스에 `app-release.apk` 첨부
