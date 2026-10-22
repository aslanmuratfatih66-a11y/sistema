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
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.util.Log

/**
 * Звонок будильника: foreground service (тип mediaPlayback) — системная мелодия будильника по кругу
 * на потоке ALARM с максимальной громкостью, вибрация, full-screen intent → MainActivity поверх блокировки.
 * Выключается только из приложения (AlarmChannel.stop после выполнения задания / «отложить»).
 */
class AlarmRingService : Service() {
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var savedVolume: Int? = null
    private var currentId: String? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeout = Runnable { stopSound() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopEverything()
            return START_NOT_STICKY
        }
        val id = intent?.getStringExtra(AlarmStore.EXTRA_ID) ?: AlarmStore.ringingId(this)
        if (id == null) {
            stopEverything()
            return START_NOT_STICKY
        }
        val title = intent?.getStringExtra(AlarmStore.EXTRA_TITLE)?.takeIf { it.isNotEmpty() }
            ?: AlarmStore.ringingTitle(this).ifEmpty { AlarmStore.label(this, "channel", "Alarm") }
        val body = intent?.getStringExtra(AlarmStore.EXTRA_BODY) ?: AlarmStore.ringingBody(this)
        val notification = buildNotification(id, title, body)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            // Android 12+: запуск из фона без исключения → хотя бы обычное уведомление.
            Log.e(TAG, "startForeground: $e")
            getSystemService(NotificationManager::class.java)?.notify(NOTIFICATION_ID, notification)
        }
        if (currentId != id || player == null) {
            currentId = id
            startSound()
        }
        return START_STICKY
    }

    private fun ensureChannel() {
        val nm = getSystemService(NotificationManager::class.java) ?: return
        if (nm.getNotificationChannel(CHANNEL_ID) != null) return
        val ch = NotificationChannel(
            CHANNEL_ID,
            AlarmStore.label(this, "channel", "Alarm"),
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = AlarmStore.label(this@AlarmRingService, "channelDesc", "")
            setSound(null, null) // звук играет сам сервис
            enableVibration(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setBypassDnd(true)
        }
        nm.createNotificationChannel(ch)
    }

    private fun buildNotification(id: String, title: String, body: String): Notification {
        ensureChannel()
        val open = Intent(this, MainActivity::class.java)
            .setAction(ACTION_OPEN)
            .putExtra(AlarmStore.EXTRA_ID, id)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pi = PendingIntent.getActivity(
            this, id.hashCode(), open, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val icon = applicationInfo.icon
        val action = Notification.Action.Builder(
            Icon.createWithResource(this, icon),
            AlarmStore.label(this, "doTask", "Open"),
            pi
        ).build()
        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(icon)
            .setContentTitle(title)
            .setContentText(body)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(true)
            .setContentIntent(pi)
            .setFullScreenIntent(pi, true)
            .addAction(action)
            .build()
    }

    private fun alarmUri(): Uri? =
        RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            ?: Settings.System.DEFAULT_ALARM_ALERT_URI

    private fun startSound() {
        stopSound()
        acquireWakeLock()
        val am = getSystemService(AudioManager::class.java)
        if (am != null) {
            try {
                savedVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
                am.setStreamVolume(AudioManager.STREAM_ALARM, am.getStreamMaxVolume(AudioManager.STREAM_ALARM), 0)
            } catch (e: Exception) {
                Log.w(TAG, "volume: $e") // «Не беспокоить» без доступа к политике
                savedVolume = null
            }
        }
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val candidates = listOfNotNull(
            alarmUri(),
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        )
        for (uri in candidates) {
            try {
                player = MediaPlayer().apply {
                    setAudioAttributes(attrs)
                    setDataSource(this@AlarmRingService, uri)
                    isLooping = true
                    prepare()
                    start()
                }
                break
            } catch (e: Exception) {
                Log.w(TAG, "player $uri: $e")
                player?.release()
                player = null
            }
        }
        startVibration(attrs)
        handler.removeCallbacks(timeout)
        handler.postDelayed(timeout, MAX_RING_MS)
    }

    @Suppress("DEPRECATION")
    private fun startVibration(attrs: AudioAttributes) {
        val v: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            getSystemService(Vibrator::class.java)
        }
        vibrator = v
        if (v == null || !v.hasVibrator()) return
        try {
            v.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 900, 600), 0), attrs)
        } catch (e: Exception) {
            Log.w(TAG, "vibrate: $e")
        }
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        val pm = getSystemService(PowerManager::class.java) ?: return
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "sistema:alarm").apply {
            setReferenceCounted(false)
            acquire(MAX_RING_MS + 60_000L)
        }
    }

    private fun stopSound() {
        handler.removeCallbacks(timeout)
        try {
            player?.stop()
        } catch (e: Exception) {
            // уже остановлен
        }
        player?.release()
        player = null
        try {
            vibrator?.cancel()
        } catch (e: Exception) {
        }
        vibrator = null
        val vol = savedVolume
        if (vol != null) {
            try {
                getSystemService(AudioManager::class.java)?.setStreamVolume(AudioManager.STREAM_ALARM, vol, 0)
            } catch (e: Exception) {
            }
        }
        savedVolume = null
        if (wakeLock?.isHeld == true) wakeLock?.release()
        wakeLock = null
    }

    private fun stopEverything() {
        stopSound()
        currentId = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        getSystemService(NotificationManager::class.java)?.cancel(NOTIFICATION_ID)
        stopSelf()
    }

    override fun onDestroy() {
        stopSound()
        super.onDestroy()
    }

    companion object {
        private const val TAG = "AlarmRingService"
        const val CHANNEL_ID = "sistema_alarm"
        const val NOTIFICATION_ID = 0x5157A1
        const val ACTION_START = "com.sistema.sistema.alarm.START"
        const val ACTION_STOP = "com.sistema.sistema.alarm.STOP"
        /** Открыть экран задания (full-screen intent / кнопка уведомления). */
        const val ACTION_OPEN = "com.sistema.sistema.alarm.OPEN"
        /** Звонок не дольше 30 мин (батарея); экран задания и уведомление остаются. */
        private const val MAX_RING_MS = 30 * 60_000L

        fun start(ctx: Context, id: String, title: String, body: String) {
            val i = Intent(ctx, AlarmRingService::class.java)
                .setAction(ACTION_START)
                .putExtra(AlarmStore.EXTRA_ID, id)
                .putExtra(AlarmStore.EXTRA_TITLE, title)
                .putExtra(AlarmStore.EXTRA_BODY, body)
            ctx.startForegroundService(i)
        }

        fun stop(ctx: Context) {
            // stopService вместо startService(STOP): из фона startService запрещён.
            ctx.stopService(Intent(ctx, AlarmRingService::class.java))
            ctx.getSystemService(NotificationManager::class.java)?.cancel(NOTIFICATION_ID)
        }
    }
}
