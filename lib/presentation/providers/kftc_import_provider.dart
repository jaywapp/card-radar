import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:card_radar/core/kftc_card_matcher.dart';
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
  final _repo = KftcRepository();
  String _pendingState = '';

  KftcImportNotifier(this._ref) : super(const KftcImportState());

  Future<void> startOAuth() async {
    _pendingState = DateTime.now().millisecondsSinceEpoch.toString();
    final uri = _repo.buildAuthUri(_pendingState);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      state = state.copyWith(
        status: KftcImportStatus.error,
        message: '브라우저를 열 수 없습니다',
      );
      return;
    }
    state = state.copyWith(status: KftcImportStatus.waitingCallback);
  }

  Future<void> handleAuthCode(String code, String returnedState) async {
    if (returnedState.isNotEmpty && returnedState != _pendingState) {
      state = state.copyWith(
        status: KftcImportStatus.error,
        message: '보안 오류: state 불일치',
      );
      return;
    }

    state = state.copyWith(status: KftcImportStatus.loading);
    try {
      final token = await _repo.exchangeCode(code);
      final cardNames = await _repo.fetchCardNames(token);
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

  void handleError(String error) {
    state = state.copyWith(
      status: KftcImportStatus.error,
      message: '인증 실패: $error',
    );
  }

  void reset() => state = const KftcImportState();
}

final kftcImportProvider =
    StateNotifierProvider<KftcImportNotifier, KftcImportState>(
  (ref) => KftcImportNotifier(ref),
);
