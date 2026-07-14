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
- [ ] **2-5.** Supabase CLI로 프로젝트를 연결하고 버전 관리된 마이그레이션을 적용:

```powershell
supabase link --project-ref YOUR_PROJECT_REF
supabase db push --dry-run
supabase db push
```

  마이그레이션은 `cards`, `card_benefits` 테이블에 RLS를 활성화하고
  `anon`, `authenticated` 역할에는 조회 권한만 부여합니다.

- [ ] **2-6.** `.env.functions.example`을 `.env.functions`로 복사하고 실제 값을 입력
  - `GH_ISSUE_TOKEN`: `jaywapp/card-radar` Issues 쓰기만 허용한 fine-grained token
  - `KFTC_CLIENT_ID`, `KFTC_CLIENT_SECRET`: 오픈뱅킹 애플리케이션 자격 증명
  - `KFTC_REDIRECT_URI`: `kftc-callback` 함수 URL
  - `KFTC_BANK_TRAN_ID_PREFIX`: 이용기관코드 10자리와 `U`를 합친 접두사

- [ ] **2-7.** 함수 시크릿 등록 및 Edge Functions 배포:

```powershell
supabase secrets set --env-file .env.functions
supabase functions deploy kftc-callback kftc-import submit-feedback
```

  `supabase/config.toml`에서 세 함수의 JWT 검증을 비활성화했습니다. 로그인 없는
  모바일 앱과 외부 KFTC 콜백이 호출하는 공개 엔드포인트이므로, 외부 서비스
  비밀키는 반드시 Edge Function 환경 변수에만 저장합니다.

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
