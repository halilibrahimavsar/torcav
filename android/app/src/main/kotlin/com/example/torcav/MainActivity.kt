package com.example.torcav

import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val WIFI_EXTENDED_CHANNEL = "torcav/wifi_extended"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIFI_EXTENDED_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getExtendedResults" -> {
                    try {
                        result.success(getExtendedWifiResults())
                    } catch (e: Exception) {
                        result.error("WIFI_EXTENDED_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun getExtendedWifiResults(): List<Map<String, Any?>> {
        val wifiManager =
            applicationContext.getSystemService(WIFI_SERVICE) as WifiManager

        val scanResults = wifiManager.scanResults ?: return emptyList()

        return scanResults.map { sr ->
            val map = mutableMapOf<String, Any?>()
            map["bssid"] = sr.BSSID?.uppercase()
            map["capabilities"] = sr.capabilities
            map["timestampUs"] = sr.timestamp

            // channelWidth: API 23+ (Android 6.0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                map["channelWidth"] = sr.channelWidth
            } else {
                map["channelWidth"] = null
            }

            // wifiStandard: API 30+ (Android 11)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                map["wifiStandard"] = sr.wifiStandard
            } else {
                map["wifiStandard"] = null
            }

            // apMldMacAddress: API 33+ (Android 13, Wi-Fi 7)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                map["apMldMac"] = sr.apMldMacAddress?.toString()
            } else {
                map["apMldMac"] = null
            }

            map
        }
    }
}
