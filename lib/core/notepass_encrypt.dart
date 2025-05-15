import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';

class BinaryEncryptor {
  static const String _magicWord = 'VALID_KEY';

  static encrypt.Key deriveKey(String keyword) {
    final hash = sha256.convert(utf8.encode(keyword));
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  static Future<void> saveBinaryEncryptedFile({
    required List<PwdEntity> passwords,
    required String filename,
  }) async {
    final keyword = json.encode(await getImageHashes());
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

    final output = buffer.toBytes();

    final dir = Directory('/storage/emulated/0/Download/Notepass');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/$filename.nps');
    await file.writeAsBytes(output, flush: true);
  }

  static Future<List<PwdEntity>> readBinaryEncryptedFile({
    required String keyword,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    final byteData = ByteData.sublistView(bytes);
    int offset = 0;

    final iv = encrypt.IV(bytes.sublist(offset, offset + 16));
    offset += 16;

    final dataLength = byteData.getInt32(offset, Endian.big);
    offset += 4;
    final encryptedDataBytes = bytes.sublist(offset, offset + dataLength);
    offset += dataLength;

    final encKeyLength = byteData.getInt32(offset, Endian.big);
    offset += 4;
    final encryptedAesKeyBytes = bytes.sublist(offset, offset + encKeyLength);
    offset += encKeyLength;

    final magicLength = byteData.getInt32(offset, Endian.big);
    offset += 4;
    final encryptedMagicBytes = bytes.sublist(offset, offset + magicLength);

    final userKey = deriveKey(keyword);
    final keyEncrypter = encrypt.Encrypter(encrypt.AES(userKey));

    // Verify keyword by decrypting magic word
    try {
      final decryptedMagic = keyEncrypter.decrypt(
        encrypt.Encrypted(encryptedMagicBytes),
        iv: iv,
      );

      if (decryptedMagic != _magicWord) {
        PwdListResState.pwdListResponse = PwdListResponse.wrongImageSelected;
        return [];
      }
    } catch (_) {
      PwdListResState.pwdListResponse = PwdListResponse.somethingWentWrong;
      //throw Exception('Invalid keyword or corrupted file (magic check failed)');
    }

    // Decrypt AES key
    final aesKey = encrypt.Key.fromBase64(
      keyEncrypter.decrypt64(base64Encode(encryptedAesKeyBytes), iv: iv),
    );

    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey));
    final decrypted = encrypter.decrypt(
      encrypt.Encrypted(encryptedDataBytes),
      iv: iv,
    );

    final List decoded = jsonDecode(decrypted);
    PwdListResState.pwdListResponse = PwdListResponse.pwdsGeneratedSuccess;
    return decoded.map((e) => PwdEntity.fromMap(e)).toList();
  }

  static List<int> _intToBytes(int value) {
    final byteData = ByteData(4);
    byteData.setInt32(0, value, Endian.big);
    return byteData.buffer.asUint8List();
  }
}
