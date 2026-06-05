# 카드레이더 (CardRadar)

> 결제할 때 가장 유리한 카드를 바로 찾아주는 앱

[![Release](https://img.shields.io/github/v/release/jaywapp/card-radar)](https://github.com/jaywapp/card-radar/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)

## 주요 기능

- 🏪 **카테고리별 추천** — 편의점, 카페, 식당, 주유소 등 8개 카테고리
- 💳 **내 카드 등록** — 보유 카드를 등록하면 맞춤 혜택 순위 제공
- 💰 **혜택 비교** — 캐시백/포인트 비율 기준 카드 내림차순 정렬
- 🔗 **바로 신청** — 혜택 좋은 카드 바로 신청 링크 연결

## 지원 카드 (19개)

| 카드사 | 카드명 |
|--------|--------|
| 신한카드 | Deep Dream, S-Line, Mr.Life |
| 현대카드 | ZERO, M, SHOPPING |
| KB국민카드 | 플렉스카드, 탄탄대로, 노리 1.5 |
| 삼성카드 | taptap, iD SIMPLE, 삼성카드 7 |
| 롯데카드 | DC PLUS, LIKIT |
| 우리카드 | 다통장카드, Da Big카드 |
| 하나카드 | 1Q카드, 모아 |
| NH농협카드 | 올원카드 올바른FLEX |

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
