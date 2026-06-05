# 카드레이더 — PC 직접 작업 체크리스트

> 저녁에 PC에서 순서대로 진행하세요. 각 항목 완료 후 체크 표시.

---

## 1. 네이버 지도 API 키 발급 (MVP B 필수)

**소요 시간:** 약 10분  
**필요한 것:** 네이버 계정

- [ ] **1-1.** https://console.ncloud.com 접속 → 로그인
- [ ] **1-2.** 좌측 메뉴 → **AI·NAVER API** → **Application 등록**
- [ ] **1-3.** Application 이름: `card-radar` 입력
- [ ] **1-4.** 사용 API 선택: **Maps → Mobile Dynamic Map** 체크
- [ ] **1-5.** Android 앱 등록
  - 패키지명: `com.jaywapp.card_radar`
- [ ] **1-6.** 등록 후 **Client ID** 복사해두기

> Client ID는 `AIzaSy...` 형태가 아니라 영문/숫자 조합입니다.

---

## 2. Supabase 프로젝트 셋업 (MVP B 또는 별도 목표)

**소요 시간:** 약 15분  
**필요한 것:** GitHub 계정 (또는 이메일)

- [ ] **2-1.** https://supabase.com 접속 → **Start your project** → GitHub 로그인
- [ ] **2-2.** **New Project** 클릭
  - Organization: 개인 계정 선택
  - Project name: `card-radar`
  - Database password: 강력한 비밀번호 설정 (따로 저장해두기)
  - Region: **Northeast Asia (Seoul)** 선택
- [ ] **2-3.** 프로젝트 생성 완료 대기 (약 2분)
- [ ] **2-4.** 좌측 **Settings → API** 에서 두 가지 복사해두기:
  - **Project URL** (예: `https://xxxx.supabase.co`)
  - **anon public key** (긴 JWT 토큰)
- [ ] **2-5.** SQL Editor에서 아래 테이블 생성 실행:

```sql
create table cards (
  id text primary key,
  name text not null,
  issuer text not null,
  image_url text,
  apply_url text
);

create table card_benefits (
  id uuid primary key default gen_random_uuid(),
  card_id text references cards(id),
  category text not null,
  benefit_type text not null,
  rate numeric(5,2) not null,
  conditions text
);
```

---

## 3. Play Store 배포 준비 (배포 목표 시)

**소요 시간:** 약 30분  
**필요한 것:** Google 계정, $25 결제 수단

- [ ] **3-1.** https://play.google.com/console 접속
- [ ] **3-2.** 개발자 계정 등록 → **$25** 일회성 등록비 결제
- [ ] **3-3.** 앱 서명 키 생성 (한 번만, 분실 시 재배포 불가 — 안전한 곳에 백업 필수):
  ```
  keytool -genkey -v -keystore card-radar-release.jks \
    -alias card-radar -keyalg RSA -keysize 2048 -validity 10000
  ```
  입력 정보:
  - 이름, 조직, 도시, 국가 (임의로 입력 가능)
  - **storePassword, keyPassword** 따로 저장해두기
- [ ] **3-4.** 생성된 `card-radar-release.jks` 파일을 안전한 곳에 백업
- [ ] **3-5.** GitHub Secrets에 등록 (repo: jaywapp/card-radar):
  - `KEYSTORE_BASE64` : `base64 card-radar-release.jks` 결과값
  - `KEYSTORE_PASSWORD` : storePassword
  - `KEY_ALIAS` : `card-radar`
  - `KEY_PASSWORD` : keyPassword

---

## 완료 후 Claude에게 알려줄 것

작업 완료 후 아래 정보를 전달해주세요 (코드에 반영할게요):

```
네이버 Client ID: [붙여넣기]
Supabase URL: [붙여넣기]
Supabase anon key: [붙여넣기]
```

> Play Store 키 정보는 GitHub Secrets에만 저장하면 됩니다 — 저한테 직접 전달하지 않아도 됩니다.
