import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:card_radar/core/kftc_config.dart';
import 'package:card_radar/data/models/kftc_token.dart';

class KftcRepository {
  Uri buildAuthUri(String state) {
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
      throw Exception('토큰 교환 실패: ${res.statusCode} ${res.body}');
    }
    return KftcToken.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<String>> fetchCardNames(KftcToken token) async {
    final now = DateTime.now();
    final ts = '${now.year}'
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
      throw Exception('카드 조회 실패: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final cards = body['card_list'] as List<dynamic>? ?? [];
    return cards
        .map((c) => (c as Map<String, dynamic>)['card_nm'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
