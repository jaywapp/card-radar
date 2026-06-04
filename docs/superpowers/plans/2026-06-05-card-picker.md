# 카드레이더 (CardRadar) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 보유 카드 목록을 기반으로 결제 업체 선택 시 캐시백/포인트율 기준 카드 추천 Flutter 앱을 구현한다.

**Architecture:** Presentation / Domain / Data 3레이어 Flutter 앱. Riverpod으로 상태 관리. 카드 혜택 DB는 Supabase에서 가져와 Hive에 캐싱. 사용자 카드 목록은 Hive 로컬 저장. 업체 검색은 Naver Local Search API + flutter_naver_map 지도 표시.

**Tech Stack:** Flutter 3.x, flutter_riverpod 2.x, supabase_flutter 2.x, hive_flutter 1.x, flutter_naver_map 1.x, geolocator 12.x, go_router 14.x, http 1.x

---

## File Map

```
card-picker/
├── pubspec.yaml
├── .env                          # Supabase URL/key, Naver API keys (gitignored)
├── android/app/src/main/AndroidManifest.xml
├── ios/Runner/Info.plist
├── lib/
│   ├── main.dart                 # Hive init, Supabase init, ProviderScope
│   ├── app.dart                  # MaterialApp + GoRouter
│   ├── core/
│   │   ├── env.dart              # .env 값 접근 (flutter_dotenv)
│   │   └── categories.dart       # 카테고리 상수 + Naver 카테고리 → 내부 카테고리 매핑
│   ├── data/
│   │   ├── models/
│   │   │   ├── card.dart         # Card(id, name, issuer, imageUrl)
│   │   │   ├── card_benefit.dart # CardBenefit(cardId, category, benefitType, rate, conditions)
│   │   │   └── merchant.dart     # Merchant(title, category, lat, lng, distance)
│   │   └── repositories/
│   │       ├── user_card_repository.dart      # Hive: 보유 카드 ID 목록
│   │       ├── card_benefit_repository.dart   # Supabase + Hive 캐시
│   │       └── map_repository.dart            # Naver Local Search API
│   ├── domain/
│   │   ├── entities/
│   │   │   └── ranked_card.dart  # RankedCard(card, benefit, hasBenel)
│   │   └── usecases/
│   │       └── card_ranking_usecase.dart
│   └── presentation/
│       ├── router.dart
│       ├── providers/
│       │   ├── user_cards_provider.dart       # StateNotifierProvider<UserCardNotifier, List<Card>>
│       │   ├── card_benefits_provider.dart    # FutureProvider<List<CardBenefit>>
│       │   └── map_search_provider.dart       # StateNotifierProvider<MapSearchNotifier, ...>
│       ├── screens/
│       │   ├── onboarding_screen.dart         # 첫 실행: 카드 선택
│       │   ├── home_screen.dart               # 네이버 지도 + 검색창
│       │   ├── search_screen.dart             # 업체 검색 결과 (거리순)
│       │   ├── ranking_screen.dart            # 카드 순위
│       │   └── my_cards_screen.dart           # 내 카드 관리
│       └── widgets/
│           ├── card_rank_item.dart
│           └── merchant_list_item.dart
├── test/
│   ├── domain/
│   │   └── card_ranking_usecase_test.dart
│   └── data/
│       └── user_card_repository_test.dart
└── scripts/
    ├── crawler.py
    ├── parser.py
    └── uploader.py
```

---

## Task 1: 프로젝트 생성 + 의존성 설정

**Files:**
- Create: `card-picker/` (Flutter project)
- Modify: `pubspec.yaml`
- Create: `.env`
- Create: `android/app/src/main/AndroidManifest.xml` (권한 + Naver 키 추가)

- [ ] **Step 1: Flutter 프로젝트 생성**

```bash
cd D:\workspace\repositories\apps
flutter create card_radar --org com.jaywapp --platforms android,ios
cd card-radar
```

- [ ] **Step 2: pubspec.yaml 의존성 추가**

`pubspec.yaml`의 `dependencies` 섹션을 아래로 교체:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  supabase_flutter: ^2.5.0
  hive_flutter: ^1.1.0
  hive: ^2.2.3
  flutter_naver_map: ^1.2.3
  go_router: ^14.2.0
  http: ^1.2.1
  geolocator: ^12.0.0
  permission_handler: ^11.3.1
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.9
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - .env
```

- [ ] **Step 3: `.env` 파일 생성 (루트)**

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
NAVER_CLIENT_ID=your-naver-client-id
NAVER_CLIENT_SECRET=your-naver-client-secret
NAVER_MAP_CLIENT_ID=your-naver-map-client-id
```

