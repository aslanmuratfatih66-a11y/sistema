package com.sistema.sistema

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

// SMS банков (SPEC §8.7, Android, разрешение RECEIVE_SMS). Фильтр — отправители из BankPrefs.
class BankSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        try {
            val msgs = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
            // Длинное SMS приходит частями — склеиваем по отправителю.
            val bySender = LinkedHashMap<String, Pair<StringBuilder, Long>>()
            for (m in msgs) {
                val from = m?.originatingAddress ?: continue
                val e = bySender.getOrPut(from) { StringBuilder() to m.timestampMillis }
                e.first.append(m.messageBody ?: "")
            }
            for ((from, v) in bySender) {
                if (!BankPrefs.senderEnabled(context, from)) continue
                val ts = if (v.second > 0) v.second else System.currentTimeMillis()
                BankPrefs.enqueue(context, "sms", from, v.first.toString(), ts)
            }
        } catch (_: Throwable) {
        }
    }
}
