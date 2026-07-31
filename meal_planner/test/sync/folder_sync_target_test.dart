import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/sync/folder_sync_target.dart';

void main() {
  late Directory tmpDir;
  late FolderSyncTarget target;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('meal_planner_folder_');
    target = FolderSyncTarget(tmpDir);
  });

  tearDown(() {
    if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
  });

  test('read returns null for a missing file', () async {
    expect(await target.read('recipes/nope.json'), isNull);
  });

  test('write creates parent directories', () async {
    await target.write('recipes/r1.json', '{"a":1}');
    expect(await target.read('recipes/r1.json'), '{"a":1}');
  });

  test('write leaves no temp file behind', () async {
    await target.write('recipes/r1.json', '{}');
    final names = Directory('${tmpDir.path}/recipes')
        .listSync()
        .map((f) => f.uri.pathSegments.last);
    expect(names, ['r1.json']);
  });

  test('write overwrites an existing file', () async {
    await target.write('recipes/r1.json', 'first');
    await target.write('recipes/r1.json', 'second');
    expect(await target.read('recipes/r1.json'), 'second');
  });

  test('list reports names with modification times', () async {
    await target.write('recipes/r1.json', '{}');

    final files = await target.list('recipes');
    expect(files.single.name, 'r1.json');
    expect(files.single.modified, isNotNull);
  });

  test('list of a missing directory is empty, not an error', () async {
    expect(await target.list('weeks'), isEmpty);
  });

  test('list ignores temp and backup files', () async {
    Directory('${tmpDir.path}/recipes').createSync(recursive: true);
    File('${tmpDir.path}/recipes/r1.json').writeAsStringSync('{}');
    File('${tmpDir.path}/recipes/r2.json.tmp').writeAsStringSync('{}');
    File('${tmpDir.path}/recipes/r3.json.backup').writeAsStringSync('{}');

    expect((await target.list('recipes')).map((f) => f.name), ['r1.json']);
  });

  test('delete removes the file and is a no-op when missing', () async {
    await target.write('recipes/r1.json', '{}');
    await target.delete('recipes/r1.json');
    expect(await target.read('recipes/r1.json'), isNull);
    await target.delete('recipes/r1.json');
  });

  test('an empty file reads as null', () async {
    await target.write('recipes/r1.json', '   ');
    expect(await target.read('recipes/r1.json'), isNull);
  });

  group('ping', () {
    test('succeeds on a writable folder and leaves nothing behind', () async {
      await target.ping();
      expect(tmpDir.listSync(), isEmpty);
    });

    test('fails when the folder does not exist', () async {
      final gone = FolderSyncTarget(Directory('${tmpDir.path}/missing'));
      expect(gone.ping(), throwsA(isA<FolderSyncException>()));
    });
  });
}
