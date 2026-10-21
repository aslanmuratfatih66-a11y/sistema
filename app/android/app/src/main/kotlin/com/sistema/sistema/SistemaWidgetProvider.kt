package com.sistema.sistema

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import java.util.Calendar
import java.util.Locale

/**
 * Виджет «Система» (SPEC §8.12): следующий квест + таймер, шаги, вода, кнопка +250 мл.
 * Данные пишет приложение через home_widget (SharedPreferences "HomeWidgetPreferences"),
 * ключи — app/lib/core/live/live_codec.dart (WidgetKeys). Кнопка копит воду в pendingWaterMl,
 * приложение забирает её через WidgetSync.takePendingWater().
 */
class SistemaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            manager.updateAppWidget(id, buildViews(context))
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_ADD_WATER) {
            addWater(context, WATER_STEP_ML)
            updateAll(context)
            return
        }
        super.onReceive(context, intent)
    }

    companion object {
        const val PREFS = "HomeWidgetPreferences"
        const val ACTION_ADD_WATER = "com.sistema.sistema.widget.ADD_WATER"
        const val WATER_STEP_ML = 250

        private const val K_TITLE = "nextQuestTitle"
        private const val K_DEADLINE = "nextQuestDeadlineSec"
        private const val K_REWARD = "nextQuestReward"
        private const val K_STEPS = "steps"
        private const val K_STEP_GOAL = "stepGoal"
        private const val K_WATER = "waterMl"
        private const val K_WATER_GOAL = "waterGoalMl"
        private const val K_DAY = "dataDay"
        private const val K_PENDING = "pendingWaterMl"

        fun addWater(context: Context, ml: Int) {
            val p = prefs(context)
            p.edit()
                .putInt(K_PENDING, num(p, K_PENDING).toInt() + ml)
                .putInt(K_WATER, num(p, K_WATER).toInt() + ml)
                .apply()
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, SistemaWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val views = buildViews(context)
            for (id in ids) manager.updateAppWidget(id, views)
        }

        private fun prefs(context: Context): SharedPreferences =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        /** home_widget пишет Int через putInt, Long через putLong — читаем любое число. */
        private fun num(p: SharedPreferences, key: String, fallback: Long = 0L): Long =
            when (val v = p.all[key]) {
                is Int -> v.toLong()
                is Long -> v
                is Float -> v.toLong()
                is String -> v.toLongOrNull() ?: fallback
                else -> fallback
            }

        private fun label(p: SharedPreferences, key: String, fallback: String): String =
            p.getString(key, null)?.takeIf { it.isNotBlank() } ?: fallback

        private fun dayKey(now: Calendar): String = String.format(
            Locale.US, "%04d-%02d-%02d",
            now.get(Calendar.YEAR), now.get(Calendar.MONTH) + 1, now.get(Calendar.DAY_OF_MONTH),
        )

        private fun percent(value: Long, goal: Long): Int =
            if (goal <= 0) 0 else ((value * 100) / goal).coerceIn(0, 100).toInt()

        fun buildViews(context: Context): RemoteViews {
            val p = prefs(context)
            val views = RemoteViews(context.packageName, R.layout.sistema_widget)
            val today = p.getString(K_DAY, null) == dayKey(Calendar.getInstance())
            val pending = num(p, K_PENDING).coerceAtLeast(0)

            // Следующий квест и таймер.
            views.setTextViewText(
                R.id.sw_next_label,
                label(p, "lblNextQuest", context.getString(R.string.sistema_widget_next_quest)),
            )
            val title = p.getString(K_TITLE, null)?.trim().orEmpty()
            views.setViewVisibility(R.id.sw_quest_timer, View.GONE)
            views.setViewVisibility(R.id.sw_quest_status, View.GONE)
            views.setViewVisibility(R.id.sw_quest_reward, View.GONE)
            if (title.isEmpty()) {
                views.setTextViewText(
                    R.id.sw_quest_title,
                    label(p, "lblNoQuest", context.getString(R.string.sistema_widget_no_quest)),
                )
            } else {
                views.setTextViewText(R.id.sw_quest_title, title)
                val deadlineSec = num(p, K_DEADLINE)
                if (deadlineSec > 0) {
                    val leftMs = deadlineSec * 1000 - System.currentTimeMillis()
                    if (leftMs > 0) {
                        views.setChronometer(R.id.sw_quest_timer, SystemClock.elapsedRealtime() + leftMs, null, true)
                        views.setChronometerCountDown(R.id.sw_quest_timer, true)
                        views.setViewVisibility(R.id.sw_quest_timer, View.VISIBLE)
                    } else {
                        views.setTextViewText(R.id.sw_quest_status, label(p, "lblOverdue", "Просрочен"))
                        views.setViewVisibility(R.id.sw_quest_status, View.VISIBLE)
                    }
                }
                val reward = num(p, K_REWARD)
                if (reward > 0) {
                    views.setTextViewText(R.id.sw_quest_reward, "◆ $reward")
                    views.setViewVisibility(R.id.sw_quest_reward, View.VISIBLE)
                }
            }

            // Шаги.
            val steps = if (today) num(p, K_STEPS).coerceAtLeast(0) else 0L
            val stepGoal = num(p, K_STEP_GOAL, 8000L)
            views.setTextViewText(R.id.sw_steps, "${label(p, "lblSteps", "Шаги")}: $steps / $stepGoal")
            views.setProgressBar(R.id.sw_steps_progress, 100, percent(steps, stepGoal), false)

            // Вода (waterMl уже включает очередь; в новый день — только очередь).
            val water = if (today) num(p, K_WATER).coerceAtLeast(0) else pending
            val waterGoal = num(p, K_WATER_GOAL)
            val ml = label(p, "lblMl", "мл")
            val waterText = if (waterGoal > 0) "$water / $waterGoal $ml" else "$water $ml"
            views.setTextViewText(R.id.sw_water, "${label(p, "lblWater", "Вода")}: $waterText")
            views.setProgressBar(R.id.sw_water_progress, 100, percent(water, waterGoal), false)
            views.setTextViewText(
                R.id.sw_add_water,
                label(p, "lblAddWater", context.getString(R.string.sistema_widget_add_water)),
            )

            // Кнопка +250 — широковещательный интент самому провайдеру.
            val addIntent = Intent(context, SistemaWidgetProvider::class.java).setAction(ACTION_ADD_WATER)
            views.setOnClickPendingIntent(
                R.id.sw_add_water,
                PendingIntent.getBroadcast(
                    context, 2501, addIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            // Нажатие на виджет — открыть приложение.
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.let { launch ->
                views.setOnClickPendingIntent(
                    R.id.sw_root,
                    PendingIntent.getActivity(
                        context, 2500, launch,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    ),
                )
            }
            return views
        }
    }
}
