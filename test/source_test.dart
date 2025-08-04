import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:midnight_v1/models/source.dart';

void main() {
  group('FileSource', () {
    late File testFile;
    late String testFilePath;
    late Uint8List testBytes;

    setUp(() async {
      testFilePath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}test_file.txt';
      testFile = File(testFilePath);
      testBytes = Uint8List.fromList('Hello, world!'.codeUnits);
      await testFile.writeAsBytes(testBytes);
    });

    tearDown(() async {
      if (await testFile.exists()) {
        await testFile.delete();
      }
    });

    test('toMap and toJson', () {
      final fileSource = FileSource(testFile);
      final map = fileSource.toMap();
      expect(map['path'], testFilePath.replaceAll('\\', '/'));
      final json = fileSource.toJson();
      expect(json, '{"path":"${testFilePath.replaceAll('\\', '/')}"}');
    });

    test('fromMap and fromJson', () {
      final map = {'path': testFilePath.replaceAll('\\', '/')};
      final fileSourceFromMap = FileSource.fromMap(map);
      expect(fileSourceFromMap.file.path, testFilePath);

      final json = '{"path":"${testFilePath.replaceAll('\\', '/')}"}';
      final fileSourceFromJson = FileSource.fromJson(json);
      expect(fileSourceFromJson.file.path, testFilePath);
    });

    test('fromBytesSync and toBytes', () {
      final fileSource = FileSource.fromBytesSync(testBytes);
      expect(fileSource.toBytes(), testBytes);
    });

    test('fromBytes and toBytesAsync', () async {
      final fileSource = await FileSource.fromBytes(testBytes);
      expect(await fileSource.toBytesAsync(), testBytes);
    });
  });
}
