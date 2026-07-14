import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/core/kftc_public_config.dart';

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

  Future<List<String>> fetchCardNamesForCode(String code) async {
    final response = await Supabase.instance.client.functions.invoke(
      'kftc-import',
      body: {'code': code},
    );
    final data = response.data;
    if (response.status != 200 || data is! Map<String, dynamic>) {
      throw Exception('카드 정보를 불러오지 못했습니다');
    }
    final names = data['card_names'];
    if (names is! List<dynamic>) {
      throw Exception('카드 정보 응답 형식이 올바르지 않습니다');
    }
    return names.whereType<String>().where((name) => name.isNotEmpty).toList();
  }
}
