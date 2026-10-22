package com.sistema.sistema

import android.animation.ValueAnimator
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import kotlin.math.abs
import kotlin.math.hypot

/**
 * Окна персонажа поверх других приложений (TYPE_APPLICATION_OVERLAY):
 *  • аватар — круглая картинка (PNG из Dart), перетаскивается пальцем и прилипает к ближайшему
 *    боковому краю; позиция запоминается; тап — открыть Систему; долгое нажатие — скрыть
 *    (до следующего сворачивания приложения);
 *  • облачко — отдельное окно рядом с аватаром (со стороны центра экрана), исчезает через durationMs.
 * Все методы — на главном потоке (вызовы из MethodChannel и сервиса).
 */
object OverlayBubble {
    private const val TAG = "OverlayBubble"
    private const val PREFS = "sistema_overlay"
    private const val AVATAR_DP = 64f
    private const val MARGIN_DP = 4f
    private const val GAP_DP = 6f

    private val main = Handler(Looper.getMainLooper())
    private var app: Context? = null
    private var wm: WindowManager? = null

    private var avatarView: ImageView? = null
    private var avatarParams: WindowManager.LayoutParams? = null
    private var bubbleView: TextView? = null
    private var snap: ValueAnimator? = null

    private val removeBubbleRunnable = Runnable { removeBubble() }

    val isShown: Boolean
        get() = avatarView != null

