import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:card_radar/data/repositories/user_card_repository.dart';

void main() {
  late UserCardRepository repo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox<String>('test_user_cards');
    await box.clear();
    repo = UserCardRepository(box: box);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('초기 상태는 빈 목록', () {
    expect(repo.cardIds, isEmpty);
  });

  test('카드 추가 후 목록에 포함됨', () async {
    await repo.addCard('shinhan-deep-dream');
    expect(repo.cardIds, contains('shinhan-deep-dream'));
  });

  test('카드 제거 후 목록에서 사라짐', () async {
    await repo.addCard('shinhan-deep-dream');
    await repo.removeCard('shinhan-deep-dream');
    expect(repo.cardIds, isNot(contains('shinhan-deep-dream')));
  });

  test('중복 추가 시 하나만 유지', () async {
    await repo.addCard('shinhan-deep-dream');
    await repo.addCard('shinhan-deep-dream');
    expect(repo.cardIds.where((id) => id == 'shinhan-deep-dream').length, 1);
  });
}
