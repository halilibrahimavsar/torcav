package dev.halilibrahim.torcav

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

/**
 * Live configuration for the native stabilizer alert engine.
 *
 * The Dart side pushes updates through the `updateConfig` method-channel
 * call whenever the user changes a setting; values are persisted to
 * SharedPreferences so a START_STICKY service restart (process death while
 * the tunnel is up) comes back with the user's thresholds and localized
 * notification strings instead of factory defaults.
 */
object StabilizerConfig {
    private const val PREFS = "torcav_stabilizer"
    private const val KEY_JITTER = "jitterThresholdMs"
    private const val KEY_AUTO_DNS = "autoSwitchDns"
    private const val KEY_CANDIDATES = "candidates"
    private const val STRING_PREFIX = "str_"

    @Volatile var jitterThresholdMs: Double = 30.0
        private set
    @Volatile var autoSwitchDns: Boolean = false
        private set

    /** ip → human label, in Dart-supplied priority order. */
    @Volatile var candidates: List<Pair<String, String>> = defaultCandidates()
        private set

    @Volatile private var strings: Map<String, String> = emptyMap()

    private fun defaultCandidates() = listOf(
        "1.1.1.1" to "Cloudflare",
        "8.8.8.8" to "Google",
        "9.9.9.9" to "Quad9",
    )

    /** Localized string with English fallback so notifications never render blank. */
    fun s(key: String, fallback: String): String = strings[key] ?: fallback

    fun update(
        context: Context,
        jitterMs: Double?,
        autoDns: Boolean?,
        newCandidates: List<Pair<String, String>>?,
        newStrings: Map<String, String>?,
    ) {
        jitterMs?.let { jitterThresholdMs = it }
        autoDns?.let { autoSwitchDns = it }
        newCandidates?.takeIf { it.isNotEmpty() }?.let { candidates = it }
        newStrings?.takeIf { it.isNotEmpty() }?.let { strings = it }
        persist(context)
    }

    fun load(context: Context) {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        jitterThresholdMs = Double.fromBits(
            p.getLong(KEY_JITTER, jitterThresholdMs.toRawBits()),
        )
        autoSwitchDns = p.getBoolean(KEY_AUTO_DNS, autoSwitchDns)
        p.getString(KEY_CANDIDATES, null)?.let { raw ->
            val parsed = raw.split('\n').mapNotNull { line ->
                val idx = line.indexOf('|')
                if (idx <= 0) null else line.substring(0, idx) to line.substring(idx + 1)
            }
            if (parsed.isNotEmpty()) candidates = parsed
        }
        strings = p.all
            .filterKeys { it.startsWith(STRING_PREFIX) }
            .mapNotNull { (k, v) ->
                (v as? String)?.let { k.removePrefix(STRING_PREFIX) to it }
            }
            .toMap()
    }

    private fun persist(context: Context) {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
        p.putLong(KEY_JITTER, jitterThresholdMs.toRawBits())
        p.putBoolean(KEY_AUTO_DNS, autoSwitchDns)
        p.putString(
            KEY_CANDIDATES,
            candidates.joinToString("\n") { (ip, label) -> "$ip|$label" },
        )
        strings.forEach { (k, v) -> p.putString("$STRING_PREFIX$k", v) }
        p.apply()
    }
}

/**
 * Native recommendation engine for the Ping Stabilizer.
 *
 * This used to live in the Flutter `PingStabilizerCubit`, which meant every
 * alert (jitter spike, faster DNS, packet loss) and the auto-DNS-switch
 * feature silently died the moment Android reclaimed the activity process —
 * the exact "notifications stop in the background" failure users reported.
 * The VPN foreground service is the one component guaranteed to be alive
 * while stabilization runs, so the rules are evaluated here.
 *
 * Responsibilities:
 *  - jitter-breach detection over consecutive 1 Hz samples;
 *  - real packet-loss tracking (probe timeouts over a rolling window);
 *  - periodic DNS candidate benchmarking through a [protector]-protected
 *    socket (an unprotected socket would loop through the TUN and be
 *    rewritten to the active resolver, making every candidate measure
 *    identical — see [PingStabilizerVpnService.buildTunnel]);
 *  - posting localized notifications and, when the user opted in,
 *    switching the active DNS without any Dart involvement.
 */
