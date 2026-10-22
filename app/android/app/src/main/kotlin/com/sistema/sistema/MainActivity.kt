package com.sistema.sistema

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity — для registerForActivityResult (разрешения Health Connect).
class MainActivity : FlutterFragmentActivity() {
    private var steps: StepCounterChannel? = null
    private var audio: AudioChannel? = null
    private var blocker: BlockerChannel? = null
    private var alarm: AlarmChannel? = null
    private var bank: BankChannel? = null
    private var overlay: OverlayChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // На Android профиля подписи нет.
                    "getProvisioningInfo" -> result.success(mapOf<String, Any?>("expiresAt" to null))
                    else -> result.notImplemented()
                }
            }
        steps = StepCounterChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        audio = AudioChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        // Этап 7: блокировка приложений, будильник-квест.
        blocker = BlockerChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        alarm = AlarmChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        bank = BankChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        // Этап 8: персонаж поверх других приложений.
        overlay = OverlayChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        alarm?.handleIntent(intent)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        audio?.dispose()
        audio = null
        blocker?.dispose()
        blocker = null
        alarm?.dispose()
        alarm = null
        bank?.dispose()
        bank = null
        overlay?.dispose()
        overlay = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private companion object {
        const val CHANNEL = "sistema/platform"
    }
}
