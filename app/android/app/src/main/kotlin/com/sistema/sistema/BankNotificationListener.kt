package com.sistema.sistema

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

// Уведомления банковских приложений (SPEC §8.7, Android, по разрешению «Доступ к уведомлениям»).
// Фильтр — пакеты из BankPrefs (их задаёт Dart через sistema/bank setSources). Входящие — в очередь BankPrefs.
class BankNotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val n = sbn ?: return
        try {
            val pkg = n.packageName ?: return
            if (!BankPrefs.packages(this).contains(pkg)) return
            val notif = n.notification ?: return
            if (notif.flags and Notification.FLAG_GROUP_SUMMARY != 0) return
            val ex = notif.extras ?: return
            val title = ex.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim().orEmpty()
            val text = (ex.getCharSequence(Notification.EXTRA_BIG_TEXT) ?: ex.getCharSequence(Notification.EXTRA_TEXT))
                ?.toString()?.trim().orEmpty()
            if (text.isEmpty() && title.isEmpty()) return
            val body = if (title.isNotEmpty() && !text.startsWith(title)) "$title\n$text" else text.ifEmpty { title }
            BankPrefs.enqueue(this, "notification", pkg, body, n.postTime)
        } catch (_: Throwable) {
        }
    }
}