`.gitignore`에 추가:
```
.env
```

- [ ] **Step 4: Naver Maps 네이티브 키 설정**

`android/app/src/main/AndroidManifest.xml`의 `<application>` 태그 안에 추가:

```xml
<meta-data
    android:name="com.naver.maps.map.CLIENT_ID"
    android:value="your-naver-map-client-id" />
```

`android/app/src/main/AndroidManifest.xml`의 `<manifest>` 태그 안에 권한 추가:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

`ios/Runner/Info.plist`에 추가:

```xml
<key>NMFClientId</key>
<string>your-naver-map-client-id</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 업체를 찾기 위해 위치 권한이 필요합니다.</string>
```

- [ ] **Step 5: 의존성 설치 확인**

```bash
flutter pub get
```

Expected: 오류 없이 완료.

- [ ] **Step 6: Supabase 테이블 생성**

Supabase 대시보드 → SQL Editor에서 실행:

```sql
create table cards (
  id        text primary key,
  name      text not null,
  issuer    text not null,
  image_url text
);

create table card_benefits (
  id           uuid primary key default gen_random_uuid(),
  card_id      text references cards(id) on delete cascade,
  category     text not null,
  benefit_type text not null check (benefit_type in ('cashback', 'points')),
  rate         numeric(5,2) not null,
  conditions   text
);

create table merchant_categories (
  id       uuid primary key default gen_random_uuid(),
  keyword  text unique not null,
  category text not null
);

-- 샘플 데이터
insert into cards values
  ('shinhan-deep-dream', '신한 Deep Dream', '신한카드', null),
  ('hyundai-zero', '현대카드 ZERO', '현대카드', null),
  ('kb-flex', 'KB 플렉스', 'KB국민카드', null);

insert into card_benefits (card_id, category, benefit_type, rate) values
  ('shinhan-deep-dream', '편의점', 'cashback', 5.0),
  ('shinhan-deep-dream', '카페', 'cashback', 3.0),
  ('hyundai-zero', '주유소', 'cashback', 5.0),
  ('hyundai-zero', '대중교통', 'cashback', 3.0),
  ('kb-flex', '식당', 'points', 5.0),
  ('kb-flex', '온라인쇼핑', 'points', 3.0);

insert into merchant_categories (keyword, category) values
  ('GS25', '편의점'),
  ('CU', '편의점'),
  ('세븐일레븐', '편의점'),
  ('스타벅스', '카페'),
  ('투썸플레이스', '카페'),
  ('이디야', '카페'),
  ('GS칼텍스', '주유소'),
  ('SK주유소', '주유소'),
  ('맥도날드', '식당'),
  ('롯데리아', '식당'),
  ('쿠팡', '온라인쇼핑'),
  ('네이버쇼핑', '온라인쇼핑');
```

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock .gitignore android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist
git commit -m "chore: project setup with dependencies and native config"
```

---

## Task 2: Core 상수 + 데이터 모델

**Files:**
- Create: `lib/core/env.dart`
- Create: `lib/core/categories.dart`
- Create: `lib/data/models/card.dart`
- Create: `lib/data/models/card_benefit.dart`
- Create: `lib/data/models/merchant.dart`
- Create: `lib/domain/entities/ranked_card.dart`

- [ ] **Step 1: `lib/core/env.dart`**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String get naverClientId => dotenv.env['NAVER_CLIENT_ID']!;
  static String get naverClientSecret => dotenv.env['NAVER_CLIENT_SECRET']!;
}
```

- [ ] **Step 2: `lib/core/categories.dart`**

```dart
class Categories {
  static const List<String> all = [
    '편의점', '카페', '식당', '주유소', '대중교통', '온라인쇼핑', '마트', '약국', '기타',
  ];

  // 네이버 지도 카테고리 코드 → 내부 카테고리
  static const Map<String, String> naverCategoryMap = {
    'CS2': '편의점',   // 편의점
    'CE7': '카페',    // 카페,커피
    'FD6': '식당',    // 음식점
    'OL7': '주유소',  // 주유,충전소
    'SW8': '대중교통', // 지하철역
    'BK9': '마트',   // 은행 (fallback 제거용)
    'PM9': '약국',   // 약국
  };

  static String fromNaverCategory(String naverCode) {
    return naverCategoryMap[naverCode] ?? '기타';
  }
}
```

- [ ] **Step 3: `lib/data/models/card.dart`**

