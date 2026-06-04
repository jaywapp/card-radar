# 카드레이더 (CardRadar) — MVP A Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 카드 혜택 데이터를 앱에 하드코딩하고, 카테고리 선택으로 결제 시 최적 카드를 추천하는 Flutter MVP를 구현한다. GitHub 레포에 코드를 올리고 GitHub Actions로 Android APK를 Releases에 배포한다.

**Architecture:** 3레이어 Flutter 앱 (Presentation/Domain/Data). Supabase·지도 API 없이 Dart 상수로 카드 혜택 데이터 하드코딩. 사용자 카드 목록은 Hive 로컬 저장. 업체 대신 카테고리를 직접 선택.

**Tech Stack:** Flutter 3.x, flutter_riverpod 2.x, hive_flutter 1.x, go_router 14.x

**범위 외 (MVP A 제외):**
- Supabase / 원격 DB
- Naver Maps / 지도
- 데이터 파이프라인 (크롤링/AI)
- 업체명 텍스트 검색

---

## File Map

```
card-radar/                         # 이미 존재하는 폴더 (docs만 있음)
├── pubspec.yaml
├── lib/
│   ├── main.dart                   # Hive init, ProviderScope
│   ├── app.dart                    # MaterialApp.router
│   ├── core/
│   │   └── sample_data.dart        # 하드코딩된 카드·혜택 데이터
│   ├── data/
│   │   ├── models/
│   │   │   ├── card.dart
│   │   │   ├── card_benefit.dart
│   │   │   └── category.dart       # 카테고리 enum + 메타데이터
│   │   └── repositories/
│   │       └── user_card_repository.dart  # Hive 로컬
│   ├── domain/
│   │   ├── entities/
│   │   │   └── ranked_card.dart
│   │   └── usecases/
│   │       └── card_ranking_usecase.dart
│   └── presentation/
│       ├── router.dart
│       ├── providers/
│       │   └── user_cards_provider.dart
│       ├── screens/
│       │   ├── onboarding_screen.dart   # 첫 실행: 카드 선택
│       │   ├── home_screen.dart         # 카테고리 그리드
│       │   ├── ranking_screen.dart      # 카드 순위
│       │   └── my_cards_screen.dart     # 내 카드 관리
│       └── widgets/
│           └── card_rank_item.dart
├── test/
│   ├── domain/
│   │   └── card_ranking_usecase_test.dart
│   └── data/
│       └── user_card_repository_test.dart
└── .github/
    └── workflows/
        └── release.yml             # APK 빌드 + GitHub Releases 업로드
```

---

## Task 1: Flutter 프로젝트 생성 + 의존성 설정

**Files:**
- Create: Flutter project in `card-radar/` (기존 git repo 안에)
- Modify: `pubspec.yaml`

- [ ] **Step 1: 기존 card-radar 폴더 안에 Flutter 프로젝트 생성**

```powershell
cd D:\workspace\repositories\apps\card-radar
flutter create . --org com.jaywapp --project-name card_radar --platforms android,ios
```

> 기존 `docs/` 폴더는 유지됨. Flutter가 `.`에 생성할 때 기존 파일을 덮어쓰지 않음.

- [ ] **Step 2: pubspec.yaml dependencies 교체**

`pubspec.yaml`의 `dependencies` 섹션을 아래로 교체:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  hive_flutter: ^1.1.0
  hive: ^2.2.3
  go_router: ^14.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.9
  flutter_lints: ^4.0.0
```

- [ ] **Step 3: 의존성 설치**

```bash
flutter pub get
```

Expected: 오류 없이 완료.

- [ ] **Step 4: Android minSdkVersion 설정**

`android/app/build.gradle`에서 `minSdkVersion`을 21로 설정:

```gradle
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
    ...
}
```

- [ ] **Step 5: Commit**

```bash
git add .
git commit -m "chore: flutter project setup with minimal dependencies"
```

---

## Task 2: 카테고리 모델 + 샘플 카드 데이터

**Files:**
- Create: `lib/data/models/category.dart`
- Create: `lib/data/models/card.dart`
- Create: `lib/data/models/card_benefit.dart`
- Create: `lib/domain/entities/ranked_card.dart`
- Create: `lib/core/sample_data.dart`

- [ ] **Step 1: `lib/data/models/category.dart`**

```dart
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
```

- [ ] **Step 2: `lib/data/models/card.dart`**

```dart
class Card {
  final String id;
  final String name;
  final String issuer;

