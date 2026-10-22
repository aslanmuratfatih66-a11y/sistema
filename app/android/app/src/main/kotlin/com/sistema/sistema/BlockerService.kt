package com.sistema.sistema

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Блокировка после отбоя (SPEC §8.6): foreground service (тип specialUse) в окне расписания раз в ~1 с
 * через UsageStatsManager.queryEvents определяет приложение на переднем плане. Если оно в списке —
 * полноэкранный оверлей «Система: отбой» (TYPE_APPLICATION_OVERLAY) с кнопкой «Закрыть» (домашний экран)
 * и попытка в очередь BlockerSchedule (Dart забирает drainAttempts). После until сервис останавливается и,
 * если окно повторяется, ставит будильник на следующий вечер (BlockerReceiver). Без Accessibility.
 */
class BlockerService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var schedule: BlockerScheduleData? = null
    private var untilMs: Long = 0L

    private var lastQueryMs: Long = 0L
    private var foreground: String? = null

    /** Пакет, за открытие которого уже записана попытка (до смены переднего плана). */
    private var attemptFor: String? = null

    private var overlay: View? = null
    private var overlayFor: String? = null

    private val tick = object : Runnable {
        override fun run() {
            try {
                poll()
            } catch (e: Exception) {
                Log.w(TAG, "poll failed", e)
            }
            if (running) handler.postDelayed(this, POLL_MS)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val s = BlockerSchedule.load(this)
        val now = System.currentTimeMillis()
        val window = s?.effectiveWindow(now)
        // startForeground — сразу (обязателен в течение нескольких секунд после startForegroundService).
        if (!enterForeground(s)) {
            stopSelf()
            return START_NOT_STICKY
        }
        if (s == null || window == null || now < window.first || now >= window.second || s.appIds.isEmpty()) {
            finish()
            return START_NOT_STICKY
        }
        schedule = s
        untilMs = window.second
        if (!running) {
            running = true
            lastQueryMs = now - INITIAL_LOOKBACK_MS
            handler.post(tick)
        }
        return START_STICKY
    }

    override fun onDestroy() {
        running = false
        handler.removeCallbacks(tick)
        hideOverlay()
        super.onDestroy()
    }

    private fun finish() {
        running = false
        handler.removeCallbacks(tick)
        hideOverlay()
        try {
            stopForeground(Service.STOP_FOREGROUND_REMOVE)
        } catch (e: Exception) {
            // уже не на переднем плане
        }
        stopSelf()
        // Следующее окно (repeatDaily) — будильником.
        scheduleNextStart(this)
    }

    // ---------- Опрос переднего плана ----------

    private fun poll() {
        val s = schedule ?: return finish()
        val now = System.currentTimeMillis()
        if (now >= untilMs) {
            finish()
            return
        }
        val power = getSystemService(Context.POWER_SERVICE) as? PowerManager
        if (power != null && !power.isInteractive) {
            // Экран выключен: события не нужны, следующий запрос — с текущего момента.
            lastQueryMs = now - 1000L
            return
        }
        val fg = currentForeground(now)
        if (fg == null) return
        if (fg in s.appIds) {
            if (attemptFor != fg) {
                attemptFor = fg
                BlockerSchedule.addAttempt(this, fg, now)
            }
            if (overlayFor != fg) showOverlay(fg, s)
        } else {
            attemptFor = null
            if (overlay != null) hideOverlay()
        }
    }

    /** Пакет последнего события «на передний план» (MOVE_TO_FOREGROUND == ACTIVITY_RESUMED). */
    private fun currentForeground(now: Long): String? {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager ?: return foreground
        val events = try {
            usm.queryEvents(lastQueryMs, now)
        } catch (e: Exception) {
            null
        } ?: return foreground
        val event = UsageEvents.Event()
        @Suppress("DEPRECATION")
        val moveToForeground = UsageEvents.Event.MOVE_TO_FOREGROUND
        var last: String? = null
        var lastAt = 0L
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == moveToForeground && event.timeStamp >= lastAt) {
                last = event.packageName
                lastAt = event.timeStamp
            }
        }
        // Небольшой нахлёст, чтобы не потерять событие на границе запросов.
        lastQueryMs = now - 500L
        if (last != null) foreground = last
        return foreground
    }

    // ---------- Оверлей ----------

    private fun showOverlay(pkg: String, s: BlockerScheduleData) {
        if (!Settings.canDrawOverlays(this)) return
        hideOverlay()
        val wm = getSystemService(Context.WINDOW_SERVICE) as? WindowManager ?: return
        val view = buildOverlay(s)
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        )
        params.gravity = Gravity.CENTER
        try {
            wm.addView(view, params)
            overlay = view
            overlayFor = pkg
        } catch (e: Exception) {
            Log.w(TAG, "addView failed", e)
        }
    }

    private fun hideOverlay() {
        val v = overlay ?: return
        overlay = null
        overlayFor = null
        val wm = getSystemService(Context.WINDOW_SERVICE) as? WindowManager ?: return
        try {
            wm.removeViewImmediate(v)
        } catch (e: Exception) {
            // уже убран
        }
    }

    private fun goHome() {
        hideOverlay()
        val home = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_HOME)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            // Разрешено из фона: у приложения есть SYSTEM_ALERT_WINDOW.
            startActivity(home)
        } catch (e: Exception) {
            Log.w(TAG, "home failed", e)
        }
        // Если приложение осталось на переднем плане — следующий опрос покажет оверлей снова (без новой попытки).
    }

    private fun dp(v: Float): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, resources.displayMetrics).toInt()

    private fun buildOverlay(s: BlockerScheduleData): View {
        val root = object : FrameLayout(this) {
            override fun dispatchKeyEvent(event: KeyEvent): Boolean {
                if (event.keyCode == KeyEvent.KEYCODE_BACK) {
                    if (event.action == KeyEvent.ACTION_UP) goHome()
                    return true
                }
                return super.dispatchKeyEvent(event)
            }
        }
        root.setBackgroundColor(COLOR_BACKGROUND)
        root.isClickable = true
        root.isFocusable = true
        root.isFocusableInTouchMode = true

        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24f), dp(28f), dp(24f), dp(24f))
            background = GradientDrawable().apply {
                setColor(COLOR_PANEL)
                setStroke(dp(1f), COLOR_BORDER)
                cornerRadius = dp(3f).toFloat()
            }
        }

        val label = TextView(this).apply {
            text = "◆"
            setTextColor(COLOR_ACCENT_LIGHT)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            gravity = Gravity.CENTER
        }
        val title = TextView(this).apply {
            text = s.text("title", "Система: отбой").uppercase()
            setTextColor(COLOR_DANGER)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 26f)
            typeface = Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD)
            letterSpacing = 0.12f
            gravity = Gravity.CENTER
        }
        val body = TextView(this).apply {
            text = s.text("body", "")
            setTextColor(COLOR_TEXT)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            gravity = Gravity.CENTER
            setLineSpacing(0f, 1.2f)
        }
        val button = TextView(this).apply {
            text = s.text("button", "OK").uppercase()
            setTextColor(COLOR_ACCENT_LIGHTER)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD)
            letterSpacing = 0.12f
            gravity = Gravity.CENTER
            minHeight = dp(48f)
            setPadding(dp(28f), dp(12f), dp(28f), dp(12f))
            background = GradientDrawable().apply {
                setColor(COLOR_BUTTON)
                setStroke(dp(1f), COLOR_ACCENT)
                cornerRadius = dp(3f).toFloat()
            }
            isClickable = true
            isFocusable = true
            setOnClickListener { goHome() }
        }

        fun lp(top: Int) = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
        ).apply { topMargin = top; gravity = Gravity.CENTER_HORIZONTAL }

        column.addView(label, lp(0))
        column.addView(title, lp(dp(8f)))
        column.addView(body, lp(dp(14f)))
        column.addView(button, lp(dp(24f)))

        val columnParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            Gravity.CENTER,
        ).apply {
            leftMargin = dp(20f)
            rightMargin = dp(20f)
        }
        root.addView(column, columnParams)
        return root
    }

    // ---------- Уведомление переднего плана ----------

    private fun enterForeground(s: BlockerScheduleData?): Boolean {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        nm?.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, s?.text("notificationTitle", "Система") ?: "Система", NotificationManager.IMPORTANCE_LOW)
                .apply { setShowBadge(false) }
        )
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val content = launch?.let {
            PendingIntent.getActivity(this, 0, it, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        }
        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentTitle(s?.text("notificationTitle", "Система") ?: "Система")
            .setContentText(s?.text("notificationBody", "") ?: "")
            .setOngoing(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_SERVICE)
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
        private const val TAG = "BlockerService"
        private const val CHANNEL_ID = "sistema_blocker"
        private const val NOTIFICATION_ID = 7106
        private const val POLL_MS = 1000L
        private const val INITIAL_LOOKBACK_MS = 10 * 60 * 1000L
        const val ACTION_START = "com.sistema.sistema.blocker.START"

        private val COLOR_BACKGROUND = Color.argb(245, 3, 5, 11)
        private val COLOR_PANEL = Color.argb(240, 9, 22, 48)
        private val COLOR_BORDER = Color.argb(140, 63, 180, 255)
        private val COLOR_BUTTON = Color.argb(60, 63, 180, 255)
        private val COLOR_ACCENT = Color.rgb(63, 180, 255)
        private val COLOR_ACCENT_LIGHT = Color.rgb(127, 212, 255)
        private val COLOR_ACCENT_LIGHTER = Color.rgb(159, 226, 255)
        private val COLOR_DANGER = Color.rgb(255, 77, 94)
        private val COLOR_TEXT = Color.rgb(230, 243, 255)

        /** Сервис работает (опрашивает передний план). */
        @Volatile
        var running: Boolean = false
            private set

        /**
         * Применить сохранённое расписание: внутри окна — запустить сервис, до окна — будильник на начало,
         * нет расписания — остановить всё.
         */
        fun applySchedule(context: Context) {
            val app = context.applicationContext
            cancelAlarm(app)
            val s = BlockerSchedule.load(app)
            val now = System.currentTimeMillis()
            val window = s?.effectiveWindow(now)
            if (s == null || window == null || s.appIds.isEmpty()) {
                if (s != null && window == null) BlockerSchedule.clear(app)
                app.stopService(Intent(app, BlockerService::class.java))
                return
            }
            if (now >= window.first) {
                start(app)
            } else {
                app.stopService(Intent(app, BlockerService::class.java))
                setAlarm(app, window.first)
            }
        }

        /** После окна: будильник на следующее (если repeatDaily). */
        fun scheduleNextStart(context: Context) {
            val app = context.applicationContext
            val s = BlockerSchedule.load(app) ?: return
            val now = System.currentTimeMillis()
            val window = s.effectiveWindow(now + 1000L)
            if (window == null) {
                BlockerSchedule.clear(app)
                return
            }
            if (window.first > now) setAlarm(app, window.first)
        }

        private fun start(context: Context) {
            val intent = Intent(context, BlockerService::class.java).setAction(ACTION_START)
            try {
                context.startForegroundService(intent)
            } catch (e: Exception) {
                // Android 12+: запуск FGS из фона запрещён (ForegroundServiceStartNotAllowedException) —
                // повторим при следующем открытии приложения (Dart вызывает setSchedule на resume).
                Log.w(TAG, "startForegroundService failed", e)
            }
        }

        private fun alarmIntent(context: Context): PendingIntent =
            PendingIntent.getBroadcast(
                context,
                7106,
                Intent(context, BlockerReceiver::class.java).setAction(ACTION_START),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )

        private fun setAlarm(context: Context, at: Long) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val pi = alarmIntent(context)
            try {
                val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || am.canScheduleExactAlarms()
                if (exact) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
                } else {
                    // Без точных будильников запуск FGS из фона может быть запрещён — тогда сервис стартует
                    // при следующем открытии приложения.
                    am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
                }
            } catch (e: SecurityException) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
            }
        }

        private fun cancelAlarm(context: Context) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            am.cancel(alarmIntent(context))
        }
    }
}

/** Будильник начала окна, перезагрузка, обновление приложения, смена времени → применить расписание. */
class BlockerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        try {
            BlockerService.applySchedule(context)
        } catch (e: Exception) {
            Log.w("BlockerReceiver", "applySchedule failed", e)
        }
    }
}
