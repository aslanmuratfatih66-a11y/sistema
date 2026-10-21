package com.sistema.sistema

import android.Manifest
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.aggregate.AggregateMetric
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.FloorsClimbedRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import kotlin.coroutines.resume
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull

/**
 * Канал шагов (SPEC §8.3, §12): Health Connect, фолбэк — датчик TYPE_STEP_COUNTER.
 * Контракт — app/lib/core/activity/activity_api.dart:
 *   isAvailable → Boolean
 *   kind → String ("healthConnect" | "sensor") — тип источника (StepSourceKind.name)
 *   requestPermission → Boolean
 *   query {from: ms, to: ms} → {steps: Int, distanceM: Double?, floors: Int?} или null (нет доступа/данных)
 *
 * Лаунчеры разрешений регистрируются через activityResultRegistry.register(key, …) без LifecycleOwner:
 * такой вызов допустим в любой момент (configureFlutterEngine у FlutterFragmentActivity может
 * выполниться уже после onStart, а registerForActivityResult после STARTED бросает исключение).
 */
class StepCounterChannel(private val activity: ComponentActivity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, NAME)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val context: Context = activity.applicationContext
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private var pendingPermission: MethodChannel.Result? = null

    private val healthPermissionLauncher: ActivityResultLauncher<Set<String>> =
        activity.activityResultRegistry.register(
            "sistema.steps.health",
            PermissionController.createRequestPermissionResultContract(),
        ) { granted: Set<String> ->
            finishPermission(granted.contains(STEPS_PERMISSION))
        }

    private val sensorPermissionLauncher: ActivityResultLauncher<String> =
        activity.activityResultRegistry.register(
            "sistema.steps.sensor",
            ActivityResultContracts.RequestPermission(),
        ) { granted: Boolean ->
            finishPermission(granted)
        }

    init {
        channel.setMethodCallHandler { call, result -> handle(call, result) }
        activity.lifecycle.addObserver(LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_DESTROY) {
                scope.cancel()
                healthPermissionLauncher.unregister()
                sensorPermissionLauncher.unregister()
                channel.setMethodCallHandler(null)
                finishPermission(false)
            }
        })
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(healthConnectAvailable() || stepSensor() != null)
            "kind" -> result.success(if (healthConnectAvailable()) "healthConnect" else "sensor")
            "requestPermission" -> requestPermission(result)
            "query" -> {
                val from = (call.argument<Any>("from") as? Number)?.toLong()
                val to = (call.argument<Any>("to") as? Number)?.toLong()
                if (from == null || to == null) {
                    result.error("bad_args", "query: нужны from и to (мс)", null)
                    return
                }
                scope.launch {
                    val answer = try {
                        if (healthConnectAvailable()) queryHealthConnect(from, to) else querySensor(from, to)
                    } catch (e: Exception) {
                        // SecurityException (нет разрешения), RemoteException, IllegalState — для Dart это «нет данных».
                        Log.w(TAG, "query failed", e)
                        null
                    }
                    result.success(answer)
                }
            }
            else -> result.notImplemented()
        }
    }

    // ---------- Разрешения ----------

    private fun requestPermission(result: MethodChannel.Result) {
        if (pendingPermission != null) {
            result.error("busy", "Запрос разрешения уже идёт", null)
            return
        }
        if (healthConnectAvailable()) {
            scope.launch {
                val granted = try {
                    client().permissionController.getGrantedPermissions()
                } catch (e: Exception) {
                    Log.w(TAG, "getGrantedPermissions failed", e)
                    emptySet()
                }
                if (granted.contains(STEPS_PERMISSION)) {
                    result.success(true)
                } else {
                    pendingPermission = result
                    try {
                        healthPermissionLauncher.launch(HEALTH_PERMISSIONS)
                    } catch (e: Exception) {
                        Log.w(TAG, "health permission launch failed", e)
                        finishPermission(false)
                    }
                }
            }
            return
        }
        if (stepSensor() == null) {
            result.success(false)
            return
        }
        if (sensorPermissionGranted()) {
            result.success(true)
            return
        }
        pendingPermission = result
        try {
            sensorPermissionLauncher.launch(Manifest.permission.ACTIVITY_RECOGNITION)
        } catch (e: Exception) {
            Log.w(TAG, "sensor permission launch failed", e)
            finishPermission(false)
        }
    }

    private fun finishPermission(granted: Boolean) {
        val pending = pendingPermission ?: return
        pendingPermission = null
        pending.success(granted)
    }

    private fun sensorPermissionGranted(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACTIVITY_RECOGNITION) ==
            PackageManager.PERMISSION_GRANTED

    // ---------- Health Connect ----------

    private fun healthConnectAvailable(): Boolean =
        try {
            HealthConnectClient.getSdkStatus(context) == HealthConnectClient.SDK_AVAILABLE
        } catch (e: Exception) {
            false
        }

    private fun client(): HealthConnectClient = HealthConnectClient.getOrCreate(context)

    private suspend fun queryHealthConnect(fromMs: Long, toMs: Long): Map<String, Any?>? {
        if (toMs <= fromMs) return null
        val hc = client()
        val granted = hc.permissionController.getGrantedPermissions()
        if (!granted.contains(STEPS_PERMISSION)) return null
        // Метрику без разрешения запрашивать нельзя (SecurityException) — берём только разрешённые.
        val metrics = mutableSetOf<AggregateMetric<*>>(StepsRecord.COUNT_TOTAL)
        val withDistance = granted.contains(DISTANCE_PERMISSION)
        val withFloors = granted.contains(FLOORS_PERMISSION)
        if (withDistance) metrics.add(DistanceRecord.DISTANCE_TOTAL)
        if (withFloors) metrics.add(FloorsClimbedRecord.FLOORS_CLIMBED_TOTAL)
        val response = hc.aggregate(
            AggregateRequest(
                metrics = metrics,
                timeRangeFilter = TimeRangeFilter.between(Instant.ofEpochMilli(fromMs), Instant.ofEpochMilli(toMs)),
            )
        )
        val steps: Long = response[StepsRecord.COUNT_TOTAL] ?: 0L
        val distance: Double? = if (withDistance) response[DistanceRecord.DISTANCE_TOTAL]?.inMeters else null
        val floors: Double? = if (withFloors) response[FloorsClimbedRecord.FLOORS_CLIMBED_TOTAL] else null
        return mapOf(
            "steps" to steps.toInt(),
            "distanceM" to distance,
            "floors" to floors?.toInt(),
        )
    }

    // ---------- Датчик TYPE_STEP_COUNTER (фолбэк без Health Connect) ----------

    private fun stepSensor(): Sensor? {
        val manager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager ?: return null
        return manager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    }

    /**
     * Датчик считает шаги с перезагрузки, истории у него нет. Поэтому отвечаем только за «сегодня»:
     * база дня (значение счётчика при первом опросе за день) хранится в SharedPreferences,
     * перезагрузка (счётчик стал меньше) — накопленное переносится в offset.
     * Шаги до первого опроса за день не учитываются (известное ограничение).
     */
    private suspend fun querySensor(fromMs: Long, toMs: Long): Map<String, Any?>? {
        if (toMs <= fromMs || !sensorPermissionGranted()) return null
        val zone = ZoneId.systemDefault()
        val today = LocalDate.now(zone)
        val fromDay = Instant.ofEpochMilli(fromMs).atZone(zone).toLocalDate()
        if (fromDay != today) return null
        val sensor = stepSensor() ?: return null
        val counter: Long = readCounter(sensor)?.toLong()
            ?: prefs.getLong(KEY_LAST, -1L).takeIf { it >= 0L }
            ?: return null

        val todayKey = today.toString()
        var base = prefs.getLong(KEY_BASE, counter)
        var offset = prefs.getLong(KEY_OFFSET, 0L)
        val last = prefs.getLong(KEY_LAST, counter)
        if (prefs.getString(KEY_DAY, null) != todayKey) {
            base = counter
            offset = 0L
        } else if (counter < last) {
            // Перезагрузка: счётчик начался с нуля.
            offset += last - base
            base = 0L
        }
        prefs.edit()
            .putString(KEY_DAY, todayKey)
            .putLong(KEY_BASE, base)
            .putLong(KEY_OFFSET, offset)
            .putLong(KEY_LAST, counter)
            .apply()
        val steps = (offset + counter - base).coerceAtLeast(0L)
        return mapOf("steps" to steps.toInt(), "distanceM" to null, "floors" to null)
    }

    /** Текущее значение счётчика: первое событие после подписки (обычно приходит сразу), ждём до 3 с. */
    private suspend fun readCounter(sensor: Sensor): Float? {
        val manager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager ?: return null
        return withTimeoutOrNull(3000L) {
            suspendCancellableCoroutine<Float> { cont ->
                val listener = object : SensorEventListener {
                    override fun onSensorChanged(event: SensorEvent) {
                        manager.unregisterListener(this)
                        if (cont.isActive) cont.resume(event.values[0])
                    }

                    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                }
                manager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
                cont.invokeOnCancellation { manager.unregisterListener(listener) }
            }
        }
    }

    companion object {
        const val NAME = "sistema/steps"
        private const val TAG = "StepCounterChannel"
        private const val PREFS = "sistema_steps"
        private const val KEY_DAY = "day"
        private const val KEY_BASE = "base"
        private const val KEY_OFFSET = "offset"
        private const val KEY_LAST = "last"

        private val STEPS_PERMISSION = HealthPermission.getReadPermission(StepsRecord::class)
        private val DISTANCE_PERMISSION = HealthPermission.getReadPermission(DistanceRecord::class)
        private val FLOORS_PERMISSION = HealthPermission.getReadPermission(FloorsClimbedRecord::class)
        private val HEALTH_PERMISSIONS = setOf(STEPS_PERMISSION, DISTANCE_PERMISSION, FLOORS_PERMISSION)
    }
}
