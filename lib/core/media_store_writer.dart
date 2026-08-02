import 'package:flutter/services.dart';

/// Bridges to MainActivity.kt's `saveKmgFile`: writes the backup straight
/// into Downloads/Keymage via MediaStore on Android 10+ (no permission
/// needed), falling back to a direct write gated on WRITE_EXTERNAL_STORAGE
/// on older versions.
class MediaStoreWriter {
  static const _channel = MethodChannel('com.example.pwd_gen/vault_export');

  /// Returns `"ok"` on success, `"permission_needed"` if the caller should
  /// request storage permission and retry (only possible pre-Android 10).
  static Future<String> saveKmgFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final result = await _channel.invokeMethod<String>('saveKmgFile', {
      'fileName': fileName,
      'bytes': bytes,
    });
    return result ?? 'permission_needed';
  }
}
