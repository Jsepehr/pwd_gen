import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/rendering.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
import '/core/utility.dart';
import '/domain/pwd_entity.dart';
import '/view/widgets/shared/app_dialog.dart';

/// Thrown when a `.kmg` file can't be parsed: truncated, the wrong format
/// version, or any length field pointing outside the file's actual bytes.
/// Kept distinct from a wrong-image failure so the caller can show the
/// right message, and always caught before it reaches the UI.
class CorruptedVaultFileException implements Exception {
  const CorruptedVaultFileException();
}

class BinaryEncrypt {
  /// Bumped from the original unversioned/CBC format. v2 uses PBKDF2 (salted,
  /// stretched) key derivation and AES-GCM (authenticated) encryption instead
  /// of a bare SHA-256 key + AES-CBC + a hardcoded "magic word" check.
  static const int _formatVersion = 2;
  static const int _pbkdf2Iterations = 150000;
  static const int _saltLength = 16;
  static const int _ivLength = 16;

  static encrypt.Key _deriveKey(String keyword, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, 32));
    final keyBytes = derivator.process(Uint8List.fromList(utf8.encode(keyword)));
    return encrypt.Key(keyBytes);
  }

  static Future<void> saveBinaryEncryptedFile(
      {required List<PwdEntity> passwords, required String imageHash}) async {
    final keyword = json.encode(imageHash);
    final jsonData = jsonEncode(passwords.map((e) => e.toMap()).toList());

    final salt = Uint8List.fromList(encrypt.IV.fromSecureRandom(_saltLength).bytes);
    final userKey = _deriveKey(keyword, salt);

    final aesKey = encrypt.Key.fromSecureRandom(32);
    final dataIv = encrypt.IV.fromSecureRandom(_ivLength);
    final dataEncrypter =
        encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.gcm));
    final encryptedData =
        dataEncrypter.encrypt(jsonData, iv: dataIv, associatedData: salt);

    final keyIv = encrypt.IV.fromSecureRandom(_ivLength);
    final keyEncrypter =
        encrypt.Encrypter(encrypt.AES(userKey, mode: encrypt.AESMode.gcm));
    final encryptedAesKey =
        keyEncrypter.encryptBytes(aesKey.bytes, iv: keyIv, associatedData: salt);

    final buffer = BytesBuilder();
    buffer.addByte(_formatVersion);
    buffer.add(_intToBytes(salt.length));
    buffer.add(salt);
    buffer.add(keyIv.bytes);
    buffer.add(_intToBytes(encryptedAesKey.bytes.length));
    buffer.add(encryptedAesKey.bytes);
    buffer.add(dataIv.bytes);
    buffer.add(_intToBytes(encryptedData.bytes.length));
    buffer.add(encryptedData.bytes);

    final output = buffer.toBytes();
    final directory = await AppSharedPreferences.loadSavedDirectory();
    final dir = Directory(directory!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final fileName = await AppSharedPreferences.loadSavedFileName();

    final result = "${dir.path}/$fileName";

    final file = File(result);
    try {
      final f =
          await file.writeAsBytes(output, flush: false, mode: FileMode.write);
      debugPrint(f.path);

      KeymageState.applyState(KeymageStateEnums.fileGenSuccess);
    } catch (e) {
      debugPrint('$e');
      KeymageState.applyState(KeymageStateEnums.somethingWentWrong);
    }
  }

  static Future<List<PwdEntity>> readFileAndValidateHash({
    required File file,
    required String imageHash,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      var offset = 0;

      int readVersion() {
        _ensureBounds(bytes, offset, 1);
        final v = bytes[offset];
        offset += 1;
        return v;
      }

      int readLength() {
        _ensureBounds(bytes, offset, 4);
        final v =
            ByteData.sublistView(bytes, offset, offset + 4).getInt32(0, Endian.big);
        offset += 4;
        if (v < 0) throw const CorruptedVaultFileException();
        return v;
      }

      Uint8List readBytes(int length) {
        _ensureBounds(bytes, offset, length);
        final v = Uint8List.sublistView(bytes, offset, offset + length);
        offset += length;
        return v;
      }

      if (readVersion() != _formatVersion) {
        throw const CorruptedVaultFileException();
      }

      final salt = readBytes(readLength());
      final keyIv = encrypt.IV(readBytes(_ivLength));
      final encryptedAesKeyBytes = readBytes(readLength());
      final dataIv = encrypt.IV(readBytes(_ivLength));
      final encryptedDataBytes = readBytes(readLength());

      final keyword = json.encode(imageHash);
      final userKey = _deriveKey(keyword, salt);
      final keyEncrypter =
          encrypt.Encrypter(encrypt.AES(userKey, mode: encrypt.AESMode.gcm));

      late List<int> aesKeyBytes;
      try {
        aesKeyBytes = keyEncrypter.decryptBytes(
          encrypt.Encrypted(encryptedAesKeyBytes),
          iv: keyIv,
          associatedData: salt,
        );
      } catch (_) {
        // Wrong image (or tampered file): the derived key doesn't match, so
        // the GCM auth tag on the wrapped key fails to verify.
        KeymageState.applyState(KeymageStateEnums.wrongImageSelected);
        return [];
      }

      final aesKey = encrypt.Key(Uint8List.fromList(aesKeyBytes));
      final dataEncrypter =
          encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.gcm));

      late String decryptedJson;
      try {
        decryptedJson = dataEncrypter.decrypt(
          encrypt.Encrypted(encryptedDataBytes),
          iv: dataIv,
          associatedData: salt,
        );
      } catch (_) {
        // Right image, but the data blob itself failed its auth tag — the
        // file was truncated or tampered with after export.
        KeymageState.applyState(KeymageStateEnums.corruptedFile);
        return [];
      }

      final List decoded = jsonDecode(decryptedJson);
      return decoded.map((e) => PwdEntity.fromMap(e)).toList();
    } catch (_) {
      // Catch-all safety net: any truncated/malformed/malicious file (e.g.
      // any arbitrary file renamed to `.kmg`, since the file picker only
      // filters by extension) must never crash the app.
      KeymageState.applyState(KeymageStateEnums.corruptedFile);
      return [];
    }
  }

  static void _ensureBounds(Uint8List bytes, int offset, int length) {
    if (length < 0 || offset + length > bytes.length) {
      throw const CorruptedVaultFileException();
    }
  }

  static List<int> _intToBytes(int value) {
    final byteData = ByteData(4);
    byteData.setInt32(0, value, Endian.big);
    return byteData.buffer.asUint8List();
  }
}
