import 'package:flutter_test/flutter_test.dart';
import 'package:card_radar/core/kftc_card_matcher.dart';

void main() {
  group('matchCardIds', () {
    test('알려진 카드명을 ID로 변환한다', () {
      expect(matchCardIds(['Deep Dream']), contains('shinhan-deep-dream'));
    });

    test('대소문자를 무시한다', () {
      expect(matchCardIds(['deep dream']), contains('shinhan-deep-dream'));
    });

    test('미등록 카드명은 결과에서 제외된다', () {
      expect(matchCardIds(['존재하지않는카드XYZ']), isEmpty);
    });

    test('빈 입력은 빈 결과를 반환한다', () {
      expect(matchCardIds([]), isEmpty);
    });

    test('중복 카드명은 ID를 중복 생성하지 않는다', () {
      final ids = matchCardIds(['Deep Dream', 'Deep Dream']);
      expect(ids.where((id) => id == 'shinhan-deep-dream').length, 1);
    });
  });
}