```dart
class Card {
  final String id;
  final String name;
  final String issuer;
  final String? imageUrl;

  const Card({
    required this.id,
    required this.name,
    required this.issuer,
    this.imageUrl,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        id: json['id'] as String,
        name: json['name'] as String,
        issuer: json['issuer'] as String,
        imageUrl: json['image_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'issuer': issuer,
        'image_url': imageUrl,
      };
}
```

- [ ] **Step 4: `lib/data/models/card_benefit.dart`**

```dart
class CardBenefit {
  final String cardId;
  final String category;
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

  factory CardBenefit.fromJson(Map<String, dynamic> json) => CardBenefit(
        cardId: json['card_id'] as String,
        category: json['category'] as String,
        benefitType: json['benefit_type'] as String,
        rate: (json['rate'] as num).toDouble(),
        conditions: json['conditions'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'category': category,
        'benefit_type': benefitType,
        'rate': rate,
        'conditions': conditions,
      };
}
```

- [ ] **Step 5: `lib/data/models/merchant.dart`**

```dart
class Merchant {
  final String title;
  final String category;
  final double lat;
  final double lng;
  final double? distanceMeters;

  const Merchant({
    required this.title,
    required this.category,
    required this.lat,
    required this.lng,
    this.distanceMeters,
  });
}
```

- [ ] **Step 6: `lib/domain/entities/ranked_card.dart`**

```dart
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';

class RankedCard {
  final Card card;
  final CardBenefit? benefit; // null이면 혜택 없음
  final bool hasBenefit;

  const RankedCard({
    required this.card,
    this.benefit,
    required this.hasBenefit,
  });
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/core/ lib/data/models/ lib/domain/entities/
git commit -m "feat: add core constants and data models"
```

---

## Task 3: UserCardRepository (Hive 로컬)

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
    await Hive.deleteFromDisk();
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
git commit -m "feat: add UserCardRepository with Hive local storage"
```

---

## Task 4: CardBenefitRepository (Supabase + 캐시)

**Files:**
- Create: `lib/data/repositories/card_benefit_repository.dart`

- [ ] **Step 1: `lib/data/repositories/card_benefit_repository.dart`**

```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';

class CardBenefitRepository {
  final SupabaseClient supabase;
  final Box<String> cacheBox;

  static const _cardsKey = 'cached_cards';
  static const _benefitsKey = 'cached_benefits';
  static const _syncedAtKey = 'last_synced_at';

  CardBenefitRepository({required this.supabase, required this.cacheBox});

  bool get isCacheValid {
    final synced = cacheBox.get(_syncedAtKey);
    if (synced == null) return false;
    final syncedAt = DateTime.tryParse(synced);
    if (syncedAt == null) return false;
    return DateTime.now().difference(syncedAt).inHours < 24;
  }

