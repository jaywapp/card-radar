# 빌드 및 기능 검증 작업

orchestrator: Codex

| 작업 | owner | model | effort | depends_on | parallel_group | files | verification | status |
|---|---|---|---|---|---|---|---|---|
| 로컬 빌드 설정 복구 | Codex | gpt-6-astra | high | 분석·설계 | card-radar | 설정 예제·README | analyze 통과, 원래 API 21 APK는 SDK 요구조건 미충족 | blocked |
| HTTP·입력·인증 경계 검증 | Codex | gpt-6-astra | high | 설정 복구 | card-radar | KFTC 모델·저장소·provider 및 test | 정상·실패·빈 값·권한·state 회귀 | complete |
| 실제 화면 회귀 검증 | Codex | gpt-6-astra | high | 경계 검증 | card-radar | test/widget_test.dart | 실제 Hive 메모리 백엔드 및 앱 router 기반 위젯 테스트 | complete |
| API 21 호환성 후속 조사 | Codex | gpt-6-astra | high | APK 요구조건 실패 확인 | card-radar | 분석·설계·작업 문서 | 공식 태그·로컬 잠긴 패키지 선언 비교 | complete |

동일 저장소의 설정과 검증은 순차 진행한다. Excel/.NET/중첩 프로젝트는 다른 Codex 에이전트가 병렬 담당한다. 실제 외부 API 및 배포는 수행하지 않는다.

## 검증 결과

- `flutter analyze --no-pub`: 문제 0개.
- `flutter test --no-pub`: 30개 통과. 설정 누락 시 안전한 오류 상태를 확인했다.
- `flutter test --no-pub --dart-define=KFTC_CLIENT_ID=fixture-client --dart-define=KFTC_CLIENT_SECRET=fixture-secret --dart-define=KFTC_REDIRECT_URI=https://fixture.invalid/callback`: 30개 통과. HTTP·브라우저 실행은 테스트 대역이며 실제 요청하지 않는다.
- OAuth 정상 콜백 → 토큰/카드 조회 → Hive 저장, 잘못된 state·재전송 차단을 검증했다.
- 화면 4개 회귀: 온보딩/선택/검색/삭제, 저장된 카드/카테고리 랭킹, 조회 실패, 플랫폼 링크 오류. 위젯은 Hive 메모리 백엔드를 사용하고 기존 저장소 테스트는 임시 디스크 파일을 검증한다.
- 카드 삭제 후 체크박스 갱신 누락을 재현·수정했다. 선택 ID 집합을 한 번 구성해 행마다 Hive 문자열을 다시 분해하지 않는다.
- APK 첫 빌드는 성공했지만 Flutter가 `minSdk=21`을 기본값 24로 자동 상향했다. `aapt`로 실제 APK의 최소 SDK 24를 확인했고 소스 설정은 21로 복구했다. 이 산출물은 API 21 지원 빌드의 성공 증거가 아니다.
- 원래 설정에서 `gradlew :app:assembleDebug '-Pkotlin.incremental=false' '-Pkotlin.compiler.execution.strategy=in-process'`는 `DebugMinSdkCheck`에서 실패했다. 설치된 Flutter의 최소 요구조건은 23이다. 지원 기기 변경 없이 완료할 수 없어 원래 SDK/의존성 조합 복원 또는 지원 버전 변경 결정이 남아 있다. 검증 우회는 하지 않았다.
- 첫 Kotlin daemon 오류는 C: 패키지 캐시와 D: 프로젝트 사이 경로 변환 문제였으며 fallback으로 컴파일했다. 최종 직접 검증에서는 호출 인자로 증분 컴파일을 끄고 SDK 요구조건 실패를 확인했다. 불필요 생성 캐시는 정리했다.

## API 21 후속 조사 결과

- 공식 Flutter 3.32.8 태그의 minSdk 21 선언을 확인했지만, 현재 지도 플러그인 1.4.4의 minSdk 23 및 후보 SDK의 정확한 테스트 패키지 버전과 현재 lock의 차이 때문에 SDK 단독 고정을 채택하지 않았다.
- 실제 확인한 것은 공식 SDK 소스·공식 릴리스 설명·현재 Pub 캐시의 잠긴 지도 패키지 Gradle 선언·현재 lock 값이다. 후보 SDK 설치, 후보 lock solve, 이전 지도 플러그인 설치, API 21 APK 실행은 하지 않았다.
- 기존 API 21 지원을 보존하는 SDK/지도 플러그인의 동반 교체는 별도 범위로 남긴다. 대규모 다운로드·다운그레이드, 전역 Flutter 변경, SDK 검증 우회 없음.
- `git diff -- pubspec.lock pubspec.yaml android/app/build.gradle.kts .github/workflows/ci.yml .github/workflows/release.yml`: 변경 없음. 기존 테스트 결과를 이번 문서만 변경한 조사에 대해 불필요하게 재실행하지 않았다.
- 이번 조사 완료와 원래 API 21 APK 빌드의 차단 상태는 구분한다. 빌드 차단을 해결했다고 표시하지 않는다.
