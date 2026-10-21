package com.sistema.sistema

import androidx.activity.ComponentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Канал шагов (SPEC §8.3, §12): Health Connect, фолбэк — датчик TYPE_STEP_COUNTER.
 * Контракт — app/lib/core/activity/activity_api.dart:
 *   isAvailable → Boolean
 *   requestPermission → Boolean
 *   query {from: ms, to: ms} → {steps: Int, distanceM: Double?, floors: Int?} или null
 * КАРКАС: реализация — сабагент B (этап 3).
 */
class StepCounterChannel(private val activity: ComponentActivity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, NAME)

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(false)
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        const val NAME = "sistema/steps"
    }
}
