import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pwd_gen/core/notepass_encrypt.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kmg_test');
    SharedPreferences.setMockInitialValues({
      keyUserPrefPath: tempDir.path,
      keyUserPrefFileName: 'test_export.kmg',
    });
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  final pwds = [
    PwdEntity(id: '1', hint: 'email', password: 'Sup3rSecret!', usageDate: '0'),
    PwdEntity(id: '2', hint: 'bank', password: 'AnotherOne#42', usageDate: '0'),
  ];

  test('round-trip: same image hash decrypts the saved vault', () async {
    const imageHash = 'fake-hash-of-the-secret-image';
    await BinaryEncrypt.saveBinaryEncryptedFile(
        passwords: pwds, imageHash: imageHash);

    final file = File('${tempDir.path}/test_export.kmg');
    expect(await file.exists(), isTrue);

    final result = await BinaryEncrypt.readFileAndValidateHash(
      file: file,
      imageHash: imageHash,
    );

    expect(result, equals(pwds));
  });

  test('wrong image hash fails to decrypt instead of returning garbage',
      () async {
    const imageHash = 'fake-hash-of-the-secret-image';
    await BinaryEncrypt.saveBinaryEncryptedFile(
        passwords: pwds, imageHash: imageHash);

    final file = File('${tempDir.path}/test_export.kmg');
    final result = await BinaryEncrypt.readFileAndValidateHash(
      file: file,
      imageHash: 'a-completely-different-hash',
    );

    expect(result, isEmpty);
  });

  test('a garbage file with a .kmg-like content never crashes the app',
      () async {
    final garbageFile = File('${tempDir.path}/garbage.kmg');
    await garbageFile.writeAsBytes(
        Uint8List.fromList(List.generate(37, (i) => i * 7 % 256)));

    // Must complete normally (returning an empty list), never throw.
    final result = await BinaryEncrypt.readFileAndValidateHash(
      file: garbageFile,
      imageHash: 'whatever',
    );
    expect(result, isEmpty);
  });

  test('a file with a bogus huge length prefix never crashes the app',
      () async {
    final maliciousFile = File('${tempDir.path}/malicious.kmg');
    final bytes = BytesBuilder();
    bytes.addByte(2); // correct version marker
    bytes.add([0x7f, 0xff, 0xff, 0xff]); // saltLength = huge int32
    await maliciousFile.writeAsBytes(bytes.toBytes());

    final result = await BinaryEncrypt.readFileAndValidateHash(
      file: maliciousFile,
      imageHash: 'whatever',
    );
    expect(result, isEmpty);
  });

  test('an empty file never crashes the app', () async {
    final emptyFile = File('${tempDir.path}/empty.kmg');
    await emptyFile.writeAsBytes(<int>[]);

    final result = await BinaryEncrypt.readFileAndValidateHash(
      file: emptyFile,
      imageHash: 'whatever',
    );
    expect(result, isEmpty);
  });
}
