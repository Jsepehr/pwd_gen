import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pwd_gen/core/notepass_encrypt.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';

const _channel = MethodChannel('com.example.pwd_gen/vault_export');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  Uint8List? capturedBytes;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kmg_test');
    capturedBytes = null;
    // Stand in for MainActivity.kt's handler, which isn't reachable from a
    // plain `flutter test` run — just capture the bytes it would have
    // written to MediaStore/Downloads.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      if (call.method == 'saveKmgFile') {
        capturedBytes = call.arguments['bytes'] as Uint8List;
        return 'ok';
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
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
    final status = await BinaryEncrypt.saveBinaryEncryptedFile(
      passwords: pwds,
      imageHash: imageHash,
      fileName: 'test_export.kmg',
    );
    expect(status, 'ok');
    expect(capturedBytes, isNotNull);

    final file = File('${tempDir.path}/test_export.kmg');
    await file.writeAsBytes(capturedBytes!);

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
      passwords: pwds,
      imageHash: imageHash,
      fileName: 'test_export.kmg',
    );

    final file = File('${tempDir.path}/test_export.kmg');
    await file.writeAsBytes(capturedBytes!);

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
