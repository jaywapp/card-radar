import 'dart:convert';
import 'package:card_radar/core/kftc_config.dart';
import 'package:card_radar/data/models/kftc_token.dart';
import 'package:card_radar/data/repositories/kftc_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _token = KftcToken(
  accessToken: 'fixture-token',
  userSeqNo: 'fixture-user',
);

void main() {
  final repo = KftcRepository();
  final configured = kftcClientId.isNotEmpty && kftcRedirectUri.isNotEmpty;
  final exchangeConfigured = configured && kftcClientSecret.isNotEmpty;

  Future<T> respond<T>(
    Future<T> Function() action,
    String body, {
    int status = 200,
  }) {
    return http.runWithClient(
      action,
      () => MockClient((_) async => http.Response(body, status)),
    );
  }

  test('token parsing preserves valid strings and rejects invalid fields', () {
    final token = KftcToken.fromJson({
      'access_token': 'fixture-token',
      'user_seq_no': 'fixture-user',
    });
    expect(token.accessToken, 'fixture-token');
    expect(token.userSeqNo, 'fixture-user');
    for (final value in [null, '', ' ', 12, [], {}]) {
      for (final field in ['access_token', 'user_seq_no']) {
        final input = <String, dynamic>{
          'access_token': 'fixture-token',
          'user_seq_no': 'fixture-user',
          field: value,
        };
        expect(() => KftcToken.fromJson(input), throwsFormatException);
      }
    }
  });

  test(
    'authorization preserves encoded state or rejects missing configuration',
    () {
      if (!configured) {
        expect(() => repo.buildAuthUri('fixture-state'), throwsStateError);
        return;
      }
      final uri = repo.buildAuthUri('state +/?');
      expect(uri.path, '/oauth/2.0/authorize');
      expect(uri.queryParameters['state'], 'state +/?');
      expect(uri.queryParameters['scope'], 'cardinfo');
      expect(() => repo.buildAuthUri(''), throwsArgumentError);
    },
  );

  test('code exchange preserves form request and token response', () async {
    var requests = 0;
    final result = http.runWithClient(
      () => repo.exchangeCode('fixture-code'),
      () => MockClient((request) async {
        requests++;
        expect(request.method, 'POST');
        expect(request.url.path, '/oauth/2.0/token');
        final form = Uri.splitQueryString(request.body);
        expect(form['grant_type'], 'authorization_code');
        expect(form['code'], 'fixture-code');
        expect(
          form.keys,
          containsAll(['client_id', 'client_secret', 'redirect_uri']),
        );
        return http.Response(
          jsonEncode({
            'access_token': 'fixture-token',
            'user_seq_no': 'fixture-user',
          }),
          200,
        );
      }),
    );
    if (!exchangeConfigured) {
      await expectLater(result, throwsStateError);
      expect(requests, 0);
    } else {
      expect((await result).accessToken, 'fixture-token');
      expect(requests, 1);
      await expectLater(repo.exchangeCode(' '), throwsArgumentError);
    }
  });

  test(
    'code exchange rejects HTTP and malformed responses without exposing bodies',
    () async {
      if (!exchangeConfigured) {
        await expectLater(repo.exchangeCode('fixture-code'), throwsStateError);
        return;
      }
      for (final status in [401, 403, 500]) {
        await expectLater(
          respond(
            () => repo.exchangeCode('fixture-code'),
            'private-response',
            status: status,
          ),
          throwsA(
            predicate(
              (error) =>
                  error.toString().contains('$status') &&
                  !error.toString().contains('private-response'),
            ),
          ),
        );
      }
      for (final body in [
        'private-response',
        'null',
        '[]',
        '{}',
        '{"access_token":1}',
      ]) {
        await expectLater(
          respond(() => repo.exchangeCode('fixture-code'), body),
          throwsA(
            isA<FormatException>().having((e) => e.source, 'source', isNull),
          ),
        );
      }
    },
  );

  test(
    'card requests preserve headers, order, duplicate names and missing names',
    () async {
      final names = await http.runWithClient(
        () => repo.fetchCardNames(_token),
        () => MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], 'Bearer fixture-token');
          expect(request.url.queryParameters['user_seq_no'], 'fixture-user');
          expect(
            request.url.queryParameters['bank_tran_id'],
            matches(r'^0001942900U\d{17}$'),
          );
          return http.Response(
            jsonEncode({
              'card_list': [
                {'card_nm': 'First'},
                {},
                {'card_nm': ''},
                {'card_nm': 'Second'},
                {'card_nm': 'First'},
              ],
            }),
            200,
          );
        }),
      );
      expect(names, ['First', 'Second', 'First']);
      for (final body in ['{}', '{"card_list":null}', '{"card_list":[]}']) {
        expect(await respond(() => repo.fetchCardNames(_token), body), isEmpty);
      }
    },
  );

  test(
    'card lookup rejects malformed lists and never exposes HTTP bodies',
    () async {
      for (final body in [
        'private-response',
        'null',
        '[]',
        '{"card_list":{}}',
        '{"card_list":[null]}',
        '{"card_list":[{"card_nm":42}]}',
      ]) {
        await expectLater(
          respond(() => repo.fetchCardNames(_token), body),
          throwsA(
            isA<FormatException>().having((e) => e.source, 'source', isNull),
          ),
        );
      }
      for (final status in [401, 403, 500]) {
        await expectLater(
          respond(
            () => repo.fetchCardNames(_token),
            'private-response',
            status: status,
          ),
          throwsA(
            predicate(
              (error) =>
                  error.toString().contains('$status') &&
                  !error.toString().contains('private-response'),
            ),
          ),
        );
      }
      await expectLater(
        repo.fetchCardNames(
          const KftcToken(accessToken: '', userSeqNo: 'user'),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repo.fetchCardNames(
          const KftcToken(accessToken: 'token', userSeqNo: ' '),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'network failures propagate instead of becoming an empty success',
    () async {
      await expectLater(
        http.runWithClient(
          () => repo.fetchCardNames(_token),
          () => MockClient(
            (_) async => throw http.ClientException('fixture failure'),
          ),
        ),
        throwsA(isA<http.ClientException>()),
      );
    },
  );
}
