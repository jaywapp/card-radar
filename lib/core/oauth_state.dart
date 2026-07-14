import 'dart:convert';
import 'dart:math';

String generateOAuthState() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

bool isValidOAuthState({required String expected, required String returned}) {
  return expected.isNotEmpty && returned.isNotEmpty && expected == returned;
}
