import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:card_radar/core/kftc_config.dart';
import 'package:card_radar/data/models/kftc_token.dart';

class KftcRepository {
  Uri buildAuthUri(String state) {
    _requireConfiguration();
    if (state.isEmpty) throw ArgumentError('OAuth state is required');
    return Uri.parse('$kftcBaseUrl/oauth/2.0/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': kftcClientId,
        'redirect_uri': kftcRedirectUri,
        'scope': 'cardinfo',
        'state': state,
        'auth_type': '0',
      },
    );
  }

  Future<KftcToken> exchangeCode(String code) async {
    _requireConfiguration(requireSecret: true);
    if (code.trim().isEmpty) {
      throw ArgumentError('Authorization code is required');
    }
    final res = await http.post(
      Uri.parse('$kftcBaseUrl/oauth/2.0/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': kftcClientId,
        'client_secret': kftcClientSecret,
        'redirect_uri': kftcRedirectUri,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('토큰 교환 실패: ${res.statusCode}');
    }
    return KftcToken.fromJson(_decodeObject(res.body));
  }

  Future<List<String>> fetchCardNames(KftcToken token) async {
    if (token.accessToken.trim().isEmpty || token.userSeqNo.trim().isEmpty) {
      throw ArgumentError('A valid card access token is required');
    }
    final now = DateTime.now();
    final ts =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        '000';
    final bankTranId = '0001942900U$ts';

    final uri = Uri.parse('$kftcBaseUrl/v2.0/cards').replace(
      queryParameters: {
        'bank_tran_id': bankTranId,
        'user_seq_no': token.userSeqNo,
        'card_co_code': '999',
        'include_cancel_yn': 'N',
        'next_page_yn': 'N',
      },
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token.accessToken}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('카드 조회 실패: ${res.statusCode}');
    }

    final body = _decodeObject(res.body);
    final cards = body['card_list'] ?? [];
    if (cards is! List) {
      throw const FormatException('Invalid card list response');
    }
    final names = <String>[];
    for (final card in cards) {
      if (card is! Map<String, dynamic>) {
        throw const FormatException('Invalid card entry');
      }
      final name = card['card_nm'];
      if (name != null && name is! String) {
        throw const FormatException('Invalid card name');
      }
      if (name is String && name.isNotEmpty) names.add(name);
    }
    return names;
  }

  void _requireConfiguration({bool requireSecret = false}) {
    if (kftcClientId.trim().isEmpty ||
        !(Uri.tryParse(kftcRedirectUri)?.hasScheme ?? false) ||
        (requireSecret && kftcClientSecret.trim().isEmpty)) {
      throw StateError('카드 연동 설정이 필요합니다');
    }
  }

  Map<String, dynamic> _decodeObject(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Do not expose response bodies containing tokens or personal data.
    }
    throw const FormatException('Invalid card service response');
  }
}
