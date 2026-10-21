package com.sistema.sistema

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
    }

    private companion object {
        const val CHANNEL = "sistema/platform"
    }
}
