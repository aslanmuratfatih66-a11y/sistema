package com.sistema.sistema

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Срабатывание setAlarmClock → звонящий будильник в prefs, AlarmRingService (звук + full-screen intent),
 * событие в Dart, если приложение запущено.
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != AlarmStore.ACTION_RING) return
        val id = intent.getStringExtra(AlarmStore.EXTRA_ID) ?: return
        val key = intent.getStringExtra(AlarmStore.EXTRA_KEY)
        val title = intent.getStringExtra(AlarmStore.EXTRA_TITLE) ?: ""
        val body = intent.getStringExtra(AlarmStore.EXTRA_BODY) ?: ""
        val now = System.currentTimeMillis()
        if (key != null) AlarmStore.removeEntry(context, key)
        AlarmStore.setRinging(context, id, now, title, body)
        try {
            AlarmRingService.start(context, id, title, body)
        } catch (e: Exception) {
            // Запуск foreground service из фона запрещён (не должно случаться для setAlarmClock).
            Log.e("AlarmReceiver", "start service: $e")
        }
        AlarmChannel.notifyRing(id, now)
    }
}

/** Перезагрузка / обновление приложения: AlarmManager забывает будильники — ставим заново из prefs. */
class AlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" -> AlarmStore.reschedule(context)
        }
    }
}