class StabilizerAlertEngine(
    private val context: Context,
    private val protector: (DatagramSocket) -> Boolean,
) {
    companion object {
        private const val TAG = "TorcavAlertEngine"
        private const val CHANNEL_ID = "torcav_stabilizer_alerts"

        private const val ID_JITTER = 4401
        private const val ID_DNS_SUGGEST = 4402
        private const val ID_LOSS = 4403
        private const val ID_DNS_SWITCHED = 4404

        /** Consecutive over-threshold samples before a jitter alert fires. */
        private const val JITTER_BREACH_WINDOW = 3

        /** Clean samples required before a new jitter episode may re-alert. */
        private const val JITTER_RESET_WINDOW = 10

        /** Rolling probe-outcome window for loss percentage (≈1 min @ 1 Hz). */
        private const val LOSS_WINDOW = 60

        /** Minimum filled window before the loss rule is trusted. */
        private const val LOSS_MIN_SAMPLES = 30
        private const val LOSS_ALERT_PCT = 5.0
        private const val LOSS_CLEAR_PCT = 2.0

        /** Seconds between full candidate benchmark passes. */
        private const val BENCH_INTERVAL_MS = 45_000L
        private const val BENCH_TIMEOUT_MS = 800
        private const val BENCH_MIN_PROBES = 3
        private const val BENCH_EWMA_ALPHA = 0.3

        /** A switch/suggestion needs both 1.5× ratio and ≥15 ms absolute win. */
        private const val DNS_RATIO = 1.5
        private const val DNS_MIN_DELTA_MS = 15.0

        /** Floor between two notifications of the same type. */
        private const val REFIRE_COOLDOWN_MS = 10 * 60_000L

        /** Floor between two automatic DNS switches (anti-flap). */
        private const val SWITCH_COOLDOWN_MS = 5 * 60_000L
    }

    // ── Jitter episode state ────────────────────────────────────────────
    private var consecutiveBreaches = 0
    private var cleanSamples = 0
    private var jitterEpisodeActive = false

    // ── Loss window (true = probe timed out) ────────────────────────────
    private val lossWindow = ArrayDeque<Boolean>()
    private var lossEpisodeActive = false

    // ── DNS benchmark state ─────────────────────────────────────────────
    private val candidateEwmaMs = ConcurrentHashMap<String, Double>()
    private val candidateProbeCount = ConcurrentHashMap<String, Int>()
    @Volatile private var benchThread: Thread? = null
    @Volatile private var lastSwitchAtMs = 0L

    private val lastFiredAtMs = HashMap<Int, Long>()

    fun start() {
        ensureChannel()
        benchThread = Thread({ runBenchLoop() }, "TorcavStabilizer-bench").apply {
            isDaemon = true
            start()
        }
    }

    fun stop() {
        try { benchThread?.interrupt() } catch (_: Exception) {}
        benchThread = null
    }

    /**
     * Feed one 1 Hz probe outcome. Returns the current rolling loss
     * percentage so the service can emit it to Flutter.
     */
    fun onSample(jitterMs: Double, lost: Boolean): Double {
        lossWindow.addLast(lost)
        while (lossWindow.size > LOSS_WINDOW) lossWindow.removeFirst()
        val lossPct =
            if (lossWindow.isEmpty()) 0.0
            else lossWindow.count { it } * 100.0 / lossWindow.size

        evaluateJitter(jitterMs, lost)
        evaluateLoss(lossPct)
        return lossPct
    }

    private fun evaluateJitter(jitterMs: Double, lost: Boolean) {
        if (lost) return // timeouts are loss, not jitter
        if (jitterMs > StabilizerConfig.jitterThresholdMs) {
            consecutiveBreaches++
            cleanSamples = 0
        } else {
            consecutiveBreaches = 0
            cleanSamples++
            if (cleanSamples >= JITTER_RESET_WINDOW) jitterEpisodeActive = false
        }
        if (consecutiveBreaches >= JITTER_BREACH_WINDOW && !jitterEpisodeActive) {
            jitterEpisodeActive = true
            if (cooldownOk(ID_JITTER)) {
                val threshold = StabilizerConfig.jitterThresholdMs
                notify(
                    id = ID_JITTER,
                    title = StabilizerConfig.s("jitterTitle", "Jitter spike detected"),
                    body = StabilizerConfig
                        .s(
                            "jitterBody",
                            "Jitter is {jitter} ms (threshold {threshold} ms). " +
                                "Cycling the tunnel may break a sticky bad path.",
                        )
                        .replace("{jitter}", fmt(jitterMs))
                        .replace("{threshold}", fmt(threshold)),
                    withCycleAction = true,
                )
            }
        }
    }

    private fun evaluateLoss(lossPct: Double) {
        if (lossPct < LOSS_CLEAR_PCT) lossEpisodeActive = false
        if (lossWindow.size < LOSS_MIN_SAMPLES) return
        if (lossPct >= LOSS_ALERT_PCT && !lossEpisodeActive) {
            lossEpisodeActive = true
            if (cooldownOk(ID_LOSS)) {
                notify(
                    id = ID_LOSS,
                    title = StabilizerConfig.s("lossTitle", "Persistent packet loss"),
                    body = StabilizerConfig
                        .s("lossBody", "Packet loss is {loss}%.")
                        .replace("{loss}", fmt(lossPct)),
                    withCycleAction = true,
                )
            }
        }
    }

    // ── DNS benchmarking ────────────────────────────────────────────────

    private fun runBenchLoop() {
        try {
            while (!Thread.currentThread().isInterrupted) {
                for ((ip, _) in StabilizerConfig.candidates) {
                    val rtt = probeDns(ip)
                    if (rtt >= 0) {
                        val prev = candidateEwmaMs[ip]
                        candidateEwmaMs[ip] =
                            if (prev == null) rtt
                            else BENCH_EWMA_ALPHA * rtt + (1 - BENCH_EWMA_ALPHA) * prev
                        candidateProbeCount.merge(ip, 1, Int::plus)
                    }
                }
                evaluateDns()
                Thread.sleep(BENCH_INTERVAL_MS)
            }
        } catch (_: InterruptedException) {
            // Normal teardown.
        } catch (e: Exception) {
            Log.e(TAG, "Bench loop failed", e)
        }
    }

    private fun evaluateDns() {
        val activeIp = PingStabilizerVpnService.activeDnsIp() ?: return
        val labels = StabilizerConfig.candidates.toMap()

        val activeRtt = trustedRtt(activeIp) ?: return
        var bestIp = activeIp
        var bestRtt = activeRtt
        for ((ip, _) in StabilizerConfig.candidates) {
            val rtt = trustedRtt(ip) ?: continue
            if (rtt < bestRtt) {
                bestIp = ip
                bestRtt = rtt
            }
        }
        if (bestIp == activeIp) return
        val fastEnough =
            bestRtt * DNS_RATIO < activeRtt && activeRtt - bestRtt >= DNS_MIN_DELTA_MS
        if (!fastEnough) return

        val bestLabel = labels[bestIp] ?: bestIp
        if (StabilizerConfig.autoSwitchDns) {
            val now = System.currentTimeMillis()
            if (now - lastSwitchAtMs < SWITCH_COOLDOWN_MS) return
            lastSwitchAtMs = now
            PingStabilizerVpnService.setActiveDns(bestIp)
            Log.i(TAG, "Auto-switched DNS to $bestIp (${fmt(bestRtt)} ms vs ${fmt(activeRtt)} ms)")
            notify(
                id = ID_DNS_SWITCHED,
                title = StabilizerConfig.s("dnsSwitchedTitle", "DNS switched"),
                body = StabilizerConfig
                    .s("dnsSwitchedBody", "Now using {dns} — it responded {delta} ms faster.")
                    .replace("{dns}", bestLabel)
                    .replace("{delta}", fmt(activeRtt - bestRtt)),
                withCycleAction = false,
                lowPriority = true,
            )
        } else {
            // Re-suggesting on every 45 s pass would be spam — one shared
            // cooldown gates the suggestion regardless of target. (Careful:
            // cooldownOk() records the fire time when it returns true, so it
            // must be consulted exactly once per evaluation.)
            if (!cooldownOk(ID_DNS_SUGGEST)) return
            notify(
                id = ID_DNS_SUGGEST,
                title = StabilizerConfig.s("dnsTitle", "Faster DNS available"),
                body = StabilizerConfig
                    .s("dnsBody", "A faster DNS ({dns}) is available.")
                    .replace("{dns}", bestLabel),
                withCycleAction = false,
            )
        }
    }

    private fun trustedRtt(ip: String): Double? {
        if ((candidateProbeCount[ip] ?: 0) < BENCH_MIN_PROBES) return null
        return candidateEwmaMs[ip]
    }

    /**
     * DNS RTT probe through a protected socket (bypasses the TUN so each
     * candidate is measured directly). Returns -1 on timeout/failure.
     */
    private fun probeDns(ip: String): Double {
        val socket = DatagramSocket()
        return try {
            protector(socket)
            socket.soTimeout = BENCH_TIMEOUT_MS
            val payload = byteArrayOf(
                0x24, 0x7C, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x07, 'e'.code.toByte(), 'x'.code.toByte(), 'a'.code.toByte(),
                'm'.code.toByte(), 'p'.code.toByte(), 'l'.code.toByte(), 'e'.code.toByte(),
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

    // ── Notification plumbing ───────────────────────────────────────────

    private fun cooldownOk(id: Int): Boolean {
        val now = System.currentTimeMillis()
        val last = lastFiredAtMs[id] ?: 0L
        if (now - last < REFIRE_COOLDOWN_MS) return false
        lastFiredAtMs[id] = now
        return true
    }

    private fun notify(
        id: Int,
        title: String,
        body: String,
        withCycleAction: Boolean,
        lowPriority: Boolean = false,
    ) {
        // App visible → in-app snackbar; otherwise system notification. The
        // cycle action travels as a flag + localized label so the Dart side
        // can render a matching SnackBarAction.
        InAppAlertBridge.deliver(
            mapOf(
                "source" to "stabilizer",
                "severity" to if (lowPriority) "info" else "warning",
                "title" to title,
                "body" to body,
                "action" to if (withCycleAction) "cycleTunnel" else null,
                "actionLabel" to if (withCycleAction) {
                    StabilizerConfig.s("actionCycle", "Cycle tunnel")
                } else {
                    null
                },
            ),
        ) { postNotification(id, title, body, withCycleAction, lowPriority) }
    }

    private fun postNotification(
        id: Int,
        title: String,
        body: String,
        withCycleAction: Boolean,
        lowPriority: Boolean,
    ) {
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

        val pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPending = PendingIntent.getActivity(context, id, openIntent, pendingFlags)

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setSmallIcon(R.drawable.ic_stat_torcav)
            .setAutoCancel(true)
            .setPriority(
                if (lowPriority) NotificationCompat.PRIORITY_LOW
                else NotificationCompat.PRIORITY_DEFAULT,
            )
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setContentIntent(openPending)

        if (withCycleAction) {
            val cycleIntent = Intent(context, PingStabilizerVpnService::class.java).apply {
                action = PingStabilizerVpnService.ACTION_CYCLE
            }
            builder.addAction(
                R.drawable.ic_stat_torcav,
                StabilizerConfig.s("actionCycle", "Cycle tunnel"),
                PendingIntent.getService(context, id, cycleIntent, pendingFlags),
            )
        }

        try {
            NotificationManagerCompat.from(context).notify(id, builder.build())
        } catch (e: SecurityException) {
            Log.w(TAG, "Notification blocked", e)
        }
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            StabilizerConfig.s("alertChannelName", "Stabilizer alerts"),
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = StabilizerConfig.s(
                "alertChannelDesc",
                "Jitter, packet-loss and DNS recommendations from the ping stabilizer.",
            )
        }
        mgr.createNotificationChannel(channel)
    }

    private fun fmt(v: Double): String = String.format(Locale.US, "%.1f", v)
}