  const Card({required this.id, required this.name, required this.issuer});
}
```

- [ ] **Step 3: `lib/data/models/card_benefit.dart`**

```dart
import 'package:card_radar/data/models/category.dart';

class CardBenefit {
  final String cardId;
  final CardCategory category;
  final String benefitType; // 'cashback' | 'points'
  final double rate;
  final String? conditions;

  const CardBenefit({
    required this.cardId,
    required this.category,
    required this.benefitType,
    required this.rate,
    this.conditions,
  });
}
```

- [ ] **Step 4: `lib/domain/entities/ranked_card.dart`**

```dart
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';

class RankedCard {
  final Card card;
  final CardBenefit? benefit;
  final bool hasBenefit;

  const RankedCard({
    required this.card,
    this.benefit,
    required this.hasBenefit,
  });
}
```

- [ ] **Step 5: `lib/core/sample_data.dart`**

```dart
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
```

- [ ] **Step 6: Commit**

```bash
git add lib/data/models/ lib/domain/entities/ lib/core/
git commit -m "feat: add data models and hardcoded sample card data"
```

---

## Task 3: UserCardRepository (Hive 로컬, TDD)

**Files:**
- Create: `lib/data/repositories/user_card_repository.dart`
- Create: `test/data/user_card_repository_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/data/user_card_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:card_radar/data/repositories/user_card_repository.dart';

void main() {
  late UserCardRepository repo;

  setUp(() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>('test_user_cards');
    await box.clear();
    repo = UserCardRepository(box: box);
  });

  tearDown(() async {
    await Hive.close();
  });

  test('초기 상태는 빈 목록', () {
    expect(repo.cardIds, isEmpty);
  });

  test('카드 추가 후 목록에 포함됨', () async {
    await repo.addCard('shinhan-deep-dream');
    expect(repo.cardIds, contains('shinhan-deep-dream'));
  });

  test('카드 제거 후 목록에서 사라짐', () async {
    await repo.addCard('shinhan-deep-dream');
    await repo.removeCard('shinhan-deep-dream');
    expect(repo.cardIds, isNot(contains('shinhan-deep-dream')));
  });

  test('중복 추가 시 하나만 유지', () async {
    await repo.addCard('shinhan-deep-dream');
    await repo.addCard('shinhan-deep-dream');
    expect(repo.cardIds.where((id) => id == 'shinhan-deep-dream').length, 1);
  });
}
```

- [ ] **Step 2: 테스트 실행 — FAIL 확인**

```bash
flutter test test/data/user_card_repository_test.dart
```

Expected: `Error: Cannot find 'UserCardRepository'`

- [ ] **Step 3: `lib/data/repositories/user_card_repository.dart` 구현**

```dart
import 'package:hive/hive.dart';

class UserCardRepository {
  final Box<String> box;
  static const _key = 'card_ids';

  UserCardRepository({required this.box});

  List<String> get cardIds {
    final stored = box.get(_key);
    if (stored == null || stored.isEmpty) return [];
    return stored.split(',');
  }

  Future<void> addCard(String cardId) async {
    final ids = {...cardIds, cardId}.toList();
    await box.put(_key, ids.join(','));
  }

  Future<void> removeCard(String cardId) async {
    final ids = cardIds.where((id) => id != cardId).toList();
    await box.put(_key, ids.join(','));
  }

  bool contains(String cardId) => cardIds.contains(cardId);
}
```

- [ ] **Step 4: 테스트 실행 — PASS 확인**

```bash
flutter test test/data/user_card_repository_test.dart
```

Expected: 4개 테스트 모두 PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/repositories/user_card_repository.dart test/data/user_card_repository_test.dart
git commit -m "feat: add UserCardRepository with Hive (TDD)"
```

