import 'package:card_radar/core/kftc_config.dart';
import 'package:card_radar/core/sample_data.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/kftc_import_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hive_ce/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('authorized import persists cards and rejects callback replay', () async {
    final container = ProviderContainer(
      overrides: [allCardsProvider.overrideWith((ref) async => sampleCards)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(kftcImportProvider.notifier);
    if (kftcClientId.isEmpty || kftcClientSecret.isEmpty) {
      await notifier.startOAuth();
      expect(container.read(kftcImportProvider).status, KftcImportStatus.error);
      return;
    }
    final box = await Hive.openBox<String>('user_cards', bytes: Uint8List(0));
    addTearDown(Hive.close);
    await container.read(allCardsProvider.future);
    const launcher = MethodChannel('plugins.flutter.io/url_launcher');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    String? pendingState;
    messenger.setMockMethodCallHandler(launcher, (call) async {
      pendingState = Uri.parse(
        call.arguments['url'] as String,
      ).queryParameters['state'];
      return true;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(launcher, null));
    var requests = 0;
    await http.runWithClient(
      () async {
        await notifier.startOAuth();
        expect(
          container.read(kftcImportProvider).status,
          KftcImportStatus.waitingCallback,
        );
        expect(pendingState, isNotEmpty);
        await notifier.handleAuthCode('fixture-code', 'wrong-state');
        expect(requests, 0);
        await notifier.handleAuthCode('fixture-code', pendingState!);
        expect(
          container.read(kftcImportProvider).status,
          KftcImportStatus.success,
        );
        expect(container.read(kftcImportProvider).importedCount, 1);
        expect(box.get('card_ids'), 'shinhan-deep-dream');
        expect(requests, 2);
        await notifier.handleAuthCode('fixture-code', pendingState!);
        expect(
          container.read(kftcImportProvider).status,
          KftcImportStatus.error,
        );
        expect(requests, 2);
      },
      () => MockClient((request) async {
        requests++;
        return http.Response(
          request.method == 'POST'
              ? '{"access_token":"fixture-token","user_seq_no":"fixture-user"}'
              : '{"card_list":[{"card_nm":"Deep Dream"}]}',
          200,
        );
      }),
    );
  });

  test(
    'unsolicited and empty-state callbacks fail before making HTTP requests',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var requests = 0;
      await http.runWithClient(
        () async {
          final notifier = container.read(kftcImportProvider.notifier);
          for (final returnedState in ['', 'unrequested-state']) {
            await notifier.handleAuthCode('fixture-code', returnedState);
            final state = container.read(kftcImportProvider);
            expect(state.status, KftcImportStatus.error);
            expect(state.message, '보안 오류: state 불일치');
            expect(requests, 0);
            notifier.reset();
            expect(
              container.read(kftcImportProvider).status,
              KftcImportStatus.idle,
            );
          }
        },
        () => MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
      );
    },
  );

  test(
    'authorization setup or platform failures become a recoverable state',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(kftcImportProvider.notifier).startOAuth();
      expect(container.read(kftcImportProvider).status, KftcImportStatus.error);
      container.read(kftcImportProvider.notifier).reset();
      expect(container.read(kftcImportProvider).status, KftcImportStatus.idle);
    },
  );
}
