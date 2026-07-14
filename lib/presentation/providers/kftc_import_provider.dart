import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:card_radar/core/kftc_card_matcher.dart';
import 'package:card_radar/core/kftc_public_config.dart';
import 'package:card_radar/core/oauth_state.dart';
import 'package:card_radar/data/repositories/kftc_repository.dart';
import 'package:card_radar/presentation/providers/user_cards_provider.dart';

enum KftcImportStatus { idle, waitingCallback, loading, success, error }

class KftcImportState {
  final KftcImportStatus status;
  final String? message;
  final int importedCount;

  const KftcImportState({
    this.status = KftcImportStatus.idle,
    this.message,
    this.importedCount = 0,
  });

  KftcImportState copyWith({
    KftcImportStatus? status,
    String? message,
    int? importedCount,
  }) =>
      KftcImportState(
        status: status ?? this.status,
        message: message ?? this.message,
        importedCount: importedCount ?? this.importedCount,
      );
}

class KftcImportNotifier extends StateNotifier<KftcImportState> {
  final Ref _ref;
  final Box<String> _oauthStateBox;
  final _repo = KftcRepository();
  static const _oauthStateKey = 'kftc_pending_state';

  KftcImportNotifier(this._ref, this._oauthStateBox)
      : super(const KftcImportState());

  Future<void> startOAuth() async {
    if (!kftcConfigured) {
      state = state.copyWith(
        status: KftcImportStatus.error,
        message: '오픈뱅킹 설정이 필요합니다',
      );
      return;
    }

    final pendingState = generateOAuthState();
    await _oauthStateBox.put(_oauthStateKey, pendingState);
    final uri = _repo.buildAuthUri(pendingState);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await _oauthStateBox.delete(_oauthStateKey);
      state = state.copyWith(
        status: KftcImportStatus.error,
        message: '브라우저를 열 수 없습니다',
      );
      return;
    }
    state = state.copyWith(status: KftcImportStatus.waitingCallback);
  }

  Future<void> handleAuthCode(String code, String returnedState) async {
    final expectedState = _oauthStateBox.get(_oauthStateKey) ?? '';
    if (!isValidOAuthState(expected: expectedState, returned: returnedState)) {
      await _oauthStateBox.delete(_oauthStateKey);
      state = state.copyWith(
        status: KftcImportStatus.error,
        message: '보안 오류: state 불일치',
      );
      return;
    }
    await _oauthStateBox.delete(_oauthStateKey);

    state = state.copyWith(status: KftcImportStatus.loading);
    try {
      final cardNames = await _repo.fetchCardNamesForCode(code);
      final matchedIds = matchCardIds(cardNames);

      final notifier = _ref.read(userCardsProvider.notifier);
      for (final id in matchedIds) {
        await notifier.addCard(id);
      }

      state = state.copyWith(
        status: KftcImportStatus.success,
        importedCount: matchedIds.length,
        message: matchedIds.isEmpty
            ? '매핑된 카드가 없습니다 (${cardNames.length}개 조회됨)'
            : '${matchedIds.length}개 카드를 불러왔습니다',
      );
    } catch (e) {
      state = state.copyWith(
        status: KftcImportStatus.error,
        message: e.toString(),
      );
    }
  }

  Future<void> handleError(String error) async {
    await _oauthStateBox.delete(_oauthStateKey);
    state = state.copyWith(
      status: KftcImportStatus.error,
      message: '인증 실패: $error',
    );
  }

  void reset() => state = const KftcImportState();
}

final kftcImportProvider =
    StateNotifierProvider<KftcImportNotifier, KftcImportState>(
  (ref) => KftcImportNotifier(ref, Hive.box<String>('oauth_state')),
);
