package com.sistema.sistema

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

// Финансы (SPEC §8.7, Android): включённые источники (пакеты банковских приложений и SMS-отправители)
// и очередь входящих, пока Flutter не запущен. Хранится в SharedPreferences "sistema_bank".
object BankPrefs {
    private const val PREFS = "sistema_bank"
    private const val KEY_PACKAGES = "packages"
    private const val KEY_SENDERS = "senders"
    private const val KEY_QUEUE = "queue"
    private const val MAX_QUEUE = 500
    private const val MAX_BODY = 2000

    private val lock = Any()

    /** Живой получатель (EventChannel), если Flutter запущен; иначе событие только в очереди. */
    @Volatile
    var live: ((Map<String, Any?>) -> Unit)? = null

    private fun prefs(ctx: Context) = ctx.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun setSources(ctx: Context, packages: List<String>, senders: List<String>) {
        prefs(ctx).edit()
            .putStringSet(KEY_PACKAGES, packages.map { it.trim() }.filter { it.isNotEmpty() }.toSet())
            .putStringSet(KEY_SENDERS, senders.map { normSender(it) }.filter { it.isNotEmpty() }.toSet())
            .apply()
    }

    fun packages(ctx: Context): Set<String> = prefs(ctx).getStringSet(KEY_PACKAGES, emptySet()) ?: emptySet()

    fun senders(ctx: Context): Set<String> = prefs(ctx).getStringSet(KEY_SENDERS, emptySet()) ?: emptySet()

    /** Отправитель SMS: имя в нижнем регистре, номер — только цифры (без +7/8 различий не делаем). */
    fun normSender(s: String): String {
        val t = s.trim().lowercase()
        val digits = t.filter { it.isDigit() }
        return if (digits.isNotEmpty() && digits.length >= t.count { it.isLetterOrDigit() }) digits else t
    }

    fun senderEnabled(ctx: Context, sender: String?): Boolean {
        if (sender.isNullOrBlank()) return false
        val n = normSender(sender)
        val set = senders(ctx)
        if (set.contains(n)) return true
        // Номер может прийти как +7900… или 900…: сравниваем по хвосту.
        if (n.all { it.isDigit() } && n.length >= 4) return set.any { it.all(Char::isDigit) && it.length >= 4 && (n.endsWith(it) || it.endsWith(n)) }
        return false
    }

    fun enqueue(ctx: Context, channel: String, sender: String, body: String, receivedAt: Long) {
        val item = mapOf<String, Any?>(
            "channel" to channel,
            "sender" to sender,
            "body" to body.take(MAX_BODY),
            "receivedAt" to receivedAt,
        )
        synchronized(lock) {
            val arr = readQueue(ctx)
            // Дубль (то же уведомление обновилось) — не добавляем.
            for (i in 0 until arr.length()) {
                val o = arr.optJSONObject(i) ?: continue
                if (o.optString("sender") == sender && o.optString("body") == item["body"] &&
                    kotlin.math.abs(o.optLong("receivedAt") - receivedAt) < 120_000
                ) return
            }
            arr.put(JSONObject(item))
            val trimmed = if (arr.length() > MAX_QUEUE) {
                val out = JSONArray()
                for (i in arr.length() - MAX_QUEUE until arr.length()) out.put(arr.get(i))
                out
            } else arr
            prefs(ctx).edit().putString(KEY_QUEUE, trimmed.toString()).apply()
        }
        try {
            live?.invoke(item)
        } catch (_: Throwable) {
        }
    }

    /** Забирает и очищает очередь. */
    fun drain(ctx: Context): List<Map<String, Any?>> = synchronized(lock) {
        val arr = readQueue(ctx)
        prefs(ctx).edit().remove(KEY_QUEUE).apply()
        (0 until arr.length()).mapNotNull { i ->
            val o = arr.optJSONObject(i) ?: return@mapNotNull null
            mapOf(
                "channel" to o.optString("channel"),
                "sender" to o.optString("sender"),
                "body" to o.optString("body"),
                "receivedAt" to o.optLong("receivedAt"),
            )
        }
    }

    private fun readQueue(ctx: Context): JSONArray = try {
        JSONArray(prefs(ctx).getString(KEY_QUEUE, "[]") ?: "[]")
    } catch (_: Throwable) {
        JSONArray()
    }
}
