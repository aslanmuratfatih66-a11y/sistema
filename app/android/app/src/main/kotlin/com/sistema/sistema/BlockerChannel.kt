package com.sistema.sistema

import android.app.Activity
import android.app.AppOpsManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

/**
 * Канал блокировки приложений (SPEC §8.6). Контракт — app/lib/domain/discipline/app_blocker_channel.dart:
 *   hasUsageAccess → Boolean
 *   openUsageAccessSettings
 *   canDrawOverlays → Boolean
 *   openOverlaySettings
 *   listLaunchableApps {icons: Boolean} → [{package, label, icon: ByteArray?}]
 *   setSchedule {appIds, fromMs, untilMs, texts{title, body, button, notificationTitle, notificationBody}, repeatDaily}
 *   clear
 *   status → {fromMs, untilMs, running, appCount}
 *   drainAttempts → [{appId, at}]
 * Сама проверка переднего плана и оверлей — BlockerService.
 */
class BlockerChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, NAME)
    private val context: Context = activity.applicationContext
    private val main = Handler(Looper.getMainLooper())
    private val io = Executors.newSingleThreadExecutor()

    init {
        channel.setMethodCallHandler { call, result -> handle(call, result) }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        io.shutdown()
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "hasUsageAccess" -> result.success(hasUsageAccess(context))
                "openUsageAccessSettings" -> {
                    openSettings(Settings.ACTION_USAGE_ACCESS_SETTINGS, withPackage = true)
                    result.success(null)
                }
                "canDrawOverlays" -> result.success(Settings.canDrawOverlays(context))
                "openOverlaySettings" -> {
                    openSettings(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, withPackage = true)
                    result.success(null)
                }
                "listLaunchableApps" -> {
                    val icons = call.argument<Boolean>("icons") ?: true
                    io.execute {
                        val apps = try {
                            listLaunchableApps(icons)
                        } catch (e: Exception) {
                            Log.w(TAG, "listLaunchableApps failed", e)
                            emptyList<Map<String, Any?>>()
                        }
                        main.post { result.success(apps) }
                    }
                }
                "setSchedule" -> {
                    val ids = (call.argument<List<Any?>>("appIds") ?: emptyList()).mapNotNull { it as? String }
                    val from = (call.argument<Any>("fromMs") as? Number)?.toLong()
                    val until = (call.argument<Any>("untilMs") as? Number)?.toLong()
                    if (from == null || until == null || until <= from) {
                        result.error("bad_args", "setSchedule: нужны fromMs < untilMs", null)
                        return
                    }
                    val texts = (call.argument<Map<String, Any?>>("texts") ?: emptyMap())
                        .mapValues { it.value as? String ?: "" }
                    val repeat = call.argument<Boolean>("repeatDaily") ?: true
                    BlockerSchedule.save(context, ids, from, until, texts, repeat)
                    BlockerService.applySchedule(context)
                    result.success(null)
                }
                "clear" -> {
                    BlockerSchedule.clear(context)
                    BlockerService.applySchedule(context)
                    result.success(null)
                }
                "status" -> {
                    val s = BlockerSchedule.load(context)
                    result.success(
                        mapOf(
                            "fromMs" to s?.fromMs,
                            "untilMs" to s?.untilMs,
                            "running" to BlockerService.running,
                            "appCount" to (s?.appIds?.size ?: 0),
                        )
                    )
                }
                "drainAttempts" -> result.success(BlockerSchedule.drainAttempts(context))
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.w(TAG, "${call.method} failed", e)
            result.error("blocker_error", e.message, null)
        }
    }

    private fun openSettings(action: String, withPackage: Boolean) {
        val uri = Uri.parse("package:${context.packageName}")
        val attempts = buildList {
            if (withPackage) add(Intent(action, uri))
            add(Intent(action))
            add(Intent(Settings.ACTION_SETTINGS))
        }
        for (intent in attempts) {
            try {
                activity.startActivity(intent)
                return
            } catch (e: ActivityNotFoundException) {
                // следующий вариант
            } catch (e: SecurityException) {
                // некоторые прошивки запрещают прямой переход
            }
        }
    }

    private fun listLaunchableApps(withIcons: Boolean): List<Map<String, Any?>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val infos = pm.queryIntentActivities(intent, 0)
        val seen = HashSet<String>()
        val out = ArrayList<Map<String, Any?>>()
        val size = (48 * context.resources.displayMetrics.density).toInt().coerceIn(48, 144)
        for (info in infos) {
            val pkg = info.activityInfo?.packageName ?: continue
            if (pkg == context.packageName || !seen.add(pkg)) continue
            val label = try {
                info.loadLabel(pm).toString() ?: pkg
            } catch (e: Exception) {
                pkg
            }
            val icon: ByteArray? = if (withIcons) {
                try {
                    iconPng(info.loadIcon(pm), size)
                } catch (e: Exception) {
                    null
                }
            } else null
            out.add(mapOf("package" to pkg, "label" to label, "icon" to icon))
        }
        return out
    }

    private fun iconPng(drawable: android.graphics.drawable.Drawable?, size: Int): ByteArray? {
        if (drawable == null) return null
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    companion object {
        const val NAME = "sistema/blocker"
        private const val TAG = "BlockerChannel"

        fun hasUsageAccess(context: Context): Boolean {
            val ops = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ops.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
            } else {
                @Suppress("DEPRECATION")
                ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
            }
            if (mode == AppOpsManager.MODE_DEFAULT) {
                return context.checkCallingOrSelfPermission(android.Manifest.permission.PACKAGE_USAGE_STATS) ==
                    android.content.pm.PackageManager.PERMISSION_GRANTED
            }
            return mode == AppOpsManager.MODE_ALLOWED
        }
    }
}
