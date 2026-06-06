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
  // 신규 카드
  'deep oil':       'shinhan-deep-oil',
  'hyundai z':      'hyundai-z',
  '현대카드z':       'hyundai-z',
  '현대 z':         'hyundai-z',
  'hyundai x':      'hyundai-x',
  '현대카드x':       'hyundai-x',
  '현대 x':         'hyundai-x',
  'we:sh':          'kb-my-wesh',
  'wesh':           'kb-my-wesh',
  '알뜰교통':        'kb-altteu',
  'id on':          'samsung-id-on',
  '삼성카드 4':     'samsung-4',
  'loca 365':       'lotte-loca365',
  'loca365':        'lotte-loca365',
  '정석 point':     'woori-point',
  'woori point':    'woori-point',
  '정석 money':     'woori-money',
  'woori money':    'woori-money',
  'viva x':         'hana-viva-x',
  'viva w':         'hana-viva-w',
  '채움':            'nh-chaeeum',
  '바로이지':        'bc-baro-ez',
  'baro ez':        'bc-baro-ez',
  '카카오뱅크':      'kakao-check',
  'kakaobank':      'kakao-check',
  '토스뱅크':        'toss-check',
  'tossbank':       'toss-check',
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
