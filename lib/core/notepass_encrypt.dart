import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/rendering.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';

class BinaryEncrypt {
  static const String _magicWord = 'VALID_KEY';

  static encrypt.Key deriveKey(String keyword) {
    final hash = sha256.convert(utf8.encode(keyword));
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  static Future<void> saveBinaryEncryptedFile(
      {required List<PwdEntity> passwords, required String imageHash}) async {
    final keyword = json.encode(imageHash);
    final jsonData = jsonEncode(passwords.map((e) => e.toMap()).toList());

    final aesKey = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final encryptedData = encrypter.encrypt(jsonData, iv: iv);

    final userKey = deriveKey(keyword);
    final keyEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
    final encryptedAesKey = keyEncrypter.encryptBytes(aesKey.bytes, iv: iv);

    final encryptedMagic = keyEncrypter.encrypt(_magicWord, iv: iv);

    final buffer = BytesBuilder();
    buffer.add(iv.bytes);
    buffer.add(_intToBytes(encryptedData.bytes.length));
    buffer.add(encryptedData.bytes);
    buffer.add(_intToBytes(encryptedAesKey.bytes.length));
    buffer.add(encryptedAesKey.bytes);
    buffer.add(_intToBytes(encryptedMagic.bytes.length));
    buffer.add(encryptedMagic.bytes);
    final imageHashBytes = utf8.encode(imageHash);
    buffer.add(_intToBytes(imageHashBytes.length));
    buffer.add(imageHashBytes);

    final output = buffer.toBytes();
    final directory = await loadSavedDirectory();
    final dir = Directory(directory!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final fileName = await loadSavedFileName();

    final result = "${dir.path}/$fileName";

    final file = File(result);
    try {
      final f =
          await file.writeAsBytes(output, flush: false, mode: FileMode.write);
      debugPrint(f.path);

      MPGState.applyState(MPGStateEnums.fileGenSuccess);
    } catch (e) {
      debugPrint('$e');
      MPGState.applyState(MPGStateEnums.somethingWentWrong);
    }
  }

  static Future<List<PwdEntity>> readFileAndValidateHash({
    required File file,
    required String imageHash,
  }) async {
    MPGState.applyState(MPGStateEnums.ok);
    final bytes = await file.readAsBytes();
    final byteData = ByteData.sublistView(bytes);
    int offset = 0;

    // 1. Read IV
    final iv = encrypt.IV(bytes.sublist(offset, offset + 16));
    offset += 16;

    // 2. Read encrypted data
    final dataLength = byteData.getInt32(offset, Endian.big);
    offset += 4;
    final encryptedDataBytes = bytes.sublist(offset, offset + dataLength);
    offset += dataLength;

    // 3. Read encrypted AES key
    final encKeyLength = byteData.getInt32(offset, Endian.big);
    offset += 4;
    final encryptedAesKeyBytes = bytes.sublist(offset, offset + encKeyLength);
    offset += encKeyLength;

    // 4. Read encrypted magic word
    int magicLength = byteData.getInt32(offset, Endian.big);

    offset += 4;
    final encryptedMagicBytes = bytes.sublist(offset, offset + magicLength);
    offset += magicLength;

    // 5. Read saved image hash (plaintext)
    final hashLength = byteData.getInt32(offset, Endian.big);
    offset += 4;
    final savedHashBytes = bytes.sublist(offset, offset + hashLength);
    final savedImageHash = utf8.decode(savedHashBytes);

    // 6. Compare hashes
    if (savedImageHash != imageHash) {
      MPGState.applyState(MPGStateEnums.wrongImageSelected);
      return [];
    }

    // 7. Derive key and decrypt
    final keyword = json.encode(imageHash); // same as when saving
    final userKey = deriveKey(keyword);
    final keyEncrypter = encrypt.Encrypter(encrypt.AES(userKey));

    // 8. Validate magic word
    final decryptedMagic = keyEncrypter.decrypt(
      encrypt.Encrypted(encryptedMagicBytes),
      iv: iv,
    );
    if (decryptedMagic != _magicWord) {
      MPGState.applyState(MPGStateEnums.corruptedFile);
      return [];
    }

    // 9. Decrypt AES key
    final encryptedAesKey = encrypt.Encrypted(encryptedAesKeyBytes);
    final decryptedAesKey = keyEncrypter.decryptBytes(encryptedAesKey, iv: iv);
    final aesKey = encrypt.Key(Uint8List.fromList(decryptedAesKey));

    // 10. Decrypt actual data
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final decryptedJson = encrypter.decrypt(
      encrypt.Encrypted(encryptedDataBytes),
      iv: iv,
    );

    final List decoded = jsonDecode(decryptedJson);
    return decoded.map((e) => PwdEntity.fromMap(e)).toList();
  }

  static List<int> _intToBytes(int value) {
    final byteData = ByteData(4);
    byteData.setInt32(0, value, Endian.big);
    return byteData.buffer.asUint8List();
  }
}
