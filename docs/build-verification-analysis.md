# 빌드 및 기능 검증 분석

orchestrator: Codex

사용자는 실패한 빌드 해결, 기존 동작 기준 테스트 누락 보강, 실제 실행 검증 순서로 진행하도록 승인했다. 현재 작업 브랜치는 codex/workspace-environment-20260904이며 이전 변경은 커밋된 깨끗한 상태다.

분석 결과: 로컬에 gitignored kftc_config.dart가 없어 분석이 실패한다. CI는 해당 파일을 별도로 생성하며 예제 파일도 이미 존재한다. 로컬 설정 준비 절차를 재현 가능하게 문서화하고 실제 비밀 값을 사용하지 않는 환경 변수 기반 예제를 제공한다. 기존 CI 설정 생성 및 실제 설정 파일의 인터페이스는 유지한다.

기존 widget_test.dart는 expect(true)만 실행한다. KFTC HTTP·응답 파싱·인증 state 검증에도 테스트가 없다. 정상 응답과 오류·빈 값·권한 실패를 HTTP 대역으로 검증하고, 임시 Hive 저장소를 사용해 실제 화면 기능을 검증한다. 실제 금융 API·사용자 카드 데이터·운영 계정은 사용하지 않는다.

실제 화면 회귀 테스트에서 카드 삭제 후 저장값은 비었지만 체크박스가 계속 선택된 상태로 남는 결함을 재현했다. 내 카드 화면이 카드 상태를 구독하지 않던 원인이므로 구독과 선택 ID 집합으로 바로잡는다. 딥링크 스트림의 플랫폼 오류도 처리 경계가 없어 오류 로그만 남기고 앱을 유지하도록 보강한다.

## 후속: Android API 21 호환 SDK 조사

사용자는 기존 변경의 커밋·푸시 후 API 21 지원을 유지하는 호환 SDK/lock 가능성 조사를 승인했다. 전역 Flutter 변경, 지원 OS 상향, 근거 없는 대규모 의존성 다운그레이드는 금지한다. 기존 후속 변경은 2693146으로 푸시했고 원격 HEAD 일치를 확인했다.

확인한 제약은 SDK와 지도 플러그인 두 계층이다.

- 현재 CI와 release workflow는 Flutter 3.41.9를 고정하고 `pub get --enforce-lockfile`을 실행한다. 로컬 SDK 기본 minSdk는 24이며 직접 Gradle 검증은 프로젝트 21이 Flutter 검사 최소값 23보다 낮아 실패했다.
- 공식 [Flutter 3.35 발표](https://flutter.dev/blog/whats-new-in-flutter-3-35)는 Android 기본 최소 SDK 변경을 설명한다. [Flutter 3.32.8 태그 소스](https://github.com/flutter/flutter/blob/3.32.8/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt)는 minSdk 21을 선언하므로 조사 후보가 될 근거가 있다. 이것만으로 현재 프로젝트 호환성을 입증하지는 않는다.
- 현재 잠긴 `flutter_naver_map 1.4.4`의 배포 패키지 `android/build.gradle`은 `minSdkVersion 23`, `compileSdk 36`, 네이티브 `com.naver.maps:map-sdk:3.23.0`을 선언한다. 확인 위치는 로컬 Pub 캐시의 해당 버전 소스다. Flutter만 낮춰도 현재 지도 플러그인으로 API 21을 지원할 수 없다.
- 현재 lock의 Dart 하한은 `>=3.9.0-0`이고 설치 Flutter SDK 패키지도 같은 하한을 선언한다. 후보 SDK는 [flutter_test의 정확한 버전 고정](https://github.com/flutter/flutter/blob/3.32.8/packages/flutter_test/pubspec.yaml)부터 현재 lock과 다르다. `test_api 0.7.10 → 0.7.4`, `vector_math 2.2.0 → 2.1.4`, `meta 1.17.0 → 1.16.0`, `leak_tracker 11.0.2 → 10.0.9`가 그 예다.

결정: 현 lock을 보존하면서 SDK만 고정하는 해결은 성립하지 않는다. SDK·지도 플러그인·SDK 내장 테스트 패키지를 함께 바꾸고 지도 및 API 21 기기 회귀까지 검증해야 하므로 별도 호환성 작업으로 남긴다. 이번 조사에서 전체 호환 조합을 검증한 근거는 없으므로 후보 버전을 운영 설정으로 채택하지 않는다.