  Future<List<Card>> fetchCards({bool forceRefresh = false}) async {
    if (!forceRefresh && isCacheValid) {
      final cached = cacheBox.get(_cardsKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        return list.map((e) => Card.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    final response = await supabase.from('cards').select();
    final cards = (response as List)
        .map((e) => Card.fromJson(e as Map<String, dynamic>))
        .toList();
    await cacheBox.put(_cardsKey, jsonEncode(response));
    await cacheBox.put(_syncedAtKey, DateTime.now().toIso8601String());
    return cards;
  }

  Future<List<CardBenefit>> fetchBenefits({bool forceRefresh = false}) async {
    if (!forceRefresh && isCacheValid) {
      final cached = cacheBox.get(_benefitsKey);
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        return list
            .map((e) => CardBenefit.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    final response = await supabase.from('card_benefits').select();
    final benefits = (response as List)
        .map((e) => CardBenefit.fromJson(e as Map<String, dynamic>))
        .toList();
    await cacheBox.put(_benefitsKey, jsonEncode(response));
    return benefits;
  }

  Future<String?> resolveMerchantCategory(String merchantName) async {
    final response = await supabase
        .from('merchant_categories')
        .select('category')
        .ilike('keyword', '%$merchantName%')
        .limit(1);
    final list = response as List;
    if (list.isEmpty) return null;
    return list.first['category'] as String?;
  }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
flutter analyze lib/data/repositories/card_benefit_repository.dart
```

Expected: 오류 없음

- [ ] **Step 3: Commit**

```bash
git add lib/data/repositories/card_benefit_repository.dart
git commit -m "feat: add CardBenefitRepository with Supabase and Hive cache"
```

---

## Task 5: MapRepository (Naver Local Search)

**Files:**
- Create: `lib/data/repositories/map_repository.dart`

- [ ] **Step 1: `lib/data/repositories/map_repository.dart`**

```dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:card_radar/core/env.dart';
import 'package:card_radar/data/models/merchant.dart';

class MapRepository {
  static const _searchUrl =
      'https://openapi.naver.com/v1/search/local.json';

  Future<List<Merchant>> searchNearby({
    required String query,
    required double userLat,
    required double userLng,
    int display = 10,
  }) async {
    final uri = Uri.parse(_searchUrl).replace(queryParameters: {
      'query': query,
      'display': display.toString(),
      'sort': 'random',
    });

    final response = await http.get(uri, headers: {
      'X-Naver-Client-Id': Env.naverClientId,
      'X-Naver-Client-Secret': Env.naverClientSecret,
    });

    if (response.statusCode != 200) {
      throw Exception('Naver API error: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List;

    return items.map((item) {
      // Naver mapx/mapy는 경도/위도 × 1e7 정수
      final lng = (item['mapx'] as int) / 1e7;
      final lat = (item['mapy'] as int) / 1e7;
      return Merchant(
        title: (item['title'] as String).replaceAll(RegExp(r'<[^>]*>'), ''),
        category: item['category'] as String? ?? '기타',
        lat: lat,
        lng: lng,
        distanceMeters: _haversine(userLat, userLng, lat, lng),
      );
    }).toList()
      ..sort((a, b) =>
          (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
```

- [ ] **Step 2: 빌드 확인**

```bash
flutter analyze lib/data/repositories/map_repository.dart
```

Expected: 오류 없음

- [ ] **Step 3: Commit**

```bash
git add lib/data/repositories/map_repository.dart
git commit -m "feat: add MapRepository with Naver Local Search API"
```

---

## Task 6: CardRankingUseCase (TDD 핵심 로직)

**Files:**
- Create: `lib/domain/usecases/card_ranking_usecase.dart`
- Create: `test/domain/card_ranking_usecase_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/card_ranking_usecase_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';

void main() {
  final cards = [
    const Card(id: 'card-a', name: 'Card A', issuer: 'Bank A'),
    const Card(id: 'card-b', name: 'Card B', issuer: 'Bank B'),
    const Card(id: 'card-c', name: 'Card C', issuer: 'Bank C'),
  ];

  final benefits = [
    const CardBenefit(cardId: 'card-a', category: '편의점', benefitType: 'cashback', rate: 5.0),
    const CardBenefit(cardId: 'card-b', category: '편의점', benefitType: 'points', rate: 3.0),
    const CardBenefit(cardId: 'card-a', category: '카페', benefitType: 'cashback', rate: 2.0),
  ];

  late CardRankingUseCase useCase;

  setUp(() {
    useCase = CardRankingUseCase();
  });

  test('카테고리 일치 카드를 rate 내림차순으로 정렬', () {
    final result = useCase.rank(
      merchantCategory: '편의점',
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
      merchantCategory: '편의점',
      userCards: cards,
      allBenefits: benefits,
    );

    final noBenel = result.where((r) => !r.hasBenefit).toList();
    expect(noBenel.length, 1);
    expect(noBenel.first.card.id, 'card-c');
    expect(result.last.card.id, 'card-c');
  });

  test('카테고리 혜택이 없는 경우 모두 hasBenefit=false', () {
    final result = useCase.rank(
      merchantCategory: '주유소',
      userCards: cards,
      allBenefits: benefits,
    );

    expect(result.every((r) => !r.hasBenefit), isTrue);
  });

  test('보유 카드가 없으면 빈 목록 반환', () {
    final result = useCase.rank(
      merchantCategory: '편의점',
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
import 'package:card_radar/domain/entities/ranked_card.dart';

class CardRankingUseCase {
  List<RankedCard> rank({
    required String merchantCategory,
    required List<Card> userCards,
    required List<CardBenefit> allBenefits,
  }) {
    if (userCards.isEmpty) return [];

    final withBenefit = <RankedCard>[];
    final withoutBenefit = <RankedCard>[];

    for (final card in userCards) {
      final benefit = allBenefits
          .where((b) => b.cardId == card.id && b.category == merchantCategory)
          .fold<CardBenefit?>(null, (best, b) =>
              best == null || b.rate > best.rate ? b : best);

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
git commit -m "feat: add CardRankingUseCase with TDD"
```

---

## Task 7: main.dart + Riverpod Providers

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `lib/presentation/router.dart`
- Create: `lib/presentation/providers/user_cards_provider.dart`
- Create: `lib/presentation/providers/card_benefits_provider.dart`

- [ ] **Step 1: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/core/env.dart';
import 'package:card_radar/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();
  await Hive.openBox<String>('user_cards');
  await Hive.openBox<String>('benefit_cache');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: CardPickerApp()));
}
```

- [ ] **Step 2: `lib/app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/presentation/router.dart';

class CardPickerApp extends ConsumerWidget {
  const CardPickerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Card Picker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
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
import 'package:card_radar/presentation/screens/onboarding_screen.dart';
import 'package:card_radar/presentation/screens/home_screen.dart';
import 'package:card_radar/presentation/screens/search_screen.dart';
import 'package:card_radar/presentation/screens/ranking_screen.dart';
import 'package:card_radar/presentation/screens/my_cards_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(
      path: '/ranking',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RankingScreen(
          merchantName: extra['merchantName'] as String,
          merchantCategory: extra['merchantCategory'] as String,
        );
      },
    ),
    GoRoute(path: '/my-cards', builder: (_, __) => const MyCardsScreen()),
  ],
);
```

- [ ] **Step 4: `lib/presentation/providers/card_benefits_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/repositories/card_benefit_repository.dart';

final cardBenefitRepoProvider = Provider<CardBenefitRepository>((ref) {
  return CardBenefitRepository(
    supabase: Supabase.instance.client,
    cacheBox: Hive.box<String>('benefit_cache'),
  );
});

final allCardsProvider = FutureProvider<List<Card>>((ref) async {
  return ref.read(cardBenefitRepoProvider).fetchCards();
});

final allBenefitsProvider = FutureProvider<List<CardBenefit>>((ref) async {
  return ref.read(cardBenefitRepoProvider).fetchBenefits();
});
```

- [ ] **Step 5: `lib/presentation/providers/user_cards_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:card_radar/data/models/card.dart';
import 'package:card_radar/data/repositories/user_card_repository.dart';

final userCardRepoProvider = Provider<UserCardRepository>((ref) {
  return UserCardRepository(box: Hive.box<String>('user_cards'));
});

class UserCardsNotifier extends StateNotifier<List<Card>> {
  final UserCardRepository _repo;
  final List<Card> _allCards;

  UserCardsNotifier(this._repo, this._allCards)
      : super(_allCards
            .where((c) => _repo.cardIds.contains(c.id))
            .toList());

  Future<void> addCard(String cardId) async {
    await _repo.addCard(cardId);
    state = _allCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  Future<void> removeCard(String cardId) async {
    await _repo.removeCard(cardId);
    state = _allCards.where((c) => _repo.cardIds.contains(c.id)).toList();
  }

  bool contains(String cardId) => _repo.contains(cardId);
}

final userCardsProvider =
    StateNotifierProvider<UserCardsNotifier, List<Card>>((ref) {
  final repo = ref.read(userCardRepoProvider);
  final allCards = ref.watch(allCardsProvider).valueOrNull ?? [];
  return UserCardsNotifier(repo, allCards);
});
```

- [ ] **Step 6: 빌드 확인**

```bash
flutter analyze lib/
```

Expected: 오류 없음 (또는 info 수준만)

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/app.dart lib/presentation/router.dart lib/presentation/providers/
git commit -m "feat: add main entry, router, and Riverpod providers"
```

---

## Task 8: 내 카드 관리 화면

**Files:**
- Create: `lib/presentation/screens/my_cards_screen.dart`
- Create: `lib/presentation/widgets/card_rank_item.dart`

- [ ] **Step 1: `lib/presentation/screens/my_cards_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/presentation/providers/card_benefits_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCardsAsync = ref.watch(allCardsProvider);
    final userCards = ref.watch(userCardsProvider);
    final notifier = ref.read(userCardsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('내 카드 관리')),
      body: allCardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (allCards) => ListView.builder(
          itemCount: allCards.length,
          itemBuilder: (context, index) {
            final card = allCards[index];
            final isOwned = notifier.contains(card.id);
            return CheckboxListTile(
              title: Text(card.name),
              subtitle: Text(card.issuer),
              value: isOwned,
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
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/my_cards_screen.dart
git commit -m "feat: add MyCardsScreen"
```

---

## Task 9: 홈 화면 (네이버 지도)

**Files:**
- Create: `lib/presentation/screens/home_screen.dart`

- [ ] **Step 1: `lib/presentation/screens/home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  NaverMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNaverMap();
  }

  Future<void> _initNaverMap() async {
    await NaverMapSdk.instance.initialize(
      clientId: const String.fromEnvironment('NAVER_MAP_CLIENT_ID'),
    );
  }

  Future<Position> _getLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5665, 126.9780), // 서울 시청 기본값
                zoom: 15,
              ),
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              final pos = await _getLocation();
              await controller.updateCamera(
                NCameraUpdate.withParams(
                  target: NLatLng(pos.latitude, pos.longitude),
                  zoom: 15,
                ),
              );
            },
          ),
          // 상단 검색창
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '업체명 검색',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              context.push('/search',
                                  extra: _searchController.text);
                            }
                          },
                        ),
                      ),
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          context.push('/search', extra: query);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.credit_card),
                      onPressed: () => context.push('/my-cards'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/home_screen.dart
git commit -m "feat: add HomeScreen with Naver Map"
```

---

## Task 10: 검색 화면

**Files:**
- Create: `lib/presentation/screens/search_screen.dart`
- Create: `lib/presentation/widgets/merchant_list_item.dart`
- Create: `lib/presentation/providers/map_search_provider.dart`

- [ ] **Step 1: `lib/presentation/providers/map_search_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:card_radar/data/models/merchant.dart';
import 'package:card_radar/data/repositories/map_repository.dart';

final mapRepoProvider = Provider<MapRepository>((ref) => MapRepository());

final merchantSearchProvider = FutureProvider.family<List<Merchant>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition();
    } catch (_) {
      // 위치 권한 없을 경우 서울 시청 기본값
      pos = Position(
        latitude: 37.5665, longitude: 126.9780,
        timestamp: DateTime.now(), accuracy: 0,
        altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );
    }
    return ref.read(mapRepoProvider).searchNearby(
          query: query,
          userLat: pos.latitude,
          userLng: pos.longitude,
        );
  },
);
```

- [ ] **Step 2: `lib/presentation/widgets/merchant_list_item.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:card_radar/data/models/merchant.dart';

class MerchantListItem extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback onTap;

  const MerchantListItem({
    super.key,
    required this.merchant,
    required this.onTap,
  });

  String get _distanceText {
    final d = merchant.distanceMeters;
    if (d == null) return '';
    if (d < 1000) return '${d.toStringAsFixed(0)}m';
    return '${(d / 1000).toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.store),
      title: Text(merchant.title),
      subtitle: Text(merchant.category),
      trailing: Text(_distanceText,
          style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 3: `lib/presentation/screens/search_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:card_radar/core/categories.dart';
import 'package:card_radar/presentation/providers/map_search_provider.dart';
import 'package:card_radar/presentation/widgets/merchant_list_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // GoRouter extra로 초기 쿼리 수신
    final extra = GoRouterState.of(context).extra;
    if (extra is String && _query.isEmpty) {
      _query = extra;
      _controller.text = extra;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(merchantSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '업체명 검색', border: InputBorder.none),
          onSubmitted: (q) => setState(() => _query = q),
        ),
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('검색 오류: $e')),
        data: (merchants) => merchants.isEmpty
            ? const Center(child: Text('검색 결과가 없습니다'))
            : ListView.builder(
                itemCount: merchants.length,
                itemBuilder: (context, index) {
                  final merchant = merchants[index];
                  return MerchantListItem(
                    merchant: merchant,
                    onTap: () {
                      final category = Categories.fromNaverCategory(
                        merchant.category,
                      );
                      context.push('/ranking', extra: {
                        'merchantName': merchant.title,
                        'merchantCategory': category,
                      });
                    },
                  );
                },
              ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/providers/map_search_provider.dart lib/presentation/widgets/merchant_list_item.dart lib/presentation/screens/search_screen.dart
git commit -m "feat: add SearchScreen with Naver Local Search"
```

---

## Task 11: 카드 순위 화면

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

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rankedCard.hasBenefit
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Text(
          rankedCard.hasBenefit ? '$rank' : '-',
          style: TextStyle(
            color: rankedCard.hasBenefit
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(card.name),
      subtitle: Text(card.issuer),
      trailing: rankedCard.hasBenefit
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${benefit!.rate.toStringAsFixed(1)}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
                Text(
                  benefit.benefitType == 'cashback' ? '캐시백' : '포인트',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          : Text('혜택 없음',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey)),
    );
  }
}
```

- [ ] **Step 2: `lib/presentation/screens/ranking_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/domain/usecases/card_ranking_usecase.dart';
import 'package:card_radar/presentation/providers/card_benefits_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';
import 'package:card_radar/presentation/widgets/card_rank_item.dart';

class RankingScreen extends ConsumerWidget {
  final String merchantName;
  final String merchantCategory;

  const RankingScreen({
    super.key,
    required this.merchantName,
    required this.merchantCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCards = ref.watch(userCardsProvider);
    final benefitsAsync = ref.watch(allBenefitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(merchantName),
            Text(merchantCategory,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: benefitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (benefits) {
          if (userCards.isEmpty) {
            return const Center(child: Text('내 카드를 먼저 등록해 주세요'));
          }

          final useCase = CardRankingUseCase();
          final ranked = useCase.rank(
            merchantCategory: merchantCategory,
            userCards: userCards,
            allBenefits: benefits,
          );

          int rank = 1;
          return ListView.separated(
            itemCount: ranked.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = ranked[index];
              final displayRank = item.hasBenefit ? rank++ : 0;
              return CardRankItem(rankedCard: item, rank: displayRank);
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
git add lib/presentation/widgets/card_rank_item.dart lib/presentation/screens/ranking_screen.dart
git commit -m "feat: add RankingScreen and CardRankItem widget"
```

---

## Task 12: 온보딩 화면

**Files:**
- Create: `lib/presentation/screens/onboarding_screen.dart`

- [ ] **Step 1: `lib/presentation/screens/onboarding_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:card_radar/presentation/providers/card_benefits_provider.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이미 카드 등록된 경우 홈으로
    final box = Hive.box<String>('user_cards');
    final stored = box.get('card_ids');
    if (stored != null && stored.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    final allCardsAsync = ref.watch(allCardsProvider);
    final notifier = ref.read(userCardsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('보유 카드를 선택해 주세요',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('결제 시 최적 카드를 추천해 드립니다',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Expanded(
                child: allCardsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('카드 목록 로드 실패: $e')),
                  data: (cards) => ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
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
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/home'),
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

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/onboarding_screen.dart
git commit -m "feat: add OnboardingScreen"
```

---

## Task 13: 데이터 파이프라인 (Python)

**Files:**
- Create: `scripts/crawler.py`
- Create: `scripts/parser.py`
- Create: `scripts/uploader.py`
- Create: `scripts/requirements.txt`

- [ ] **Step 1: `scripts/requirements.txt`**

```
anthropic>=0.30.0
supabase>=2.5.0
requests>=2.31.0
beautifulsoup4>=4.12.0
python-dotenv>=1.0.0
```

- [ ] **Step 2: `scripts/crawler.py`**

```python
"""카드 혜택 페이지 크롤링 — 카드고리스트(cardgorilla.com) 기준"""
import requests
from bs4 import BeautifulSoup

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; CardPickerBot/1.0)"}

def crawl_card_benefits(card_name: str) -> str:
    """카드 이름으로 카드고릴라 검색 후 혜택 텍스트 반환"""
    search_url = f"https://www.cardgorilla.com/cards?search={requests.utils.quote(card_name)}"
    response = requests.get(search_url, headers=HEADERS, timeout=10)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    # 첫 번째 카드 링크 추출 (사이트 구조에 따라 수정 필요)
    first_card = soup.select_one(".card-item a")
    if not first_card:
        return ""

    card_url = "https://www.cardgorilla.com" + first_card["href"]
    card_response = requests.get(card_url, headers=HEADERS, timeout=10)
    card_soup = BeautifulSoup(card_response.text, "html.parser")

    # 혜택 섹션 텍스트 추출 (사이트 구조에 따라 수정 필요)
    benefit_section = card_soup.select_one(".benefit-list")
    return benefit_section.get_text(separator="\n") if benefit_section else ""
```

- [ ] **Step 3: `scripts/parser.py`**

```python
"""Claude API로 혜택 텍스트 → 구조화 JSON 파싱"""
import json
import anthropic

client = anthropic.Anthropic()

PARSE_PROMPT = """
다음은 신용카드 혜택 안내 텍스트입니다.
각 혜택을 JSON 배열로 추출하세요. 각 항목은 다음 형식을 따릅니다:
{
  "category": "편의점|카페|식당|주유소|대중교통|온라인쇼핑|마트|약국|기타",
  "benefit_type": "cashback|points",
  "rate": <숫자 — % 단위>,
  "conditions": "<월 한도 등 조건, 없으면 null>"
}

카테고리에 해당하지 않는 혜택(항공 마일리지, 해외, 콘도 등)은 제외하세요.
숫자로 표현할 수 없는 혜택도 제외하세요.
JSON 배열만 출력하세요. 설명 없이.

혜택 텍스트:
{benefit_text}
"""

def parse_benefits(card_id: str, benefit_text: str) -> list[dict]:
    if not benefit_text.strip():
        return []

    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": PARSE_PROMPT.format(benefit_text=benefit_text),
        }],
    )

    raw = message.content[0].text.strip()
    try:
        benefits = json.loads(raw)
        return [{"card_id": card_id, **b} for b in benefits]
    except json.JSONDecodeError:
        print(f"[WARN] JSON 파싱 실패 for {card_id}: {raw[:100]}")
        return []
```

- [ ] **Step 4: `scripts/uploader.py`**

```python
"""파싱된 혜택 데이터를 Supabase에 upsert"""
import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_ROLE_KEY"])

def upsert_card(card_id: str, name: str, issuer: str) -> None:
    supabase.table("cards").upsert({
        "id": card_id, "name": name, "issuer": issuer
    }).execute()

def upsert_benefits(card_id: str, benefits: list[dict]) -> None:
    # 기존 혜택 삭제 후 재삽입
    supabase.table("card_benefits").delete().eq("card_id", card_id).execute()
    if benefits:
        supabase.table("card_benefits").insert(benefits).execute()

def run_pipeline(cards: list[dict]) -> None:
    """
    cards: [{"id": "shinhan-deep-dream", "name": "신한 Deep Dream", "issuer": "신한카드"}, ...]
    """
    from crawler import crawl_card_benefits
    from parser import parse_benefits

    for card in cards:
        print(f"Processing {card['name']}...")
        upsert_card(card["id"], card["name"], card["issuer"])
        text = crawl_card_benefits(card["name"])
        benefits = parse_benefits(card["id"], text)
        upsert_benefits(card["id"], benefits)
        print(f"  → {len(benefits)} benefits upserted")

if __name__ == "__main__":
    CARDS = [
        {"id": "shinhan-deep-dream", "name": "신한 Deep Dream", "issuer": "신한카드"},
        {"id": "hyundai-zero", "name": "현대카드 ZERO", "issuer": "현대카드"},
        {"id": "kb-flex", "name": "KB 플렉스", "issuer": "KB국민카드"},
    ]
    run_pipeline(CARDS)
```

- [ ] **Step 5: 파이프라인 실행 테스트**

```bash
cd scripts
pip install -r requirements.txt
# .env에 SUPABASE_SERVICE_ROLE_KEY, ANTHROPIC_API_KEY 추가 후:
python uploader.py
```

Expected: 각 카드별 혜택 건수 출력 및 Supabase 테이블에 데이터 반영

- [ ] **Step 6: Commit**

```bash
git add scripts/
git commit -m "feat: add data pipeline (crawler + parser + uploader)"
```

---

## Task 14: 전체 통합 테스트

- [ ] **Step 1: 전체 단위 테스트 실행**

```bash
flutter test
```

Expected: 모든 테스트 PASS

- [ ] **Step 2: 앱 실행 확인 (Android 에뮬레이터 or 실기기)**

```bash
flutter run
```

확인 체크리스트:
- [ ] 첫 실행: 온보딩 화면 표시 + 카드 선택 가능
- [ ] 카드 선택 후 "시작하기" → 홈(지도) 이동
- [ ] 지도 표시 및 현재 위치 이동
- [ ] 검색창에 "스타벅스" 입력 → 거리순 목록
- [ ] 업체 탭 → 카드 순위 화면 표시 (% 내림차순)
- [ ] 혜택 없는 카드는 하단에 "혜택 없음" 표시
- [ ] 내 카드 버튼 → 카드 추가/삭제 동작
- [ ] 앱 재실행 시 카드 목록 유지 (Hive 영속성)

- [ ] **Step 3: 최종 Commit**

```bash
git add .
git commit -m "chore: final integration verified"
```

---

## 자기 검토 (Self-Review)

### 스펙 커버리지 확인

| 스펙 요구사항 | 구현 태스크 |
|---|---|
| Flutter 모바일 앱 | Task 1 |
| 카드 혜택 DB (Supabase) | Task 1 (SQL), Task 4 |
| 사용자 카드 목록 (Hive) | Task 3, Task 7 |
| 카테고리 + % 기준 정렬 | Task 6 (CardRankingUseCase) |
| 네이버 지도 | Task 9 |
| 업체 검색 (거리순) | Task 5, Task 10 |
| 카드 순위 화면 | Task 11 |
| 내 카드 관리 화면 | Task 8 |
| 온보딩 (첫 실행) | Task 12 |
| 데이터 파이프라인 | Task 13 |

모든 요구사항 커버됨. ✓
