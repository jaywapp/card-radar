import 'package:card_radar/app.dart';
import 'package:card_radar/data/models/card.dart' as model;
import 'package:card_radar/data/models/card_benefit.dart';
import 'package:card_radar/data/models/category.dart';
import 'package:card_radar/presentation/providers/all_cards_provider.dart';
import 'package:card_radar/presentation/providers/benefits_provider.dart';
import 'package:card_radar/presentation/router.dart';
import 'package:card_radar/presentation/widgets/card_rank_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const _cards = [
  model.Card(id: 'fixture-alpha', name: 'Alpha Card', issuer: 'Fixture A'),
  model.Card(id: 'fixture-beta', name: 'Beta Card', issuer: 'Fixture B'),
];
const _benefits = [
  CardBenefit(
    cardId: 'fixture-alpha',
    category: CardCategory.cafe,
    benefitType: 'cashback',
    rate: 5,
  ),
];

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const links = MethodChannel('com.llfbandit.app_links/events');
  late Box<String> box;

  setUp(() async {
    box = await Hive.openBox<String>('user_cards', bytes: Uint8List(0));
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      links,
      (_) async => null,
    );
  });
  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(links, null);
    await Hive.close();
  });

  Future<void> mount(WidgetTester tester, {bool failCards = false}) async {
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    appRouter.go('/home');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allCardsProvider.overrideWith((ref) async {
            if (failCards) throw StateError('fixture unavailable');
            return _cards;
          }),
          benefitsProvider.overrideWith((ref) async => _benefits),
        ],
        child: const CardRadarApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'onboarding, search and card removal persist through real screens',
    (tester) async {
      await mount(tester);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '시작하기'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Alpha Card'));
      await tester.pumpAndSettle();
      expect(box.get('card_ids'), 'fixture-alpha');
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();
      expect(find.text('1개 카드 등록됨'), findsOneWidget);
      await tester.tap(find.byTooltip('내 카드 관리'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  no matching card  ');
      await tester.pump();
      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.text('Alpha Card'));
      await tester.pumpAndSettle();
      expect(box.get('card_ids'), '');
      final row = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Alpha Card'),
      );
      expect(row.value, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('stored cards open home and category ranking with real routing', (
    tester,
  ) async {
    await box.put('card_ids', 'fixture-alpha');
    await mount(tester);
    expect(find.text('1개 카드 등록됨'), findsOneWidget);
    await tester.tap(find.text('카페'));
    await tester.pumpAndSettle();
    final ranking = tester.widget<CardRankItem>(find.byType(CardRankItem));
    expect(ranking.rankedCard.card.id, 'fixture-alpha');
    expect(ranking.rank, 1);
    expect(find.text('1개 카드 기준'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('card loading failures keep onboarding safe and disabled', (
    tester,
  ) async {
    await mount(tester, failCards: true);
    expect(find.text('카드 목록을 불러올 수 없습니다'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '시작하기'))
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('platform link errors do not terminate the running app', (
    tester,
  ) async {
    await mount(tester);
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      links.name,
      const StandardMethodCodec().encodeErrorEnvelope(
        code: 'fixture_permission_denied',
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('👋 보유 카드를 선택해 주세요'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
