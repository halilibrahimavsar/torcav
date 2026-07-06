package dev.halilibrahim.torcav

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress

/**
 * MethodChannel + EventChannel handler for the Ping Stabilizer feature.
 *
 * Wires:
 *   - `torcav/ping_stabilizer` (method): prepare, isPrepared, start, stop,
 *     setDns, benchmarkDns
 *   - `torcav/ping_stabilizer/stats` (event): 1 Hz JitterSample stream
 */
class PingStabilizerChannelHandler(
    private val activity: Activity,
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val METHOD_CHANNEL = "torcav/ping_stabilizer"
        const val EVENT_CHANNEL = "torcav/ping_stabilizer/stats"
        const val REQ_VPN = 0xCA7E
    }

    @Volatile private var pendingPermission: MethodChannel.Result? = null

    fun register(messenger: io.flutter.plugin.common.BinaryMessenger) {
        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler(this)
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(PingStabilizerStatsSink)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isPrepared" -> {
                val intent = VpnService.prepare(context)
                result.success(intent == null)
            }
            "prepare" -> {
                val intent = VpnService.prepare(context)
                if (intent == null) {
                    result.success(true)
                } else {
                    pendingPermission?.success(false)
                    pendingPermission = result
                    activity.startActivityForResult(intent, REQ_VPN)
                }
            }
            "start" -> {
                val profileId = call.argument<String>("id") ?: "generic"
                PingStabilizerVpnService.start(context, profileId)
                result.success(true)
            }
            "stop" -> {
                PingStabilizerVpnService.stop(context)
                result.success(null)
            }
            "setDns" -> {
                val ip = call.argument<String>("ip")
                if (ip == null) {
                    result.error("BAD_ARG", "ip required", null)
                } else {
                    PingStabilizerVpnService.setActiveDns(ip)
                    result.success(null)
                }
            }
            "updateConfig" -> {
                // Threshold / auto-switch / candidate list / localized
                // notification strings for the native alert engine. Persisted
                // so a STICKY service restart keeps the user's settings even
                // when the Dart side never comes back.
                val rawCandidates = call.argument<List<Map<String, Any?>>>("candidates")
                val candidates = rawCandidates?.mapNotNull { m ->
                    val ip = m["ip"] as? String ?: return@mapNotNull null
                    val label = m["label"] as? String ?: ip
                    ip to label
                }
                @Suppress("UNCHECKED_CAST")
                val strings = call.argument<Map<String, String>>("strings")
                StabilizerConfig.update(
                    context,
                    jitterMs = call.argument<Number>("jitterThresholdMs")?.toDouble(),
                    autoDns = call.argument<Boolean>("autoSwitchDns"),
                    newCandidates = candidates,
                    newStrings = strings,
                )
                result.success(null)
            }
            "benchmarkDns" -> {
                val raw = call.argument<List<Map<String, Any?>>>("candidates") ?: emptyList()
                Thread {
                    val benched = raw.map { m ->
                        val ip = m["ip"] as? String ?: ""
                        val label = m["label"] as? String ?: ""
                        val rtt = if (ip.isNotEmpty()) probeDns(ip) else -1.0
                        mapOf<String, Any?>(
                            "ip" to ip,
                            "label" to label,
                            "rttMs" to if (rtt < 0) null else rtt,
                        )
                    }
                    Handler(Looper.getMainLooper()).post {
                        result.success(benched)
                    }
                }.start()
            }
            else -> result.notImplemented()
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQ_VPN) return false
        val granted = resultCode == Activity.RESULT_OK
        pendingPermission?.success(granted)
        pendingPermission = null
        return true
    }

    /**
     * Synchronous DNS RTT probe — sends a tiny `A example.com` query to the
     * candidate resolver and times the response. Returns -1 on failure.
     */
    private fun probeDns(ip: String): Double {
        val socket = DatagramSocket()
        socket.soTimeout = 800
        return try {
            val payload = byteArrayOf(
                0x12, 0x34, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x07, 'e'.code.toByte(), 'x'.code.toByte(), 'a'.code.toByte(),
                'm'.code.toByte(), 'p'.code.toByte(), 'l'.code.toByte(),
                'e'.code.toByte(),
                0x03, 'c'.code.toByte(), 'o'.code.toByte(), 'm'.code.toByte(),
                0x00, 0x00, 0x01, 0x00, 0x01,
            )
            val target = InetAddress.getByName(ip)
            val pkt = DatagramPacket(payload, payload.size, InetSocketAddress(target, 53))
            val start = System.nanoTime()
            socket.send(pkt)
            val resp = ByteArray(512)
            socket.receive(DatagramPacket(resp, resp.size))
            (System.nanoTime() - start) / 1_000_000.0
        } catch (_: Exception) {
            -1.0
        } finally {
            try { socket.close() } catch (_: Exception) {}
        }
    }
}
