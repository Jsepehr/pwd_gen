import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import '/core/media_store_writer.dart';
import '/core/utility.dart';
import '/domain/pwd_entity.dart';
import '/view/widgets/shared/app_dialog.dart';

const int _formatVersion = 2;
const int _pbkdf2Iterations = 150000;
const int _saltLength = 16;
const int _ivLength = 16;

encrypt.Key _deriveKey(String keyword, Uint8List salt) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, 32));
  final keyBytes = derivator.process(Uint8List.fromList(utf8.encode(keyword)));
  return encrypt.Key(keyBytes);
}

List<int> _intToBytes(int value) {
  final byteData = ByteData(4);
  byteData.setInt32(0, value, Endian.big);
  return byteData.buffer.asUint8List();
}

void _ensureBounds(Uint8List bytes, int offset, int length) {
  if (length < 0 || offset + length > bytes.length) {
    throw const CorruptedVaultFileException();
  }
}

/// Thrown when a `.kmg` file can't be parsed: truncated, the wrong format
/// version, or any length field pointing outside the file's actual bytes.
/// Kept distinct from a wrong-image failure so the caller can show the
/// right message, and always caught before it reaches the UI.
class CorruptedVaultFileException implements Exception {
  const CorruptedVaultFileException();
}

/// Runs entirely inside a background isolate (via [compute]) — PBKDF2 at
/// 150k iterations plus AES-GCM would otherwise block the UI thread for
/// several seconds on a slow device. Only primitive/sendable types cross
/// the isolate boundary, so this takes and returns maps/lists, not
/// [PwdEntity]/[File]/crypto objects.
Uint8List _encryptVaultIsolate(Map<String, dynamic> args) {
  final passwords = (args['passwords'] as List).cast<Map<String, dynamic>>();
  final imageHash = args['imageHash'] as String;

  final keyword = json.encode(imageHash);
  final jsonData = jsonEncode(passwords);

  final salt =
      Uint8List.fromList(encrypt.IV.fromSecureRandom(_saltLength).bytes);
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

  return buffer.toBytes();
}

/// Result codes returned by [_decryptVaultIsolate], since the custom
/// exception types thrown inside the isolate can't be relied on to survive
/// the trip back to the caller in exactly the same shape.
const _statusOk = 'ok';
const _statusWrongImage = 'wrongImage';
const _statusCorrupted = 'corrupted';

Map<String, dynamic> _decryptVaultIsolate(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final imageHash = args['imageHash'] as String;

  try {
    var offset = 0;

    int readVersion() {
      _ensureBounds(bytes, offset, 1);
      final v = bytes[offset];
      offset += 1;
      return v;
    }

    int readLength() {
      _ensureBounds(bytes, offset, 4);
      final v = ByteData.sublistView(bytes, offset, offset + 4)
          .getInt32(0, Endian.big);
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
      return {'status': _statusWrongImage};
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
      return {'status': _statusCorrupted};
    }

    final decoded = (jsonDecode(decryptedJson) as List)
        .cast<Map<String, dynamic>>();
    return {'status': _statusOk, 'passwords': decoded};
  } catch (_) {
    // Catch-all safety net: any truncated/malformed/malicious file (e.g.
    // any arbitrary file renamed to `.kmg`, since the file picker only
    // filters by extension) must never crash the app.
    return {'status': _statusCorrupted};
  }
}

class BinaryEncrypt {
  /// Saves straight into Downloads/Keymage via [MediaStoreWriter] — MediaStore
  /// on Android 10+ (no permission needed), or a direct write gated on the
  /// classic WRITE_EXTERNAL_STORAGE permission on older versions. Avoids
  /// MANAGE_EXTERNAL_STORAGE, which Google Play scrutinizes heavily and this
  /// app has no real justification for.
  ///
  /// Returns `"ok"`, `"permission_needed"` (caller should request storage
  /// permission and retry), or `"error"`.
  static Future<String> saveBinaryEncryptedFile({
    required List<PwdEntity> passwords,
    required String imageHash,
    required String fileName,
  }) async {
    final output = await compute(_encryptVaultIsolate, {
      'passwords': passwords.map((e) => e.toMap()).toList(),
      'imageHash': imageHash,
    });

    try {
      return await MediaStoreWriter.saveKmgFile(
        fileName: fileName,
        bytes: output,
      );
    } catch (e) {
      debugPrint('$e');
      return 'error';
    }
  }

  static Future<List<PwdEntity>> readFileAndValidateHash({
    required File file,
    required String imageHash,
  }) async {
    final bytes = await file.readAsBytes();
    final result = await compute(_decryptVaultIsolate, {
      'bytes': bytes,
      'imageHash': imageHash,
    });

    switch (result['status']) {
      case _statusWrongImage:
        KeymageState.applyState(KeymageStateEnums.wrongImageSelected);
        return [];
      case _statusCorrupted:
        KeymageState.applyState(KeymageStateEnums.corruptedFile);
        return [];
      default:
        final decoded =
            (result['passwords'] as List).cast<Map<String, dynamic>>();
        return decoded.map((e) => PwdEntity.fromMap(e)).toList();
    }
  }
}
