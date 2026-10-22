package com.sistema.sistema

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Канал «персонаж поверх других приложений» (SPEC §9.2). Контракт —
 * app/lib/features/character/system_overlay_android.dart:
 *   hasPermission → Boolean
 *   requestPermission — открыть Settings.ACTION_MANAGE_OVERLAY_PERMISSION
 *   show {avatar: ByteArray?, texts: {notificationTitle, notificationBody, hideAction, avatarLabel}} → Boolean
 *   hide
 *   say {text, durationMs}
 *   setAvatar {avatar: ByteArray}
 * Окна — OverlayBubble, foreground service с уведомлением — OverlayService.
 */
class OverlayChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, NAME)
    private val context: Context = activity.applicationContext

    init {
        channel.setMethodCallHandler { call, result -> handle(call, result) }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "hasPermission" -> result.success(Settings.canDrawOverlays(context))
                "requestPermission" -> {
                    openPermissionSettings()
                    result.success(null)
                }
                "show" -> {
                    if (!Settings.canDrawOverlays(context)) {
                        result.success(false)
                        return
                    }
                    @Suppress("UNCHECKED_CAST")
                    val texts = (call.argument<Map<String, Any?>>("texts") ?: emptyMap())
                        .mapValues { it.value as? String ?: "" }
                    val avatar = decode(call.argument<ByteArray>("avatar"))
                    val shown = OverlayBubble.show(context, avatar, texts["avatarLabel"])
                    if (shown) OverlayService.start(context, texts)
                    result.success(shown)
                }
                "hide" -> {
                    OverlayBubble.hide()
                    OverlayService.stop(context)
                    result.success(null)
                }
                "say" -> {
                    val text = call.argument<String>("text") ?: ""
                    val ms = (call.argument<Any>("durationMs") as? Number)?.toLong() ?: 7000L
                    OverlayBubble.say(text, ms)
                    result.success(null)
                }
                "setAvatar" -> {
                    decode(call.argument<ByteArray>("avatar"))?.let { OverlayBubble.setAvatar(it) }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.w(TAG, "${call.method} failed", e)
            result.error("overlay", e.message, null)
        }
    }

    private fun decode(bytes: ByteArray?): Bitmap? =
        if (bytes == null || bytes.isEmpty()) null else BitmapFactory.decodeByteArray(bytes, 0, bytes.size)

    private fun openPermissionSettings() {
        val withPackage = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}"),
        )
        try {
            activity.startActivity(withPackage)
        } catch (e: ActivityNotFoundException) {
            try {
                activity.startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION))
            } catch (e2: ActivityNotFoundException) {
                Log.w(TAG, "overlay settings not found", e2)
            }
        }
    }

    private companion object {
        const val NAME = "sistema/overlay"
        const val TAG = "OverlayChannel"
    }
}
