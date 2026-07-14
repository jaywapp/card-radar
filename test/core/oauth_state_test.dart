import 'package:flutter_test/flutter_test.dart';
import 'package:card_radar/core/oauth_state.dart';

void main() {
  group('OAuth state', () {
    test('generates a non-empty URL-safe random value', () {
      final state = generateOAuthState();

      expect(state, isNotEmpty);
      expect(state, matches(RegExp(r'^[A-Za-z0-9_-]+$')));
    });

    test('accepts only an exact non-empty match', () {
      expect(isValidOAuthState(expected: 'state', returned: 'state'), isTrue);
      expect(isValidOAuthState(expected: 'state', returned: ''), isFalse);
      expect(isValidOAuthState(expected: '', returned: 'state'), isFalse);
      expect(isValidOAuthState(expected: 'state', returned: 'other'), isFalse);
    });
  });
}
