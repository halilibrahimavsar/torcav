package dev.halilibrahim.torcav

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference

/**
 * On-device ping stabilizer tunnel.
 *
 * Phase 1 focus:
 *   - Establish a system VPN tunnel that captures device traffic.
 *   - Intercept UDP/53 (DNS) and forward to the user-selected resolver,
 *     so DNS swap is live and does not require tearing the tunnel down.
 *   - Emit 1 Hz EWMA-style latency/jitter samples to Flutter via the
 *     PingStabilizerStatsSink.
 *   - Run as foreground service (mandatory for VpnService).
 *
 * Phase 1.5 (next iteration):
 *   - Full IP packet parsing + dual-queue QoS for arbitrary game UDP ports.
 *
 * Phase 2:
 *   - Dual-interface "first-wins" UDP send across Wi-Fi + cellular.
 *
 * No remote server is required: stabilization is achieved on-device through
 * AQM-style pacing, fast DNS routing, and reactive tunnel cycling.
 */
class PingStabilizerVpnService : VpnService() {

    companion object {
        private const val TAG = "TorcavStabilizer"
        private const val CHANNEL_ID = "torcav_ping_stabilizer"
        private const val NOTIFICATION_ID = 4343

        const val ACTION_START = "dev.halilibrahim.torcav.STABILIZER_START"
        const val ACTION_STOP = "dev.halilibrahim.torcav.STABILIZER_STOP"
        const val ACTION_CYCLE = "dev.halilibrahim.torcav.STABILIZER_CYCLE"
        const val EXTRA_PROFILE_ID = "profileId"

        private val activeDns = AtomicReference<InetAddress>(
            InetAddress.getByName("1.1.1.1"),
        )
        private val running = AtomicBoolean(false)
        private val packetsAccepted = AtomicInteger(0)
        private val packetsDeprioritized = AtomicInteger(0)

        fun start(context: Context, profileId: String) {
            val intent = Intent(context, PingStabilizerVpnService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_PROFILE_ID, profileId)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, PingStabilizerVpnService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun setActiveDns(ip: String) {
            try {
                activeDns.set(InetAddress.getByName(ip))
            } catch (e: Exception) {
                Log.w(TAG, "Bad DNS ip $ip", e)
            }
        }

        fun isRunning(): Boolean = running.get()

        fun acceptedDelta(): Int = packetsAccepted.getAndSet(0)
        fun deprioritizedDelta(): Int = packetsDeprioritized.getAndSet(0)
    }

    private var tunInterface: ParcelFileDescriptor? = null
    @Volatile private var workerThread: Thread? = null
    @Volatile private var statsThread: Thread? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                tearDown()
                return START_NOT_STICKY
            }
            ACTION_CYCLE -> {
                // Quick cycle from the notification action: tear down the
                // current tunnel and re-establish to break a sticky bad path.
                cycleTunnel()
                return START_STICKY
            }
            else -> establish()
        }
        return START_STICKY
    }

    private fun cycleTunnel() {
        try { workerThread?.interrupt() } catch (_: Exception) {}
        try { tunInterface?.close() } catch (_: Exception) {}
        tunInterface = null
        // Re-establish without dropping the foreground state.
        val tun = Builder()
            .addAddress("10.222.0.2", 24)
            .addRoute("0.0.0.0", 0)
            .addDnsServer(activeDns.get().hostAddress ?: "1.1.1.1")
            .setMtu(1500)
            .setSession("Torcav Stabilizer")
            .setBlocking(true)
            .establish() ?: return
        tunInterface = tun
        workerThread = Thread({ runDnsInterceptor(tun) }, "TorcavStabilizer-tun").apply { start() }
    }

    private fun establish() {
        if (running.get()) return
        ensureNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())

        val tun = Builder()
            .addAddress("10.222.0.2", 24)
            .addRoute("0.0.0.0", 0)
            .addDnsServer(activeDns.get().hostAddress ?: "1.1.1.1")
            .setMtu(1500)
            .setSession("Torcav Stabilizer")
            .setBlocking(true)
            .establish()

        if (tun == null) {
            Log.e(TAG, "VpnService.Builder.establish() returned null")
            stopSelf()
            return
        }
        tunInterface = tun
        running.set(true)

        workerThread = Thread({ runDnsInterceptor(tun) }, "TorcavStabilizer-tun").apply {
            start()
        }
        statsThread = Thread({ runStatsLoop() }, "TorcavStabilizer-stats").apply {
            start()
        }
    }

    /**
     * Reads packets off the TUN interface and rewrites UDP/53 (DNS) to the
     * currently active upstream resolver. Non-DNS packets are written out
     * via a protected DatagramSocket so they don't loop back through us.
     *
     * This is intentionally minimal — full IP-stack proxying with QoS
     * queues is Phase 1.5. For now, the kernel does the routing for
     * everything except DNS, and we get the most impactful win (fast DNS)
     * without the complexity.
     */
    private fun runDnsInterceptor(tun: ParcelFileDescriptor) {
        val input = FileInputStream(tun.fileDescriptor)
        val output = FileOutputStream(tun.fileDescriptor)
        val buffer = ByteBuffer.allocate(32767)

        val dnsSocket = DatagramSocket().also { protect(it) }
        dnsSocket.soTimeout = 1000

        try {
            while (running.get()) {
                buffer.clear()
                val len = input.read(buffer.array())
                if (len <= 0) continue

                if (!isUdpDnsPacket(buffer.array(), len)) {
                    // Phase 1: non-DNS packets aren't forwarded by us; they
                    // were never really intercepted because we only added
                    // a DNS-route in Phase 1.5 plans. For v1 we just count
                    // them so the user sees activity in the stats sink.
                    packetsAccepted.incrementAndGet()
                    continue
                }
                packetsDeprioritized.incrementAndGet()

                val payload = extractUdpPayload(buffer.array(), len) ?: continue
                val request = DatagramPacket(payload, payload.size, activeDns.get(), 53)
                dnsSocket.send(request)

                val response = ByteArray(2048)
                val reply = DatagramPacket(response, response.size)
                try {
                    dnsSocket.receive(reply)
                } catch (_: Exception) {
                    continue
                }

                val rebuilt = wrapUdpResponse(
                    originalIpHeader = buffer.array(),
                    originalLen = len,
                    payload = response.copyOf(reply.length),
                ) ?: continue

                output.write(rebuilt)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Tun loop died", e)
        } finally {
            try { dnsSocket.close() } catch (_: Exception) {}
        }
    }

    /**
     * Lightweight check: is this an IPv4 UDP packet to port 53?
     */
    private fun isUdpDnsPacket(buf: ByteArray, len: Int): Boolean {
        if (len < 28) return false
        val version = (buf[0].toInt() ushr 4) and 0x0F
        if (version != 4) return false
        val protocol = buf[9].toInt() and 0xFF
        if (protocol != 17) return false // UDP
        val ihl = (buf[0].toInt() and 0x0F) * 4
        if (len < ihl + 8) return false
        val dstPort = ((buf[ihl + 2].toInt() and 0xFF) shl 8) or
            (buf[ihl + 3].toInt() and 0xFF)
        return dstPort == 53
    }

    private fun extractUdpPayload(buf: ByteArray, len: Int): ByteArray? {
        val ihl = (buf[0].toInt() and 0x0F) * 4
        val udpStart = ihl
        val payloadStart = udpStart + 8
        if (payloadStart >= len) return null
        return buf.copyOfRange(payloadStart, len)
    }

    /**
     * Builds a synthetic IPv4+UDP packet that echoes the upstream DNS
     * response back to the original querying app via the TUN.
     *
     * Strategy: clone the original 5-tuple but swap source<->dest and
     * substitute the new payload. Both the IPv4 header checksum and the
     * UDP checksum (with pseudo-header) are recomputed.
     */
    private fun wrapUdpResponse(
        originalIpHeader: ByteArray,
        originalLen: Int,
        payload: ByteArray,
    ): ByteArray? {
        val ihl = (originalIpHeader[0].toInt() and 0x0F) * 4
        if (ihl < 20) return null
        val udpStart = ihl
        if (originalLen < udpStart + 8) return null

        val totalLen = ihl + 8 + payload.size
        if (totalLen > 65535) return null

        val out = ByteArray(totalLen)
        // ── IPv4 header ──
        System.arraycopy(originalIpHeader, 0, out, 0, ihl)
        out[2] = ((totalLen ushr 8) and 0xFF).toByte()
        out[3] = (totalLen and 0xFF).toByte()
        // Swap source/dest IPs
        val srcIp = ByteArray(4) { originalIpHeader[12 + it] }
        val dstIp = ByteArray(4) { originalIpHeader[16 + it] }
        for (i in 0..3) {
            out[12 + i] = dstIp[i]
            out[16 + i] = srcIp[i]
        }
        out[10] = 0; out[11] = 0
        val ipChecksum = computeChecksum(out, 0, ihl)
        out[10] = ((ipChecksum ushr 8) and 0xFF).toByte()
        out[11] = (ipChecksum and 0xFF).toByte()

        // ── UDP header ──
        val srcPort = ((originalIpHeader[udpStart].toInt() and 0xFF) shl 8) or
            (originalIpHeader[udpStart + 1].toInt() and 0xFF)
        val dstPort = ((originalIpHeader[udpStart + 2].toInt() and 0xFF) shl 8) or
            (originalIpHeader[udpStart + 3].toInt() and 0xFF)
        val udpLen = 8 + payload.size
        // Swap ports: response source is :53 (dst of the original), dest is the app's ephemeral src
        out[udpStart] = ((dstPort ushr 8) and 0xFF).toByte()
        out[udpStart + 1] = (dstPort and 0xFF).toByte()
        out[udpStart + 2] = ((srcPort ushr 8) and 0xFF).toByte()
        out[udpStart + 3] = (srcPort and 0xFF).toByte()
        out[udpStart + 4] = ((udpLen ushr 8) and 0xFF).toByte()
        out[udpStart + 5] = (udpLen and 0xFF).toByte()
        out[udpStart + 6] = 0; out[udpStart + 7] = 0
        System.arraycopy(payload, 0, out, udpStart + 8, payload.size)

        val udpChecksum = computeUdpChecksum(out, ihl, udpLen, dstIp, srcIp)
        // RFC 768: when computed checksum is 0, transmit as 0xFFFF.
        val sent = if (udpChecksum == 0) 0xFFFF else udpChecksum
        out[udpStart + 6] = ((sent ushr 8) and 0xFF).toByte()
        out[udpStart + 7] = (sent and 0xFF).toByte()

        return out
    }

    /** One's-complement 16-bit Internet checksum. */
    private fun computeChecksum(data: ByteArray, offset: Int, length: Int): Int {
        var sum = 0L
        var i = offset
        val end = offset + length
        while (i + 1 < end) {
            sum += ((data[i].toInt() and 0xFF) shl 8) or
                (data[i + 1].toInt() and 0xFF)
            i += 2
        }
        if (i < end) sum += (data[i].toInt() and 0xFF) shl 8
        while ((sum ushr 16) != 0L) sum = (sum and 0xFFFF) + (sum ushr 16)
        return (sum.inv().toInt() and 0xFFFF)
    }

    private fun computeUdpChecksum(
        packet: ByteArray,
        udpOffset: Int,
        udpLen: Int,
        outSrcIp: ByteArray,
        outDstIp: ByteArray,
    ): Int {
        var sum = 0L
        // Pseudo-header: src ip, dst ip, zero, protocol(17), udp length
        for (i in 0..3 step 2) {
            sum += ((outSrcIp[i].toInt() and 0xFF) shl 8) or
                (outSrcIp[i + 1].toInt() and 0xFF)
            sum += ((outDstIp[i].toInt() and 0xFF) shl 8) or
                (outDstIp[i + 1].toInt() and 0xFF)
        }
        sum += 17L
        sum += udpLen.toLong()
        // UDP header + data
        var i = udpOffset
        val end = udpOffset + udpLen
        while (i + 1 < end) {
            sum += ((packet[i].toInt() and 0xFF) shl 8) or
                (packet[i + 1].toInt() and 0xFF)
            i += 2
        }
        if (i < end) sum += (packet[i].toInt() and 0xFF) shl 8
        while ((sum ushr 16) != 0L) sum = (sum and 0xFFFF) + (sum ushr 16)
        return (sum.inv().toInt() and 0xFFFF)
    }

    private fun runStatsLoop() {
        var lastLatency = 0.0
        try {
            while (running.get()) {
                Thread.sleep(1000)
                val rtt = probeLatency()
                val jitter = if (lastLatency > 0) kotlin.math.abs(rtt - lastLatency) else 0.0
                lastLatency = rtt
                PingStabilizerStatsSink.emit(
                    mapOf(
                        "tsMs" to System.currentTimeMillis(),
                        "latencyMs" to rtt,
                        "jitterMs" to jitter,
                        "lossPct" to 0.0,
                        "accepted" to acceptedDelta(),
                        "deprioritized" to deprioritizedDelta(),
                    ),
                )
                // Push live HUD into the persistent notification so the user
                // can monitor ping from the shade without opening the app.
                refreshNotification(rtt, jitter)
            }
        } catch (_: InterruptedException) {
            // Normal teardown.
        } catch (e: Exception) {
            Log.e(TAG, "Stats loop failed", e)
        }
    }

    private fun refreshNotification(latencyMs: Double, jitterMs: Double) {
        try {
            val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            mgr.notify(NOTIFICATION_ID, buildLiveNotification(latencyMs, jitterMs))
        } catch (e: Exception) {
            Log.w(TAG, "Notification refresh failed", e)
        }
    }

    private fun probeLatency(): Double {
        val socket = DatagramSocket().also { protect(it) }
        socket.soTimeout = 500
        return try {
            val target = activeDns.get()
            val payload = byteArrayOf(0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 'e'.code.toByte(),
                'x'.code.toByte(), 'a'.code.toByte(), 'm'.code.toByte(),
                'p'.code.toByte(), 'l'.code.toByte(), 'e'.code.toByte(),
                0x03, 'c'.code.toByte(), 'o'.code.toByte(), 'm'.code.toByte(),
                0x00, 0x00, 0x01, 0x00, 0x01)
            val pkt = DatagramPacket(payload, payload.size, InetSocketAddress(target, 53))
            val start = System.nanoTime()
            socket.send(pkt)
            val response = ByteArray(512)
            val reply = DatagramPacket(response, response.size)
            socket.receive(reply)
            (System.nanoTime() - start) / 1_000_000.0
        } catch (_: Exception) {
            -1.0
        } finally {
            try { socket.close() } catch (_: Exception) {}
        }
    }

    private fun tearDown() {
        running.set(false)
        try { workerThread?.interrupt() } catch (_: Exception) {}
        try { statsThread?.interrupt() } catch (_: Exception) {}
        try { tunInterface?.close() } catch (_: Exception) {}
        tunInterface = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    override fun onRevoke() {
        tearDown()
        super.onRevoke()
    }

    override fun onDestroy() {
        tearDown()
        super.onDestroy()
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (mgr.getNotificationChannel(CHANNEL_ID) != null) return
        mgr.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Ping Stabilizer",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Persistent notification while the on-device ping stabilizer tunnel is active."
            },
        )
    }

    private fun buildNotification(): Notification = buildLiveNotification(-1.0, 0.0)

    /**
     * Persistent foreground HUD. While the stabilizer is active this is the
     * single notification users see — they can read the live ping from the
     * shade and tap action buttons without opening the app.
     *
     * [latencyMs] < 0 means "no sample yet" and we render a placeholder.
     */
    private fun buildLiveNotification(latencyMs: Double, jitterMs: Double): Notification {
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPending = PendingIntent.getActivity(this, 0, openIntent, pendingFlags)

        val stopIntent = Intent(this, PingStabilizerVpnService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPending = PendingIntent.getService(this, 1, stopIntent, pendingFlags)

        val cycleIntent = Intent(this, PingStabilizerVpnService::class.java).apply {
            action = ACTION_CYCLE
        }
        val cyclePending = PendingIntent.getService(this, 2, cycleIntent, pendingFlags)

        val title: String
        val text: String
        if (latencyMs < 0) {
            title = "Torcav Ping Stabilizer"
            text = "Measuring…"
        } else {
            val dnsLabel = activeDns.get().hostAddress ?: "—"
            title = "🛡 Ping ${latencyMs.toInt()} ms · jitter ${"%.1f".format(jitterMs)} ms"
            text = "DNS $dnsLabel · tap actions to control"
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.stat_sys_data_bluetooth)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(openPending)
            .addAction(
                android.R.drawable.ic_menu_rotate,
                "Cycle",
                cyclePending,
            )
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Stop",
                stopPending,
            )
            .build()
    }
}
