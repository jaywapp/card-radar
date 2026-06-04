# 카드레이더 (CardRadar) — 설계 스펙

**작성일:** 2026-06-05  
**플랫폼:** Flutter (iOS / Android)  
**성격:** 퍼블릭 앱, 로그인 없음

---

## 개요

사용자가 보유한 카드 목록을 등록해두면, 결제할 업체/장소를 지도 또는 검색으로 선택했을 때 혜택(캐시백/포인트 비율) 기준으로 카드를 내림차순 정렬해 추천해주는 Flutter 모바일 앱.

---

## 아키텍처

```
┌─────────────────────────────────────────────┐
│              Flutter App                     │
│  ┌──────────────┐   ┌──────────────────────┐│
│  │  Presentation│   │       Domain          ││
│  │  (Screens)   │◄──│  CardRankingUseCase   ││
│  └──────────────┘   └──────────┬───────────┘│
│                                │             │
│  ┌─────────────────────────────▼───────────┐│
│  │           Data Layer                     ││
│  │  UserCardRepo   CardBenefitRepo  MapRepo ││
│  │  (로컬 Hive)    (Supabase+캐시) (네이버) ││
│  └──────────────┬──────────────┘            │
└─────────────────┼────────────────────────────┘
                  │
    ┌─────────────▼────────────┐   ┌──────────────┐
    │   Supabase (Postgres)    │   │ Naver Maps   │
    │   cards, card_benefits   │   │ Flutter SDK  │
    └──────────────────────────┘   └──────────────┘

    ┌─────────────────────────────┐
    │  데이터 파이프라인 (별도)    │
    │  Python + Claude API         │
    │  크롤링 → 구조화 → Supabase  │
    └─────────────────────────────┘
```

**레이어 책임:**

| 레이어 | 역할 |
|--------|------|
| Presentation | 화면 렌더링, 사용자 입력 처리 |
| Domain | `CardRankingUseCase` — 업체 카테고리 기준 카드 정렬 |
| Data | 로컬(Hive) / 원격(Supabase) / 지도(Naver Maps) 추상화 |

---

## 데이터 모델

### Supabase (원격)

```sql
-- 카드 기본 정보
cards (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  issuer      TEXT NOT NULL,
  image_url   TEXT
)

-- 카드별 혜택
card_benefits (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id       TEXT REFERENCES cards(id),
  category      TEXT NOT NULL,       -- 편의점, 카페, 식당, 주유소, 대중교통, 온라인쇼핑, ...
  benefit_type  TEXT NOT NULL,       -- cashback | points
  rate          NUMERIC(5,2) NOT NULL, -- % 단위
  conditions    TEXT                 -- 월 한도 등 부가 조건 (nullable)
)

-- 업체 → 카테고리 매핑
merchant_categories (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  keyword   TEXT UNIQUE NOT NULL,   -- GS25, 스타벅스, 이마트 ...
  category  TEXT NOT NULL
)
```

### 로컬 (Hive)

```
user_cards:     List<String>             // 보유 카드 ID 목록
benefit_cache:  Map<String, List<Benefit>> // card_id → 혜택 목록
last_synced:    DateTime
```

---

## 핵심 비즈니스 로직

### CardRankingUseCase.rank(merchantName)

```
1. merchantName → category 매핑 (merchant_categories 검색, 없으면 기본 "기타")
2. user_cards 중 해당 category 혜택이 있는 카드 필터
3. rate % 내림차순 정렬
4. 혜택 없는 카드는 하단에 "혜택 없음" 그룹으로 분리 표시
```

---

## 화면 구성

```
앱 실행
  └─► 홈 (네이버 지도)
        ├─ 업체 마커 탭 ──────────────► 카드 순위 화면
        ├─ 검색창 입력 → 결과 거리순 ──► 카드 순위 화면
        └─ 우상단 [내 카드] 버튼
              └─► 내 카드 관리
                    ├─ 카드 추가 (DB 검색/선택)
                    └─ 카드 삭제
```

| 화면 | 핵심 기능 |
|------|-----------|
| 홈 (지도) | 현재 위치 중심, 주변 업체 마커 표시, 검색창 |
| 검색 결과 | 업체명 입력 → 거리순 목록 |
| 카드 순위 | 선택 업체 기준 내 카드 % 내림차순. 혜택 없는 카드는 하단 |
| 내 카드 관리 | 보유 카드 추가/삭제. 첫 실행 시 온보딩으로 유도 |

**첫 실행 플로우:** 앱 설치 → 내 카드 등록 온보딩 → 홈(지도)

---

## 기술 스택

| 항목 | 선택 |
|------|------|
| 플랫폼 | Flutter 3.x (iOS / Android) |
| 상태관리 | Riverpod |
| 로컬 저장소 | Hive |
| 원격 DB | Supabase (Postgres) |
| 지도 | Naver Maps Flutter SDK |
| 혜택 파싱 파이프라인 | Python + Claude API (별도 스크립트) |
| 인증 | 없음 |

---

## 데이터 파이프라인 (별도)

```
scripts/pipeline/
  crawler.py     # 카드사 사이트 / 비교 사이트 크롤링
  parser.py      # Claude API로 혜택 텍스트 → 구조화 JSON
  uploader.py    # Supabase upsert

실행: python pipeline.py --target all
주기: 수동 or 크론 (월 1회 권장)
```

---

## 수익 구조 (고려 중)

1. **카드 신청 제휴 수수료** — 카드 순위 화면에 "이 카드 신청하기" 딥링크, 카드 발급 시 수수료 수취
2. **카드사 광고 노출** — 특정 카드사 상단 고정 노출 비용

---

## 범위 외 (v1 미포함)

- 로그인 / 다기기 동기화
- 사용자가 직접 혜택 수정
- 푸시 알림 (신규 혜택 갱신)
- 결제 금액 입력 → 실제 혜택 금액 계산
