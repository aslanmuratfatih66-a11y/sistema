package com.sistema.sistema

import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.KeyEvent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Канал `sistema/audio` (протокол — шапка app/lib/core/audio/channel_music_controller.dart).
 * Android: названия трека чужого плеера без NotificationListener не узнать — отдаём source=other
 * (SPEC §8.5: остальные сервисы — только голос поверх). Управление — медиа-кнопки AudioManager.
 * События `sistema/audio/events`: опрос isMusicActive раз в 2 с, отправка только при изменении.
 */
class AudioChannel(context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val appContext = context.applicationContext
    private val audioManager = appContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val methods = MethodChannel(messenger, CHANNEL)
    private val events = EventChannel(messenger, EVENTS)
    private val handler = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var lastSent: Map<String, Any?>? = null
    private var sentOnce = false

    private val poll = object : Runnable {
        override fun run() {
            send()
            if (sink != null) handler.postDelayed(this, POLL_MS)
        }
    }

    init {
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestAccess" -> result.success(true)
            "getNowPlaying" -> result.success(snapshot())
            "playPause" -> { mediaKey(KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE); result.success(null) }
            "next" -> { mediaKey(KeyEvent.KEYCODE_MEDIA_NEXT); result.success(null) }
            "previous" -> { mediaKey(KeyEvent.KEYCODE_MEDIA_PREVIOUS); result.success(null) }
            "isSpotifyInstalled" -> result.success(isInstalled(SPOTIFY_PACKAGE))
            else -> result.notImplemented()
        }
    }

    private fun snapshot(): Map<String, Any?>? =
        if (audioManager.isMusicActive) mapOf("source" to "other", "isPlaying" to true) else null

    private fun send() {
        val s = sink ?: return
        val value = snapshot()
        if (sentOnce && value == lastSent) return
        sentOnce = true
        lastSent = value
        s.success(value)
    }

    private fun mediaKey(code: Int) {
        val now = SystemClock.uptimeMillis()
        audioManager.dispatchMediaKeyEvent(KeyEvent(now, now, KeyEvent.ACTION_DOWN, code, 0))
        audioManager.dispatchMediaKeyEvent(KeyEvent(now, now, KeyEvent.ACTION_UP, code, 0))
        // Состояние плеера меняется не мгновенно — обновим чуть позже.
        handler.postDelayed({ send() }, 500)
    }

    @Suppress("DEPRECATION")
    private fun isInstalled(pkg: String): Boolean = try {
        appContext.packageManager.getPackageInfo(pkg, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        sentOnce = false
        lastSent = null
        handler.removeCallbacks(poll)
        handler.post(poll)
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        handler.removeCallbacks(poll)
    }

    fun dispose() {
        onCancel(null)
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
    }

    private companion object {
        const val CHANNEL = "sistema/audio"
        const val EVENTS = "sistema/audio/events"
        const val POLL_MS = 2000L
        const val SPOTIFY_PACKAGE = "com.spotify.music"
    }
}