    /** Показать аватар (или обновить картинку, если уже показан). false — окно добавить не удалось. */
    fun show(context: Context, avatar: Bitmap?, label: String?): Boolean {
        val ctx = context.applicationContext
        app = ctx
        val manager = wm ?: (ctx.getSystemService(Context.WINDOW_SERVICE) as WindowManager).also { wm = it }
        avatarView?.let { view ->
            if (avatar != null) view.setImageBitmap(avatar)
            if (!label.isNullOrBlank()) view.contentDescription = label
            return true
        }
        val size = dp(ctx, AVATAR_DP)
        val view = ImageView(ctx).apply {
            scaleType = ImageView.ScaleType.FIT_CENTER
            if (avatar != null) {
                setImageBitmap(avatar)
            } else {
                // Без картинки — простой круг в цветах Системы.
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(0xF20D2044.toInt())
                    setStroke(dp(ctx, 2f), 0xFF3FB4FF.toInt())
                }
            }
            contentDescription = label
            isClickable = true
        }
        val (screenW, screenH) = screen(ctx)
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val right = prefs.getBoolean("right", true)
        val margin = dp(ctx, MARGIN_DP)
        val params = WindowManager.LayoutParams(
            size,
            size,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = if (right) screenW - size - margin else margin
            y = clampY(ctx, prefs.getInt("y", (screenH * 0.6f).toInt()), screenH)
        }
        attachTouch(ctx, view, params)
        return try {
            manager.addView(view, params)
            avatarView = view
            avatarParams = params
            true
        } catch (e: Exception) {
            // Нет разрешения / окно не приняли.
            Log.w(TAG, "addView failed", e)
            false
        }
    }

    fun hide() {
        main.removeCallbacks(removeBubbleRunnable)
        snap?.cancel()
        snap = null
        removeBubble()
        val view = avatarView ?: return
        avatarView = null
        avatarParams = null
        try {
            wm?.removeView(view)
        } catch (e: Exception) {
            Log.w(TAG, "removeView failed", e)
        }
    }

    fun setAvatar(bitmap: Bitmap) {
        avatarView?.apply {
            background = null
            setImageBitmap(bitmap)
        }
    }

    /** Облачко с репликой рядом с аватаром. Без показанного аватара — игнорируется. */
    fun say(text: String, durationMs: Long) {
        val ctx = app ?: return
        val manager = wm ?: return
        val p = avatarParams ?: return
        val t = text.trim()
        if (t.isEmpty()) return
        main.removeCallbacks(removeBubbleRunnable)
        removeBubble()

        val (screenW, _) = screen(ctx)
        val size = dp(ctx, AVATAR_DP)
        val gap = dp(ctx, GAP_DP)
        val onRight = p.x + size / 2 > screenW / 2
        val view = TextView(ctx).apply {
            this.text = t
            setTextColor(0xFFE6F3FF.toInt())
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            maxWidth = minOf(dp(ctx, 260f), screenW - size - gap * 2 - dp(ctx, MARGIN_DP) * 2)
            maxLines = 7
            ellipsize = TextUtils.TruncateAt.END
            setPadding(dp(ctx, 12f), dp(ctx, 8f), dp(ctx, 12f), dp(ctx, 8f))
            background = GradientDrawable().apply {
                cornerRadius = dp(ctx, 6f).toFloat()
                setColor(0xF20D2044.toInt())
                setStroke(dp(ctx, 1f), 0xFF3FB4FF.toInt())
            }
            // TalkBack зачитает реплику при появлении.
            accessibilityLiveRegion = View.ACCESSIBILITY_LIVE_REGION_POLITE
            setOnClickListener {
                openApp(ctx)
            }
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT,
        ).apply {
            // Со стороны центра экрана: при аватаре справа — облачко левее него (отсчёт от правого края).
            gravity = Gravity.TOP or (if (onRight) Gravity.END else Gravity.START)
            x = if (onRight) screenW - p.x + gap else p.x + size + gap
            y = p.y
        }
        try {
            manager.addView(view, params)
            bubbleView = view
            main.postDelayed(removeBubbleRunnable, durationMs.coerceIn(2000L, 20000L))
        } catch (e: Exception) {
            Log.w(TAG, "bubble addView failed", e)
        }
    }

    private fun removeBubble() {
        val view = bubbleView ?: return
        bubbleView = null
        try {
            wm?.removeView(view)
        } catch (e: Exception) {
            Log.w(TAG, "bubble removeView failed", e)
        }
    }

    // ---------- Жесты ----------

    private fun attachTouch(ctx: Context, view: View, p: WindowManager.LayoutParams) {
        val slop = ViewConfiguration.get(ctx).scaledTouchSlop
        val longTimeout = ViewConfiguration.getLongPressTimeout().toLong()
        var downX = 0f
        var downY = 0f
        var startX = 0
        var startY = 0
        var dragging = false
        var longFired = false
        val longPress = Runnable {
            longFired = true
            view.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
            hideByUser(ctx)
        }
        view.setOnTouchListener { v, e ->
            when (e.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downX = e.rawX
                    downY = e.rawY
                    startX = p.x
                    startY = p.y
                    dragging = false
                    longFired = false
                    snap?.cancel()
                    main.postDelayed(longPress, longTimeout)
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = e.rawX - downX
                    val dy = e.rawY - downY
                    if (!dragging && !longFired && hypot(dx, dy) > slop) {
                        dragging = true
                        main.removeCallbacks(longPress)
                        main.removeCallbacks(removeBubbleRunnable)
                        removeBubble()
                    }
                    if (dragging && avatarView === v) {
                        p.x = startX + dx.toInt()
                        p.y = clampY(ctx, startY + dy.toInt(), screen(ctx).second)
                        update(v, p)
                    }
                }
                MotionEvent.ACTION_UP -> {
                    main.removeCallbacks(longPress)
                    when {
                        longFired -> Unit
                        dragging -> snapToEdge(ctx, v, p)
                        abs(e.rawX - downX) <= slop && abs(e.rawY - downY) <= slop -> {
                            v.performClick()
                            openApp(ctx)
                        }
                    }
                }
                MotionEvent.ACTION_CANCEL -> {
                    main.removeCallbacks(longPress)
                    if (dragging) snapToEdge(ctx, v, p)
                }
            }
            true
        }
    }

    private fun snapToEdge(ctx: Context, v: View, p: WindowManager.LayoutParams) {
        val (screenW, _) = screen(ctx)
        val size = dp(ctx, AVATAR_DP)
        val margin = dp(ctx, MARGIN_DP)
        val right = p.x + size / 2 > screenW / 2
        val target = if (right) screenW - size - margin else margin
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean("right", right)
            .putInt("y", p.y)
            .apply()
        snap?.cancel()
        snap = ValueAnimator.ofInt(p.x, target).apply {
            duration = 220L
            addUpdateListener {
                if (avatarView !== v) return@addUpdateListener
                p.x = it.animatedValue as Int
                update(v, p)
            }
            start()
        }
    }

    private fun update(v: View, p: WindowManager.LayoutParams) {
        try {
            wm?.updateViewLayout(v, p)
        } catch (e: Exception) {
            Log.w(TAG, "updateViewLayout failed", e)
        }
    }

    /** Долгое нажатие: убрать персонажа до следующего сворачивания приложения. */
    private fun hideByUser(ctx: Context) {
        hide()
        OverlayService.stop(ctx)
    }

    /** Тап: открыть Систему (приложение с разрешением оверлея может запускать Activity из фона). */
    private fun openApp(ctx: Context) {
        val intent = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)
            ?: Intent(ctx, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        try {
            ctx.startActivity(intent)
        } catch (e: Exception) {
            Log.w(TAG, "startActivity failed", e)
        }
        // Dart скроет оверлей на resumed; но если движок пересоздаётся — убираем сразу.
        hideByUser(ctx)
    }

    // ---------- Размеры ----------

    private fun screen(ctx: Context): Pair<Int, Int> {
        val manager = wm
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && manager != null) {
            val b = manager.currentWindowMetrics.bounds
            return b.width() to b.height()
        }
        val dm = ctx.resources.displayMetrics
        return dm.widthPixels to dm.heightPixels
    }

    private fun clampY(ctx: Context, y: Int, screenH: Int): Int {
        val top = dp(ctx, 32f)
        val bottom = screenH - dp(ctx, AVATAR_DP) - dp(ctx, 56f)
        return if (bottom <= top) top else y.coerceIn(top, bottom)
    }

    private fun dp(ctx: Context, v: Float): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, ctx.resources.displayMetrics).toInt()
}
