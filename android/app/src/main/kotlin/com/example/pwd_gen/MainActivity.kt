package com.example.pwd_gen

import android.content.ContentUris
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.example.pwd_gen/vault_export"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveKmgFile") {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    if (fileName == null || bytes == null) {
                        result.error("BAD_ARGS", "fileName and bytes are required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        result.success(saveKmgFile(fileName, bytes))
                    } catch (e: Exception) {
                        result.error("WRITE_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    /**
     * Saves the backup into Downloads/Keymage. On Android 10+ this goes
     * through MediaStore, which needs no storage permission at all. Below
     * that, scoped storage doesn't apply yet, so it falls back to a direct
     * write gated on the classic WRITE_EXTERNAL_STORAGE permission — MUCH
     * narrower than MANAGE_EXTERNAL_STORAGE, which Play Store scrutinizes
     * heavily and this app has no real justification for.
     *
     * [fileName] is a fixed name (not timestamped): every export is meant to
     * replace the previous one, not pile up. MediaStore.insert() won't
     * overwrite an existing DISPLAY_NAME on its own — it silently renames the
     * new file instead — so any previous row with this name is deleted first.
     *
     * Returns "ok", or "permission_needed" if the caller should request
     * WRITE_EXTERNAL_STORAGE and retry (only possible pre-Android 10).
     */
    private fun saveKmgFile(fileName: String, bytes: ByteArray): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = applicationContext.contentResolver
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val relativePath = "Download/Keymage/"

            resolver.query(
                collection,
                arrayOf(MediaStore.Downloads._ID),
                "${MediaStore.Downloads.DISPLAY_NAME} = ? AND ${MediaStore.Downloads.RELATIVE_PATH} = ?",
                arrayOf(fileName, relativePath),
                null
            )?.use { cursor ->
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Downloads._ID)
                while (cursor.moveToNext()) {
                    val existingUri = ContentUris.withAppendedId(collection, cursor.getLong(idColumn))
                    resolver.delete(existingUri, null, null)
                }
            }

            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, "application/octet-stream")
                put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
            }
            val uri = resolver.insert(collection, values)
                ?: throw IOException("MediaStore insert failed")
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IOException("Could not open output stream for $uri")
            return "ok"
        }

        val granted = ContextCompat.checkSelfPermission(
            this, android.Manifest.permission.WRITE_EXTERNAL_STORAGE
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            return "permission_needed"
        }

        val dir = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            "Keymage"
        )
        if (!dir.exists()) dir.mkdirs()
        File(dir, fileName).writeBytes(bytes)
        return "ok"
    }
}
