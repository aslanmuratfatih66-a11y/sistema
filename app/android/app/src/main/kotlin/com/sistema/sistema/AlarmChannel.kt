package com.sistema.sistema

import android.app.Activity
import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Канал будильника-квеста "sistema/alarm" (SPEC §8.11). Контракт — app/lib/core/alarm/alarm_api.dart,
 * Dart-сторона — channel_alarm_scheduler.dart:
 *   isAvailable → Boolean (точные будильники + full-screen intent)
 *   permissionState → {available, exactAlarms, fullScreen}
 *   requestPermission → Boolean (открывает системный экран недостающего разрешения)
 *   schedule {entries: [{key, id, atMs, title, body}], labels: {doTask, channel, channelDesc}} → Boolean (все точные)
 *   cancelAll
 *   pendingRing → {id, firedAtMs} | null
 *   ringStart {id, title, body, labels} — звонить, пока открыт экран задания (если звонок не идёт)
 *   stop {id}
 * Из натива в Dart: onRing {id, firedAtMs}.
 * MainActivity: создать в configureFlutterEngine, из onNewIntent вызвать handleIntent(intent).
 */
class AlarmChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, NAME)
    private val context = activity.applicationContext

    /** Звонок, с которым запущена активность (если prefs уже очищены). Объявлен до init. */
    private var launchRing: Map<String, Any>? = null

    init {
        channel.setMethodCallHandler(::onCall)
        instance = this
        handleIntent(activity.intent, notify = false)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "isAvailable" -> result.success(isAvailable())
                "permissionState" -> result.success(
                    mapOf(
                        "available" to isAvailable(),
                        "exactAlarms" to AlarmStore.canExact(context),
                        "fullScreen" to canFullScreen()
                    )
                )
                "requestPermission" -> result.success(requestPermission())
                "schedule" -> {
                    AlarmStore.saveLabels(context, call.argument<Map<*, *>>("labels"))
                    val raw = call.argument<List<*>>("entries") ?: emptyList<Any>()
                    val entries = raw.mapNotNull { (it as? Map<*, *>)?.let { m -> AlarmStore.Entry.fromMap(m) } }
                    result.success(AlarmStore.schedule(context, entries))
                }
                "cancelAll" -> {
                    AlarmStore.cancelAll(context)
                    result.success(null)
                }
                "pendingRing" -> result.success(pendingRing())
                "ringStart" -> {
                    AlarmStore.saveLabels(context, call.argument<Map<*, *>>("labels"))
                    ringStart(
                        call.argument<String>("id") ?: "",
                        call.argument<String>("title") ?: "",
                        call.argument<String>("body") ?: ""
                    )
                    result.success(null)
                }
                "stop" -> {
                    stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e(TAG, "${call.method}: $e")
            result.error("alarm", e.message, null)
        }
    }

    private fun canFullScreen(): Boolean {
        if (Build.VERSION.SDK_INT < 34) return true
        val nm = context.getSystemService(NotificationManager::class.java) ?: return false
        return nm.canUseFullScreenIntent()
    }

    private fun isAvailable(): Boolean = AlarmStore.canExact(context) && canFullScreen()

    private fun requestPermission(): Boolean {
        val uri = Uri.parse("package:${context.packageName}")
        try {
            if (!AlarmStore.canExact(context) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                activity.startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, uri))
            } else if (!canFullScreen() && Build.VERSION.SDK_INT >= 34) {
                activity.startActivity(Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, uri))
            }
        } catch (e: Exception) {
            Log.w(TAG, "requestPermission: $e")
            try {
                activity.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, uri))
            } catch (e2: Exception) {
            }
        }
        return isAvailable()
    }

    private fun pendingRing(): Map<String, Any>? = AlarmStore.ringing(context) ?: launchRing

    private fun ringStart(id: String, title: String, body: String) {
        if (id.isEmpty()) return
        if (AlarmStore.ringingId(context) != id) {
            AlarmStore.setRinging(context, id, System.currentTimeMillis(), title, body)
        }
        showOverLockScreen(true)
        try {
            AlarmRingService.start(context, id, title, body)
        } catch (e: Exception) {
            Log.w(TAG, "ringStart: $e")
        }
    }

    private fun stop() {
        AlarmStore.clearRinging(context)
        launchRing = null
        AlarmRingService.stop(context)
        showOverLockScreen(false)
    }

    /** Запуск / возврат в MainActivity из full-screen intent или кнопки уведомления звонка. */
    fun handleIntent(intent: Intent?, notify: Boolean = true) {
        val i = intent ?: return
        if (i.action != AlarmRingService.ACTION_OPEN) return
        val id = i.getStringExtra(AlarmStore.EXTRA_ID) ?: return
        showOverLockScreen(true)
        val ring = AlarmStore.ringing(context)
            ?: mapOf("id" to id, "firedAtMs" to System.currentTimeMillis())
        launchRing = ring
        if (notify) channel.invokeMethod("onRing", ring)
    }

    @Suppress("DEPRECATION")
    private fun showOverLockScreen(on: Boolean) {
        activity.runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                activity.setShowWhenLocked(on)
                activity.setTurnScreenOn(on)
            } else {
                val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                if (on) activity.window.addFlags(flags) else activity.window.clearFlags(flags)
            }
            val keep = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            if (on) activity.window.addFlags(keep) else activity.window.clearFlags(keep)
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        if (instance === this) instance = null
    }

    companion object {
        private const val TAG = "AlarmChannel"
        const val NAME = "sistema/alarm"

        @Volatile
        private var instance: AlarmChannel? = null

        /** Звонок, пока приложение запущено (из AlarmReceiver). */
        fun notifyRing(id: String, atMs: Long) {
            val ch = instance ?: return
            Handler(Looper.getMainLooper()).post {
                try {
                    ch.channel.invokeMethod("onRing", mapOf("id" to id, "firedAtMs" to atMs))
                } catch (e: Exception) {
                    Log.w(TAG, "onRing: $e")
                }
            }
        }
    }
}
