package com.sistema.sistema

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity — для registerForActivityResult (разрешения Health Connect).
class MainActivity : FlutterFragmentActivity() {
    private var steps: StepCounterChannel? = null

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
    }

    private companion object {
        const val CHANNEL = "sistema/platform"
    }
}