---

## Task 4: CardRankingUseCase (TDD 핵심 로직)

**Files:**
- Create: `lib/domain/usecases/card_ranking_usecase.dart`
- Create: `test/domain/card_ranking_usecase_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/card_ranking_usecase_test.dart`:

```dart
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
}
```

- [ ] **Step 2: 테스트 실행 — FAIL 확인**

```bash
flutter test test/domain/card_ranking_usecase_test.dart
```

Expected: `Error: Cannot find 'CardRankingUseCase'`

- [ ] **Step 3: `lib/domain/usecases/card_ranking_usecase.dart` 구현**

```dart
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';

class CardRankingUseCase {
  List<RankedCard> rank({
    required CardCategory category,
    required List<Card> userCards,
    required List<CardBenefit> allBenefits,
  }) {
    if (userCards.isEmpty) return [];

    final withBenefit = <RankedCard>[];
    final withoutBenefit = <RankedCard>[];

    for (final card in userCards) {
      final benefit = allBenefits
          .where((b) => b.cardId == card.id && b.category == category)
          .fold<CardBenefit?>(
              null, (best, b) => best == null || b.rate > best.rate ? b : best);

      if (benefit != null) {
        withBenefit.add(RankedCard(card: card, benefit: benefit, hasBenefit: true));
      } else {
        withoutBenefit.add(RankedCard(card: card, hasBenefit: false));
      }
    }

    withBenefit.sort((a, b) => b.benefit!.rate.compareTo(a.benefit!.rate));
    return [...withBenefit, ...withoutBenefit];
  }
}
```

- [ ] **Step 4: 테스트 실행 — PASS 확인**

```bash
flutter test test/domain/card_ranking_usecase_test.dart
```

Expected: 4개 테스트 모두 PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/usecases/card_ranking_usecase.dart test/domain/card_ranking_usecase_test.dart
git commit -m "feat: add CardRankingUseCase (TDD)"
```

---

## Task 5: main.dart + Providers + Router

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `lib/presentation/router.dart`
- Create: `lib/presentation/providers/user_cards_provider.dart`

- [ ] **Step 1: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:card_radar/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('user_cards');
  runApp(const ProviderScope(child: CardRadarApp()));
}
```

- [ ] **Step 2: `lib/app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/presentation/router.dart';

class CardRadarApp extends ConsumerWidget {
  const CardRadarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '카드레이더',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 3: `lib/presentation/router.dart`**

```dart
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/presentation/screens/onboarding_screen.dart';
import 'package:card_radar/presentation/screens/home_screen.dart';
import 'package:card_radar/presentation/screens/ranking_screen.dart';
import 'package:card_radar/presentation/screens/my_cards_screen.dart';

final appRouter = GoRouter(
  redirect: (context, state) {
    final box = Hive.box<String>('user_cards');
    final stored = box.get('card_ids');
    final hasCards = stored != null && stored.isNotEmpty;
    if (!hasCards && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/ranking',
      builder: (_, state) {
        final category = state.extra as CardCategory;
        return RankingScreen(category: category);
      },
    ),
    GoRoute(path: '/my-cards', builder: (_, __) => const MyCardsScreen()),
  ],
);
```

- [ ] **Step 4: `lib/presentation/providers/user_cards_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/repositories/user_card_repository.dart';

final userCardRepoProvider = Provider<UserCardRepository>((ref) {
  return UserCardRepository(box: Hive.box<String>('user_cards'));
});

class UserCardsNotifier extends StateNotifier<List<Card>> {
  final UserCardRepository _repo;

  UserCardsNotifier(this._repo)
      : super(sampleCards.where((c) => _repo.cardIds.contains(c.id)).toList());

