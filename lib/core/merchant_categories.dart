import 'package:card_radar/data/models/category.dart';

const Map<String, CardCategory> merchantCategoryMap = {
  // 편의점
  'gs25': CardCategory.convenience,
  'cu': CardCategory.convenience,
  '씨유': CardCategory.convenience,
  '세븐일레븐': CardCategory.convenience,
  '7eleven': CardCategory.convenience,
  '이마트24': CardCategory.convenience,
  'ministop': CardCategory.convenience,
  '미니스톱': CardCategory.convenience,

  // 카페
  '스타벅스': CardCategory.cafe,
  '투썸플레이스': CardCategory.cafe,
  '이디야': CardCategory.cafe,
  '메가커피': CardCategory.cafe,
  '컴포즈커피': CardCategory.cafe,
  '빽다방': CardCategory.cafe,
  '할리스': CardCategory.cafe,
  '파스쿠찌': CardCategory.cafe,
  '더벤티': CardCategory.cafe,
  '공차': CardCategory.cafe,
  '달콤커피': CardCategory.cafe,
  '블루보틀': CardCategory.cafe,
  '폴바셋': CardCategory.cafe,
  '커피빈': CardCategory.cafe,

  // 식당
  '맥도날드': CardCategory.restaurant,
  '버거킹': CardCategory.restaurant,
  '롯데리아': CardCategory.restaurant,
  'kfc': CardCategory.restaurant,
  '맘스터치': CardCategory.restaurant,
  '배달의민족': CardCategory.restaurant,
  '배민': CardCategory.restaurant,
  '요기요': CardCategory.restaurant,
  '쿠팡이츠': CardCategory.restaurant,
  'bbq': CardCategory.restaurant,
  '교촌치킨': CardCategory.restaurant,
  'bhc': CardCategory.restaurant,
  '피자헛': CardCategory.restaurant,
  '도미노피자': CardCategory.restaurant,
  '써브웨이': CardCategory.restaurant,
  '노브랜드버거': CardCategory.restaurant,
  '쉐이크쉑': CardCategory.restaurant,
  '파파이스': CardCategory.restaurant,
  '굽네치킨': CardCategory.restaurant,
  '네네치킨': CardCategory.restaurant,
  '호식이두마리치킨': CardCategory.restaurant,

  // 주유소
  'sk주유소': CardCategory.gasStation,
  'gs칼텍스': CardCategory.gasStation,
  '현대오일뱅크': CardCategory.gasStation,
  's-oil': CardCategory.gasStation,
  'soil': CardCategory.gasStation,
  '에쓰오일': CardCategory.gasStation,
  '알뜰주유소': CardCategory.gasStation,
  '주유소': CardCategory.gasStation,

  // 대중교통
  '지하철': CardCategory.transit,
  '버스': CardCategory.transit,
  'ktx': CardCategory.transit,
  'srt': CardCategory.transit,
  '기차': CardCategory.transit,
  'korail': CardCategory.transit,
  '코레일': CardCategory.transit,
  '티머니': CardCategory.transit,
  '카카오택시': CardCategory.transit,
  '우티': CardCategory.transit,
  '타다': CardCategory.transit,

  // 온라인쇼핑
  '쿠팡': CardCategory.online,
  '네이버쇼핑': CardCategory.online,
  '11번가': CardCategory.online,
  'g마켓': CardCategory.online,
  '지마켓': CardCategory.online,
  '옥션': CardCategory.online,
  '위메프': CardCategory.online,
  '티몬': CardCategory.online,
  '마켓컬리': CardCategory.online,
  '오아시스마켓': CardCategory.online,
  'ssg닷컴': CardCategory.online,
  '롯데온': CardCategory.online,
  '무신사': CardCategory.online,
  '29cm': CardCategory.online,
  '인터파크': CardCategory.online,
  '카카오쇼핑': CardCategory.online,
  '토스쇼핑': CardCategory.online,

  // 마트
  '이마트': CardCategory.mart,
  '롯데마트': CardCategory.mart,
  '홈플러스': CardCategory.mart,
  '코스트코': CardCategory.mart,
  '트레이더스': CardCategory.mart,
  '노브랜드': CardCategory.mart,
  '이마트에브리데이': CardCategory.mart,
  '하나로마트': CardCategory.mart,

  // 약국/드럭스토어
  '올리브영': CardCategory.pharmacy,
  '약국': CardCategory.pharmacy,
  '드럭스토어': CardCategory.pharmacy,
  '랄라블라': CardCategory.pharmacy,
  '롭스': CardCategory.pharmacy,
  'cvs': CardCategory.pharmacy,
};

String? findMerchantKey(String query) {
  final lower = query.toLowerCase().trim();
  if (lower.isEmpty) return null;
  for (final entry in merchantCategoryMap.entries) {
    if (lower.contains(entry.key) || entry.key.contains(lower)) {
      return entry.key;
    }
  }
  return null;
}

CardCategory? findCategory(String query) {
  final lower = query.toLowerCase().trim();
  if (lower.isEmpty) return null;
  for (final entry in merchantCategoryMap.entries) {
    if (lower.contains(entry.key) || entry.key.contains(lower)) {
      return entry.value;
    }
  }
  return null;
}

List<MapEntry<String, CardCategory>> searchMerchants(String query) {
  final lower = query.toLowerCase().trim();
  if (lower.isEmpty) return [];
  return merchantCategoryMap.entries
      .where((e) => e.key.contains(lower) || lower.contains(e.key))
      .toList();
}
