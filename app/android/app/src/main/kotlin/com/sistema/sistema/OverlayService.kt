package com.sistema.sistema

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.os.Build
import android.os.IBinder
import android.util.Log

/**
 * Foreground service (тип specialUse) на время, пока персонаж висит поверх других приложений:
 * держит процесс живым и показывает уведомление «Персонаж на экране» (тап — открыть Систему,
 * кнопка «Скрыть»). Сами окна — OverlayBubble (добавляются ДО старта сервиса: видимое окно оверлея +
 * разрешение SYSTEM_ALERT_WINDOW — исключение из запрета запуска FGS из фона на Android 12+).
 */
class OverlayService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_HIDE) {
            // Кнопка «Скрыть» в уведомлении (сервис уже на переднем плане).
            OverlayBubble.hide()
            stopSelfSafely()
            return START_NOT_STICKY
        }
        // startForeground — сразу (обязателен после startForegroundService), даже если окно уже убрали.
        val ok = enterForeground(intent)
        running = ok
        if (!ok || !OverlayBubble.isShown) {
            OverlayBubble.hide()
            stopSelfSafely()
        }
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Приложение смахнули из недавних — персонажа тоже убираем.
        OverlayBubble.hide()
        stopSelfSafely()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        running = false
        OverlayBubble.hide()
        super.onDestroy()
    }

    private fun stopSelfSafely() {
        running = false
        try {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } catch (e: Exception) {
            Log.w(TAG, "stopForeground failed", e)
        }
        stopSelf()
    }

    private fun enterForeground(intent: Intent?): Boolean {
        val title = intent?.getStringExtra(EXTRA_TITLE)?.takeIf { it.isNotBlank() } ?: lastTitle
        val body = intent?.getStringExtra(EXTRA_BODY) ?: lastBody
        val hide = intent?.getStringExtra(EXTRA_HIDE)?.takeIf { it.isNotBlank() } ?: lastHide
        lastTitle = title
        lastBody = body
        lastHide = hide

        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        nm?.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, title, NotificationManager.IMPORTANCE_MIN).apply { setShowBadge(false) }
        )
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val content = launch?.let {
            PendingIntent.getActivity(this, 0, it, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        }
        val hidePi = PendingIntent.getService(
            this,
            1,
            Intent(this, OverlayService::class.java).setAction(ACTION_HIDE),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val hideAction = Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.ic_menu_close_clear_cancel),
            hide,
            hidePi,
        ).build()
        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setOngoing(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .addAction(hideAction)
            .apply { if (content != null) setContentIntent(content) }
            .build()
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            true
        } catch (e: Exception) {
            Log.w(TAG, "startForeground failed", e)
            false
        }
    }

    companion object {
        private const val TAG = "OverlayService"
        private const val CHANNEL_ID = "sistema_overlay"
        private const val NOTIFICATION_ID = 7471
        private const val ACTION_SHOW = "com.sistema.sistema.overlay.SHOW"
        private const val ACTION_HIDE = "com.sistema.sistema.overlay.HIDE"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_BODY = "body"
        private const val EXTRA_HIDE = "hide"

        /** Сервис уже вызвал startForeground и ещё не остановлен. */
        @Volatile
        private var running = false

        private var lastTitle = "Система"
        private var lastBody = ""
        private var lastHide = "Скрыть"

        fun start(context: Context, texts: Map<String, String>) {
            val app = context.applicationContext
            val intent = Intent(app, OverlayService::class.java)
                .setAction(ACTION_SHOW)
                .putExtra(EXTRA_TITLE, texts["notificationTitle"])
                .putExtra(EXTRA_BODY, texts["notificationBody"])
                .putExtra(EXTRA_HIDE, texts["hideAction"])
            try {
                app.startForegroundService(intent)
            } catch (e: Exception) {
                // Android 12+ может запретить старт FGS из фона — окно всё равно показано, только без
                // уведомления (процесс может быть выгружен системой раньше).
                Log.w(TAG, "startForegroundService failed", e)
            }
        }

        /**
         * Остановить сервис. Если он ещё не дошёл до startForeground — не трогаем: onStartCommand
         * сам увидит, что окна нет (OverlayBubble.isShown == false), и остановится.
         */
        fun stop(context: Context) {
            if (!running) return
            val app = context.applicationContext
            try {
                app.stopService(Intent(app, OverlayService::class.java))
            } catch (e: Exception) {
                Log.w(TAG, "stopService failed", e)
            }
        }
    }
}
