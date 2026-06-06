/// KFTC card_nm → 앱 내부 card ID 매핑
const Map<String, String> _kftcNameToId = {
  'deep dream':    'shinhan-deep-dream',
  's-line':        'shinhan-sline',
  'mr.life':       'shinhan-mrlife',
  'mrlife':        'shinhan-mrlife',
  'zero':          'hyundai-zero',
  'hyundai m':     'hyundai-m',
  'shopping':      'hyundai-shopping',
  '플렉스':         'kb-flex',
  'flex':          'kb-flex',
  '탄탄':           'kb-tantan',
  '노리':           'kb-nori',
  'taptap':        'samsung-taptap',
  'id simple':     'samsung-id-simple',
  'simple':        'samsung-id-simple',
  '삼성카드 7':     'samsung-7',
  'dc plus':       'lotte-dc-plus',
  'likit':         'lotte-likit',
  '다통장':         'woori-da',
  'da big':        'woori-da-big',
  '1q':            'hana-1q',
  '모아':           'hana-moa',
  '올바른flex':     'nh-all',
  'flex올바른':     'nh-all',
};

/// KFTC에서 받은 card_nm 목록을 앱 카드 ID로 변환
List<String> matchCardIds(List<String> kftcNames) {
  final result = <String>{};
  for (final name in kftcNames) {
    final lower = name.toLowerCase();
    for (final entry in _kftcNameToId.entries) {
      if (lower.contains(entry.key)) {
        result.add(entry.value);
        break;
      }
    }
  }
  return result.toList();
}
