package com.sistema.sistema

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

// Канал финансов Android (SPEC §8.7): "sistema/bank" (методы) и "sistema/bank/events" (живые входящие).
//   isListenerEnabled → bool; openListenerSettings; setSources({packages, smsSenders});
//   drain → [{channel, sender, body, receivedAt}]; readSmsHistory({since}) → то же (нужен READ_SMS);
//   isPackageInstalled({package}) → bool.
class BankChannel(private val context: Context, messenger: BinaryMessenger) {
    private val main = Handler(Looper.getMainLooper())
    private val methods = MethodChannel(messenger, CHANNEL)
    private val events = EventChannel(messenger, EVENTS)

    init {
        methods.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isListenerEnabled" -> result.success(isListenerEnabled())
                    "openListenerSettings" -> {
                        val i = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(i)
                        result.success(null)
                    }
                    "setSources" -> {
                        val pk = call.argument<List<String>>("packages") ?: emptyList()
                        val sn = call.argument<List<String>>("smsSenders") ?: emptyList()
                        BankPrefs.setSources(context, pk, sn)
                        result.success(null)
                    }
                    "drain" -> result.success(BankPrefs.drain(context))
                    "readSmsHistory" -> {
                        val since = (call.argument<Number>("since") ?: 0).toLong()
                        Thread {
                            val list = try { readSms(since) } catch (_: Throwable) { emptyList() }
                            main.post { result.success(list) }
                        }.start()
                    }
                    "isPackageInstalled" -> {
                        val p = call.argument<String>("package") ?: ""
                        result.success(isInstalled(p))
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Throwable) {
                result.error("bank", e.message, null)
            }
        }
        events.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                BankPrefs.live = { item -> main.post { sink?.success(item) } }
            }

            override fun onCancel(arguments: Any?) {
                BankPrefs.live = null
            }
        })
    }

    fun dispose() {
        BankPrefs.live = null
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
    }

    private fun isListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners") ?: return false
        val me = ComponentName(context, BankNotificationListener::class.java)
        return flat.split(":").any { ComponentName.unflattenFromString(it) == me }
    }

    private fun isInstalled(pkg: String): Boolean {
        if (pkg.isBlank()) return false
        return try {
            context.packageManager.getPackageInfo(pkg, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun readSms(since: Long): List<Map<String, Any?>> {
        if (context.checkSelfPermission(Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) return emptyList()
        val out = ArrayList<Map<String, Any?>>()
        val cursor = context.contentResolver.query(
            Uri.parse("content://sms/inbox"),
            arrayOf("address", "body", "date"),
            "date > ?",
            arrayOf(since.toString()),
            "date DESC",
        ) ?: return out
        cursor.use {
            while (it.moveToNext() && out.size < 500) {
                val addr = it.getString(0) ?: continue
                if (!BankPrefs.senderEnabled(context, addr)) continue
                out.add(mapOf("channel" to "sms", "sender" to addr, "body" to (it.getString(1) ?: ""), "receivedAt" to it.getLong(2)))
            }
        }
        return out
    }

    private companion object {
        const val CHANNEL = "sistema/bank"
        const val EVENTS = "sistema/bank/events"
    }
}
