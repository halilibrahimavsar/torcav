package dev.halilibrahim.torcav

import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.text.TextUtils
import dev.halilibrahim.torcav.ar.ArScenePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val WIFI_EXTENDED_CHANNEL = "torcav/wifi_extended"
    private val MONITORING_CHANNEL = "torcav/background_monitor"
    private val SPEED_PROBE_CHANNEL = "torcav/speed_probe"

    private var pingStabilizerHandler: PingStabilizerChannelHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        ArScenePlugin().register(
            flutterEngine.dartExecutor.binaryMessenger,
            flutterEngine.platformViewsController.registry,
        )

        pingStabilizerHandler = PingStabilizerChannelHandler(this, applicationContext).also {
            it.register(flutterEngine.dartExecutor.binaryMessenger)
        }

        CellularChannelHandler(applicationContext)
            .register(flutterEngine.dartExecutor.binaryMessenger)

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
                "getConnectedSignal" -> {
                    try {
                        result.success(getConnectedSignal())
                    } catch (e: Exception) {
                        result.error("WIFI_CONNECTED_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MONITORING_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val tickMs = (call.argument<Number>("tickMs") ?: 1_800_000L).toLong()
                    val strings =
                        call.argument<Map<String, String>>("strings") ?: emptyMap()
                    MonitoringWorker.schedule(applicationContext, tickMs, strings)
                    result.success(true)
                }
                "stop" -> {
                    MonitoringWorker.cancel(applicationContext)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SPEED_PROBE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val intervalMs =
                        (call.argument<Number>("intervalMs") ?: 43_200_000L).toLong()
                    SpeedProbeWorker.schedule(applicationContext, intervalMs)
                    result.success(true)
                }
                "stop" -> {
                    SpeedProbeWorker.cancel(applicationContext)
                    result.success(true)
                }
                "drain" -> {
                    result.success(SpeedProbeWorker.drain(applicationContext))
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (pingStabilizerHandler?.onActivityResult(requestCode, resultCode) == true) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
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

            // channelWidth + centerFreq0: API 23+ (Android 6.0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                map["channelWidth"] = sr.channelWidth
                // Center of the full 40/80/160 MHz block; ScanResult.frequency
                // is only the primary 20 MHz channel. 0 when not applicable.
                map["centerFreq0"] = sr.centerFreq0
            } else {
                map["channelWidth"] = null
                map["centerFreq0"] = null
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

    @Suppress("DEPRECATION")
    private fun getConnectedSignal(): Map<String, Any?>? {
        val wifiManager =
            applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        val info = wifiManager.connectionInfo ?: return null
        val rawBssid = info.bssid ?: return null
        if (rawBssid.isBlank() || rawBssid == "02:00:00:00:00:00") {
            return null
        }

        val normalizedSsid =
            info.ssid
                ?.trim()
                ?.removePrefix("\"")
                ?.removeSuffix("\"")
                ?.takeUnless { TextUtils.isEmpty(it) || it == "<unknown ssid>" }
                ?: ""

        return mapOf(
            "ssid" to normalizedSsid,
            "bssid" to rawBssid.uppercase(),
            "rssi" to info.rssi,
            "frequency" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) info.frequency else 0,
            "linkSpeedMbps" to info.linkSpeed,
            "timestampMs" to System.currentTimeMillis(),
        )
    }
}