  Future<void> addCard(String cardId) async {
    await _repo.addCard(cardId);
    state = sampleCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  Future<void> removeCard(String cardId) async {
    await _repo.removeCard(cardId);
    state = sampleCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  bool contains(String cardId) => _repo.contains(cardId);
}

final userCardsProvider =
    StateNotifierProvider<UserCardsNotifier, List<Card>>((ref) {
  return UserCardsNotifier(ref.read(userCardRepoProvider));
});
```

- [ ] **Step 5: 빌드 확인**

```bash
flutter analyze lib/
```

Expected: 오류 없음

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart lib/app.dart lib/presentation/router.dart lib/presentation/providers/
git commit -m "feat: add main entry, router, and Riverpod providers"
```

---

## Task 6: 온보딩 + 내 카드 관리 화면

**Files:**
- Create: `lib/presentation/screens/onboarding_screen.dart`
- Create: `lib/presentation/screens/my_cards_screen.dart`

- [ ] **Step 1: `lib/presentation/screens/onboarding_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userCardsProvider.notifier);
    final userCards = ref.watch(userCardsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('👋 보유 카드를 선택해 주세요',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('결제 시 가장 유리한 카드를 추천해 드려요',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: sampleCards.length,
                  itemBuilder: (context, index) {
                    final card = sampleCards[index];
                    return CheckboxListTile(
                      title: Text(card.name),
                      subtitle: Text(card.issuer),
                      value: notifier.contains(card.id),
                      onChanged: (checked) async {
                        if (checked == true) {
                          await notifier.addCard(card.id);
                        } else {
                          await notifier.removeCard(card.id);
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: userCards.isEmpty
                      ? null
                      : () => context.go('/home'),
                  child: const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `lib/presentation/screens/my_cards_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userCardsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('내 카드 관리')),
      body: ListView.builder(
        itemCount: sampleCards.length,
        itemBuilder: (context, index) {
          final card = sampleCards[index];
          return CheckboxListTile(
            title: Text(card.name),
            subtitle: Text(card.issuer),
            value: notifier.contains(card.id),
            onChanged: (checked) async {
              if (checked == true) {
                await notifier.addCard(card.id);
              } else {
                await notifier.removeCard(card.id);
              }
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/onboarding_screen.dart lib/presentation/screens/my_cards_screen.dart
git commit -m "feat: add OnboardingScreen and MyCardsScreen"
```

---

## Task 7: 홈 화면 (카테고리 그리드)

**Files:**
- Create: `lib/presentation/screens/home_screen.dart`

- [ ] **Step 1: `lib/presentation/screens/home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '어디서 결제하나요?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (userCards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('카드를 먼저 등록해 주세요',
                  style: TextStyle(color: Colors.grey)),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: CardCategory.values.length,
              itemBuilder: (context, index) {
                final category = CardCategory.values[index];
                return _CategoryCard(category: category);
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
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/ranking', extra: category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              category.label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/home_screen.dart
git commit -m "feat: add HomeScreen with category grid"
```

---

## Task 8: 카드 순위 화면

**Files:**
- Create: `lib/presentation/screens/ranking_screen.dart`
- Create: `lib/presentation/widgets/card_rank_item.dart`

- [ ] **Step 1: `lib/presentation/widgets/card_rank_item.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:card_radar/domain/entities/ranked_card.dart';

class CardRankItem extends StatelessWidget {
  final RankedCard rankedCard;
  final int rank;

  const CardRankItem({super.key, required this.rankedCard, required this.rank});

  @override
  Widget build(BuildContext context) {
    final card = rankedCard.card;
    final benefit = rankedCard.benefit;
    final hasBenefit = rankedCard.hasBenefit;

    return ListTile(
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
      title: Text(card.name),
      subtitle: Text(card.issuer),
      trailing: hasBenefit
          ? Column(
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (benefit.conditions != null)
                  Text(
                    benefit.conditions!,
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
              ],
            )
          : const Text('혜택 없음',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }
}
```

- [ ] **Step 2: `lib/presentation/screens/ranking_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';
import 'package:card_radar/presentation/widgets/card_rank_item.dart';

class RankingScreen extends ConsumerWidget {
  final CardCategory category;
  const RankingScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCards = ref.watch(userCardsProvider);

    if (userCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${category.emoji} ${category.label}')),
        body: const Center(child: Text('내 카드를 먼저 등록해 주세요')),
      );
    }

    final useCase = CardRankingUseCase();
    final ranked = useCase.rank(
      category: category,
      userCards: userCards,
      allBenefits: sampleBenefits,
    );

    int rank = 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.emoji} ${category.label}'),
        subtitle: Text('${userCards.length}개 카드 기준'),
      ),
      body: ListView.separated(
        itemCount: ranked.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = ranked[index];
          final displayRank = item.hasBenefit ? rank++ : 0;
          return CardRankItem(rankedCard: item, rank: displayRank);
        },
      ),
    );
  }
}
```

- [ ] **Step 3: 전체 테스트 실행**

```bash
flutter test
```

Expected: 모든 테스트 PASS

- [ ] **Step 4: 빌드 확인**

```bash
flutter build apk --debug
```

Expected: `build/app/outputs/flutter-apk/app-debug.apk` 생성

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/ranking_screen.dart lib/presentation/widgets/card_rank_item.dart
git commit -m "feat: add RankingScreen and CardRankItem — MVP A complete"
```

---

## Task 9: GitHub 레포 생성 + Push

**Files:**
- None (GitHub CLI 사용)

- [ ] **Step 1: GitHub 레포 생성**

```bash
cd D:\workspace\repositories\apps\card-radar
gh repo create card-radar --public --description "카드레이더 — 결제 시 최적 카드 추천 앱" --source . --remote origin
```

- [ ] **Step 2: 전체 Push**

```bash
git push -u origin master
```

Expected: GitHub에 코드 업로드 확인.

- [ ] **Step 3: GitHub Actions 폴더 생성**

```bash
mkdir -p .github/workflows
```

- [ ] **Step 4: Commit (빈 workflows 폴더 대비 .gitkeep)**

```bash
git add .github/
git commit -m "chore: add .github/workflows directory"
git push
```

---

## Task 10: GitHub Actions — Android APK 빌드 + Releases 업로드

**Files:**
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: `.github/workflows/release.yml` 작성**

```yaml
name: Release Android APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build-and-release:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build APK (release)
        run: flutter build apk --release

      - name: Upload APK to GitHub Releases
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
          name: "카드레이더 ${{ github.ref_name }}"
          body: |
            ## 카드레이더 ${{ github.ref_name }}

            ### 변경 사항
            - MVP A 배포: 카드 등록 + 카테고리별 혜택 카드 추천

            ### 설치 방법
            1. `app-release.apk` 다운로드
            2. Android 기기에서 알 수 없는 출처 허용
            3. APK 설치
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 2: Commit + Push**

```bash
git add .github/workflows/release.yml
git commit -m "ci: add GitHub Actions workflow for Android APK release"
git push
```

- [ ] **Step 3: v1.0.0 태그 생성 + Push — Action 트리거**

```bash
git tag v1.0.0
git push origin v1.0.0
```

Expected: GitHub Actions가 트리거되어 APK를 빌드하고 Releases에 업로드함.

- [ ] **Step 4: Actions 결과 확인**

```bash
gh run list --limit 3
```

Expected: `Release Android APK` 워크플로우가 성공(✓) 상태.

```bash
gh release list
```

Expected: `v1.0.0` 릴리스에 `app-release.apk` 첨부 확인.

---

## 완료 기준 체크리스트

- [ ] `flutter test` 전체 PASS
- [ ] 앱 실행 시 온보딩 → 카드 선택 → 홈(카테고리 그리드) → 카드 순위 흐름 동작
- [ ] 앱 재실행 시 카드 목록 유지 (Hive 영속성)
- [ ] GitHub 레포에 코드 푸시 완료
- [ ] `v1.0.0` 태그 기반 Actions 성공
- [ ] GitHub Releases에 `app-release.apk` 업로드 완료
