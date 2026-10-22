package com.sistema.sistema

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject
import java.time.Instant
import java.time.ZoneId

/**
 * Расписание блокировки и очередь попыток (SharedPreferences "sistema_blocker").
 * Окно [fromMs, untilMs); при repeatDaily истёкшее окно переносится на сутки вперёд (по местному времени),
 * пока Dart не вызовет clear (режим дисциплины выключен).
 */
data class BlockerScheduleData(
    val appIds: Set<String>,
    val fromMs: Long,
    val untilMs: Long,
    val texts: Map<String, String>,
    val repeatDaily: Boolean,
) {
    fun text(key: String, fallback: String): String = texts[key]?.takeIf { it.isNotBlank() } ?: fallback

    /** Текущее или ближайшее окно на момент [now]; null — окно прошло и не повторяется. */
    fun effectiveWindow(now: Long): Pair<Long, Long>? {
        if (now < untilMs) return fromMs to untilMs
        if (!repeatDaily) return null
        val zone = ZoneId.systemDefault()
        var from = Instant.ofEpochMilli(fromMs).atZone(zone)
        var until = Instant.ofEpochMilli(untilMs).atZone(zone)
        var guard = 0
        while (until.toInstant().toEpochMilli() <= now && guard < 400) {
            from = from.plusDays(1)
            until = until.plusDays(1)
            guard++
        }
        return from.toInstant().toEpochMilli() to until.toInstant().toEpochMilli()
    }
}

object BlockerSchedule {
    private const val PREFS = "sistema_blocker"
    private const val KEY_SCHEDULE = "schedule"
    private const val KEY_ATTEMPTS = "attempts"
    private const val MAX_ATTEMPTS = 500

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    @Synchronized
    fun save(
        context: Context,
        appIds: List<String>,
        fromMs: Long,
        untilMs: Long,
        texts: Map<String, String>,
        repeatDaily: Boolean,
    ) {
        val json = JSONObject()
            .put("appIds", JSONArray(appIds))
            .put("fromMs", fromMs)
            .put("untilMs", untilMs)
            .put("texts", JSONObject(texts))
            .put("repeatDaily", repeatDaily)
        prefs(context).edit().putString(KEY_SCHEDULE, json.toString()).commit()
    }

    @Synchronized
    fun clear(context: Context) {
        prefs(context).edit().remove(KEY_SCHEDULE).commit()
    }

    @Synchronized
    fun load(context: Context): BlockerScheduleData? {
        val raw = prefs(context).getString(KEY_SCHEDULE, null) ?: return null
        return try {
            val json = JSONObject(raw)
            val ids = HashSet<String>()
            val arr = json.optJSONArray("appIds") ?: JSONArray()
            for (i in 0 until arr.length()) {
                val id = arr.optString(i, "")
                if (id.isNotEmpty()) ids.add(id)
            }
            val texts = HashMap<String, String>()
            val t = json.optJSONObject("texts")
            if (t != null) {
                val keys = t.keys()
                while (keys.hasNext()) {
                    val k = keys.next()
                    texts[k] = t.optString(k, "")
                }
            }
            BlockerScheduleData(
                appIds = ids,
                fromMs = json.getLong("fromMs"),
                untilMs = json.getLong("untilMs"),
                texts = texts,
                repeatDaily = json.optBoolean("repeatDaily", true),
            )
        } catch (e: Exception) {
            null
        }
    }

    @Synchronized
    fun addAttempt(context: Context, appId: String, at: Long) {
        val p = prefs(context)
        val arr = try {
            JSONArray(p.getString(KEY_ATTEMPTS, "[]"))
        } catch (e: Exception) {
            JSONArray()
        }
        arr.put(JSONObject().put("appId", appId).put("at", at))
        // Очередь не растёт бесконечно, если Dart долго не забирает.
        val trimmed = if (arr.length() > MAX_ATTEMPTS) {
            val out = JSONArray()
            for (i in arr.length() - MAX_ATTEMPTS until arr.length()) out.put(arr.get(i))
            out
        } else arr
        p.edit().putString(KEY_ATTEMPTS, trimmed.toString()).commit()
    }

    @Synchronized
    fun drainAttempts(context: Context): List<Map<String, Any>> {
        val p = prefs(context)
        val raw = p.getString(KEY_ATTEMPTS, null) ?: return emptyList()
        p.edit().remove(KEY_ATTEMPTS).commit()
        return try {
            val arr = JSONArray(raw)
            val out = ArrayList<Map<String, Any>>(arr.length())
            for (i in 0 until arr.length()) {
                val o = arr.optJSONObject(i) ?: continue
                val app = o.optString("appId", "")
                val at = o.optLong("at", 0L)
                if (app.isNotEmpty() && at > 0L) out.add(mapOf("appId" to app, "at" to at))
            }
            out
        } catch (e: Exception) {
            emptyList()
        }
    }
}
