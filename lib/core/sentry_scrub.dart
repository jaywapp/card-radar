import 'package:sentry_flutter/sentry_flutter.dart';

/// PII 차단 키워드 (소문자 부분일치).
/// 공통 규칙 4의 금지 필드: 카드번호·카드명, 아동 이름·생년월일, 전화번호, 비밀번호, 토큰
const sentrySensitiveKeywords = [
  // 카드
  'card_number', 'cardnumber', 'card_name', 'cardname', 'card_no',
  // 아동 이름·생년월일
  'child_name', 'childname', 'baby_name', 'babyname',
  'birth', 'birthdate', 'birthday', 'date_of_birth', 'dob',
  // 전화번호
  'phone', 'tel', 'mobile',
  // 비밀번호·토큰
  'password', 'passwd', 'pwd', 'pin',
  'token', 'access_token', 'refresh_token', 'authorization',
  'secret', 'api_key', 'apikey',
];

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return sentrySensitiveKeywords.any(lower.contains);
}

/// Map에서 민감 키 제거 (breadcrumb.data / extra 공용 헬퍼)
void _scrubMap(Map<String, dynamic>? data) {
  data?.removeWhere((key, _) => _isSensitiveKey(key));
}

/// beforeSend 콜백: user 제거 + breadcrumbs/extra 민감 필드 필터링
SentryEvent? scrubSentryEvent(SentryEvent event, Hint hint) {
  // 1) user 제거 — v9는 mutable이므로 직접 대입.
  //    (copyWith(user: null)은 user가 유지되므로 사용하면 안 됨)
  event.user = null;

  // 2) breadcrumbs 필터링: data의 민감 키 제거, message에 키워드 포함 시 마스킹
  final breadcrumbs = event.breadcrumbs;
  if (breadcrumbs != null) {
    for (final crumb in breadcrumbs) {
      _scrubMap(crumb.data);
      final message = crumb.message;
      if (message != null && _isSensitiveKey(message)) {
        crumb.message = '[Filtered]';
      }
    }
  }

  // 3) extra 필터링 (extra는 v9에서 deprecated지만 기존 코드 호환을 위해 방어)
  // ignore: deprecated_member_use
  _scrubMap(event.extra);

  return event;
}
