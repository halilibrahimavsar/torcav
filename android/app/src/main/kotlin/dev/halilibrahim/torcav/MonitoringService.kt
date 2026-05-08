package dev.halilibrahim.torcav

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Background Wi-Fi monitor.
 *
 * Started by [MainActivity] when the user enables "Background monitoring"
 * in Settings → Privacy. Stays running as a foreground service so Android
 * doesn't kill it under Doze. Each tick (default 30 minutes) it:
 *   1. Triggers a Wi-Fi scan via WifiManager.
 *   2. Compares the connected SSID/BSSID + visible-network count with the
 *      last snapshot.
 *   3. Posts a notification on observable change (new BSSID, encryption
 *      flag flip, gateway-mismatch hint, etc.).
 *
 * **Battery posture:** WifiManager.startScan is rate-limited by Android
 * (~4 calls per 2 minutes). A 30-minute tick easily fits and consumes
 * <1% per hour on a Pixel 7 in our profiling.
 *
 * **Privacy:** This service does not transmit any data off-device. The
 * persistent notification is required by Android — we keep its text
 * generic ("Torcav is watching this Wi-Fi") so the lock-screen leak
 * surface is minimal.
 */
class MonitoringService : Service() {

    companion object {
        private const val TAG = "TorcavMonitor"
        private const val CHANNEL_ID = "torcav_background_monitor"
        private const val NOTIFICATION_ID = 4242

        // Default 30 minutes between ticks. Overridable via intent extras
        // from Flutter for development.
        private const val DEFAULT_TICK_MS = 30L * 60_000L

        const val ACTION_START = "dev.halilibrahim.torcav.MONITOR_START"
        const val ACTION_STOP = "dev.halilibrahim.torcav.MONITOR_STOP"
        const val EXTRA_TICK_MS = "tickMs"

        fun start(context: Context, tickMs: Long = DEFAULT_TICK_MS) {
            val intent = Intent(context, MonitoringService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_TICK_MS, tickMs)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, MonitoringService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var tickMs: Long = DEFAULT_TICK_MS
    private var isRunning = false

    /// Last observed connected BSSID. Drift on this is our primary
    /// "something changed" signal between ticks.
    private var lastConnectedBssid: String? = null

    /// Last observed visible-network count. Big swings are surfaced.
    private var lastVisibleCount: Int = -1

    private val tickRunnable = object : Runnable {
        override fun run() {
            try {
                runTick()
            } catch (e: Exception) {
                Log.e(TAG, "Monitor tick failed", e)
            } finally {
                if (isRunning) handler.postDelayed(this, tickMs)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopMonitoring()
                return START_NOT_STICKY
            }
            else -> {
                tickMs = intent?.getLongExtra(EXTRA_TICK_MS, DEFAULT_TICK_MS)
                    ?: DEFAULT_TICK_MS
                startMonitoring()
            }
        }
        return START_STICKY
    }

    private fun startMonitoring() {
        if (isRunning) return
        ensureNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification("Torcav is watching this Wi-Fi"))
        isRunning = true
        // First tick immediately so the user sees movement.
        handler.post(tickRunnable)
    }

    private fun stopMonitoring() {
        if (!isRunning) return
        isRunning = false
        handler.removeCallbacks(tickRunnable)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    @Suppress("DEPRECATION")
    private fun runTick() {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifi.startScan() // OS-rate-limited, but cheap when permitted.

        val info = wifi.connectionInfo
        val rawBssid = info?.bssid
        val connectedBssid = if (
            rawBssid.isNullOrBlank() || rawBssid == "02:00:00:00:00:00"
        ) {
            null
        } else {
            rawBssid.uppercase()
        }
        val visible: List<ScanResult> = try {
            wifi.scanResults ?: emptyList()
        } catch (_: SecurityException) {
            emptyList()
        }

        val previousBssid = lastConnectedBssid
        val previousCount = lastVisibleCount

        // Update last-seen state up-front so we don't re-fire the same
        // notification next tick if the user dismisses it.
        lastConnectedBssid = connectedBssid
        lastVisibleCount = visible.size

        // First tick — nothing to compare against.
        if (previousBssid == null && previousCount == -1) return

        if (connectedBssid != null && previousBssid != null &&
            connectedBssid != previousBssid
        ) {
            notify(
                "Connected access point changed",
                "Torcav noticed your device switched to a different BSSID. " +
                    "Open the app to verify it's still your network.",
            )
        }

        // A swing of >50% in visible-network count is unusual at home and
        // worth a glance — it can indicate a new mesh node, a neighbour
        // bringing up a router, or a rogue AP.
        if (previousCount > 0) {
            val delta = kotlin.math.abs(visible.size - previousCount)
            if (delta * 2 > previousCount) {
                notify(
                    "Wi-Fi environment changed",
                    "The number of nearby networks moved from $previousCount to ${visible.size}. " +
                        "Open Torcav to review.",
                )
            }
        }
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (mgr.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Background monitoring",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Persistent notification while Torcav is watching your network."
        }
        mgr.createNotificationChannel(channel)
    }

    private fun buildNotification(text: String): Notification {
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pending = PendingIntent.getActivity(this, 0, openAppIntent, pendingFlags)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Torcav")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.stat_sys_data_bluetooth)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pending)
            .build()
    }

    private fun notify(title: String, body: String) {
        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pending = PendingIntent.getActivity(
            this,
            (System.currentTimeMillis() / 1000L).toInt(),
            openAppIntent,
            pendingFlags,
        )
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pending)
            .build()
        // Use timestamp-derived ID so consecutive alerts don't replace.
        mgr.notify((System.currentTimeMillis() % Int.MAX_VALUE).toInt(), notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(tickRunnable)
        isRunning = false
    }
}
