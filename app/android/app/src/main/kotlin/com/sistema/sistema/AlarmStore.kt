package com.sistema.sistema

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

/**
 * Будильник-квест (SPEC §8.11): хранилище запланированных срабатываний и звонящего будильника
 * (SharedPreferences "sistema_alarm") + постановка в AlarmManager.setAlarmClock.
 * Список хранится, чтобы снять старые и перепланировать после перезагрузки (AlarmBootReceiver).
 */
object AlarmStore {
    private const val TAG = "AlarmStore"
    private const val PREFS = "sistema_alarm"
    private const val KEY_ENTRIES = "entries"
    private const val KEY_LABELS = "labels"
    private const val KEY_RINGING_ID = "ringing_id"
    private const val KEY_RINGING_AT = "ringing_at"
    private const val KEY_RINGING_TITLE = "ringing_title"
    private const val KEY_RINGING_BODY = "ringing_body"

    const val ACTION_RING = "com.sistema.sistema.alarm.RING"
    const val EXTRA_KEY = "sistema_alarm_key"
    const val EXTRA_ID = "sistema_alarm_id"
    const val EXTRA_TITLE = "sistema_alarm_title"
    const val EXTRA_BODY = "sistema_alarm_body"

    data class Entry(val key: String, val id: String, val atMs: Long, val title: String, val body: String) {
        fun toJson(): JSONObject = JSONObject()
            .put("key", key).put("id", id).put("atMs", atMs).put("title", title).put("body", body)

        companion object {
            fun fromMap(m: Map<*, *>): Entry? {
                val key = m["key"] as? String ?: return null
                val id = m["id"] as? String ?: return null
                val at = (m["atMs"] as? Number)?.toLong() ?: return null
                return Entry(key, id, at, m["title"] as? String ?: "", m["body"] as? String ?: "")
            }

            fun fromJson(o: JSONObject): Entry? {
                val key = o.optString("key", "")
                val id = o.optString("id", "")
                if (key.isEmpty() || id.isEmpty()) return null
                return Entry(key, id, o.optLong("atMs", 0L), o.optString("title", ""), o.optString("body", ""))
            }
        }
    }

    private fun prefs(ctx: Context) = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun canExact(ctx: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val am = ctx.getSystemService(AlarmManager::class.java) ?: return false
        return am.canScheduleExactAlarms()
    }

    // ---- Подписи для уведомления сервиса (из Dart) ----

    fun saveLabels(ctx: Context, labels: Map<*, *>?) {
        if (labels == null) return
        val o = JSONObject()
        for ((k, v) in labels) if (k is String && v is String) o.put(k, v)
        prefs(ctx).edit().putString(KEY_LABELS, o.toString()).apply()
    }

    fun label(ctx: Context, key: String, fallback: String): String {
        val raw = prefs(ctx).getString(KEY_LABELS, null) ?: return fallback
        return try {
            JSONObject(raw).optString(key, fallback).ifEmpty { fallback }
        } catch (e: Exception) {
            fallback
        }
    }

    // ---- Планирование ----

    private fun loadEntries(ctx: Context): List<Entry> {
        val raw = prefs(ctx).getString(KEY_ENTRIES, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { Entry.fromJson(arr.getJSONObject(it)) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun saveEntries(ctx: Context, entries: List<Entry>) {
        val arr = JSONArray()
        entries.forEach { arr.put(it.toJson()) }
        prefs(ctx).edit().putString(KEY_ENTRIES, arr.toString()).apply()
    }

    private fun ringIntent(ctx: Context, e: Entry): PendingIntent {
        val i = Intent(ctx, AlarmReceiver::class.java)
            .setAction(ACTION_RING)
            .setData(Uri.parse("sistema-alarm://ring/" + Uri.encode(e.key)))
            .putExtra(EXTRA_KEY, e.key)
            .putExtra(EXTRA_ID, e.id)
            .putExtra(EXTRA_TITLE, e.title)
            .putExtra(EXTRA_BODY, e.body)
        return PendingIntent.getBroadcast(
            ctx, e.key.hashCode(), i, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun showIntent(ctx: Context): PendingIntent? {
        val launch = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName) ?: return null
        return PendingIntent.getActivity(
            ctx, 7301, launch, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun set(ctx: Context, am: AlarmManager, e: Entry): Boolean {
        val op = ringIntent(ctx, e)
        try {
            if (canExact(ctx)) {
                am.setAlarmClock(AlarmManager.AlarmClockInfo(e.atMs, showIntent(ctx)), op)
                return true
            }
        } catch (se: SecurityException) {
            Log.w(TAG, "setAlarmClock denied: $se")
        }
        // Нет разрешения на точные — неточный (может опоздать на минуты).
        am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, e.atMs, op)
        return false
    }

    /** Снять прежние и поставить [entries]. true — все точные. */
    fun schedule(ctx: Context, entries: List<Entry>): Boolean {
        val am = ctx.getSystemService(AlarmManager::class.java) ?: return false
        cancelAll(ctx)
        val now = System.currentTimeMillis()
        val future = entries.filter { it.atMs > now }.distinctBy { it.key }
        var exact = true
        for (e in future) exact = set(ctx, am, e) && exact
        saveEntries(ctx, future)
        return exact
    }

    fun cancelAll(ctx: Context) {
        val am = ctx.getSystemService(AlarmManager::class.java) ?: return
        for (e in loadEntries(ctx)) {
            try {
                am.cancel(ringIntent(ctx, e))
            } catch (ex: Exception) {
                Log.w(TAG, "cancel: $ex")
            }
        }
        saveEntries(ctx, emptyList())
    }

    /** После перезагрузки / обновления: заново поставить будущие срабатывания. */
    fun reschedule(ctx: Context) {
        val am = ctx.getSystemService(AlarmManager::class.java) ?: return
        val now = System.currentTimeMillis()
        val future = loadEntries(ctx).filter { it.atMs > now }
        for (e in future) set(ctx, am, e)
        saveEntries(ctx, future)
    }

    fun removeEntry(ctx: Context, key: String) {
        saveEntries(ctx, loadEntries(ctx).filter { it.key != key })
    }

    // ---- Звонящий будильник ----

    fun setRinging(ctx: Context, id: String, atMs: Long, title: String, body: String) {
        prefs(ctx).edit()
            .putString(KEY_RINGING_ID, id)
            .putLong(KEY_RINGING_AT, atMs)
            .putString(KEY_RINGING_TITLE, title)
            .putString(KEY_RINGING_BODY, body)
            .apply()
    }

    fun ringingId(ctx: Context): String? = prefs(ctx).getString(KEY_RINGING_ID, null)

    fun ringing(ctx: Context): Map<String, Any>? {
        val p = prefs(ctx)
        val id = p.getString(KEY_RINGING_ID, null) ?: return null
        return mapOf("id" to id, "firedAtMs" to p.getLong(KEY_RINGING_AT, System.currentTimeMillis()))
    }

    fun ringingTitle(ctx: Context): String = prefs(ctx).getString(KEY_RINGING_TITLE, "") ?: ""
    fun ringingBody(ctx: Context): String = prefs(ctx).getString(KEY_RINGING_BODY, "") ?: ""

    fun clearRinging(ctx: Context) {
        prefs(ctx).edit()
            .remove(KEY_RINGING_ID).remove(KEY_RINGING_AT).remove(KEY_RINGING_TITLE).remove(KEY_RINGING_BODY)
            .apply()
    }
}
