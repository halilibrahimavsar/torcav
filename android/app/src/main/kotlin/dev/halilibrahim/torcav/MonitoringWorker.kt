package dev.halilibrahim.torcav

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * Periodic background Wi-Fi watch, WorkManager edition.
 *
 * Replaces the old `MonitoringService` foreground service, which had four
 * independent ways of dying silently:
 *  1. `dataSync` FGS types are hard-capped at 6 h/24 h on Android 14+
 *     (and the service never implemented `onTimeout`, risking an ANR);
 *  2. its `Handler.postDelayed` tick never fired in Doze;
 *  3. nothing rescheduled it after a reboot;
 *  4. it read `scanResults` immediately after `startScan()`, i.e. always
 *     one scan behind.
 *
 * WorkManager solves 1–3 by construction: no foreground service (and no
 * permanent notification!), Doze-aware scheduling in maintenance windows,
 * and persistence across reboots. Problem 4 is handled by awaiting the
 * SCAN_RESULTS_AVAILABLE broadcast with a timeout.
 *
 * Tick state (last BSSID / visible count) and the Dart-supplied localized
 * notification strings live in SharedPreferences.
 */
class MonitoringWorker(
    appContext: Context,
    params: WorkerParameters,
) : Worker(appContext, params) {

    companion object {
        private const val TAG = "TorcavMonitor"
        private const val CHANNEL_ID = "torcav_background_monitor"

        private const val UNIQUE_PERIODIC = "torcav_monitor_periodic"
        private const val UNIQUE_PRIME = "torcav_monitor_prime"

        private const val PREFS = "torcav_monitor"
        private const val KEY_LAST_BSSID = "lastBssid"
        private const val KEY_LAST_COUNT = "lastCount"
        private const val STRING_PREFIX = "str_"

        /** WorkManager's floor for periodic work. */
        private const val MIN_INTERVAL_MS = 15L * 60_000L

        private const val SCAN_AWAIT_SECONDS = 12L

        /**
         * Schedules (or re-schedules with fresh interval/strings) the
         * periodic watch, plus an immediate one-shot run so the baseline
         * snapshot is captured now instead of one interval from now.
         */
        fun schedule(context: Context, tickMs: Long, strings: Map<String, String>) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            strings.forEach { (k, v) -> prefs.putString("$STRING_PREFIX$k", v) }
            prefs.apply()

            val interval = tickMs.coerceAtLeast(MIN_INTERVAL_MS)
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                UNIQUE_PERIODIC,
                ExistingPeriodicWorkPolicy.UPDATE,
                PeriodicWorkRequestBuilder<MonitoringWorker>(
                    interval,
                    TimeUnit.MILLISECONDS,
                ).build(),
            )
            WorkManager.getInstance(context).enqueueUniqueWork(
                UNIQUE_PRIME,
                ExistingWorkPolicy.REPLACE,
                OneTimeWorkRequestBuilder<MonitoringWorker>().build(),
            )
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_PERIODIC)
            WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_PRIME)
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .remove(KEY_LAST_BSSID)
                .remove(KEY_LAST_COUNT)
                .apply()
        }
    }

    override fun doWork(): Result {
        try {
            runTick()
        } catch (e: Exception) {
            // Best-effort monitoring: a failed tick is not worth a retry
            // storm; the next periodic run gets a fresh chance.
            Log.e(TAG, "Monitor tick failed", e)
        }
        return Result.success()
    }

    private fun runTick() {
        val wifi = applicationContext
            .getSystemService(Context.WIFI_SERVICE) as WifiManager

        val visible = freshScanResults(wifi)
        val connectedBssid = readConnectedBssid(wifi)

        val prefs = applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val previousBssid = prefs.getString(KEY_LAST_BSSID, null)
        val previousCount = prefs.getInt(KEY_LAST_COUNT, -1)

        // Persist the new snapshot up-front so a dismissed notification
        // isn't re-fired for the same state on the next tick.
        prefs.edit()
            .putString(KEY_LAST_BSSID, connectedBssid)
            .putInt(KEY_LAST_COUNT, visible.size)
            .apply()

        // First tick — nothing to compare against.
        if (previousBssid == null && previousCount == -1) return

        if (connectedBssid != null && previousBssid != null &&
            connectedBssid != previousBssid
        ) {
            notify(
                id = 4241,
                title = s("bssidChangedTitle", "Connected access point changed"),
                body = s(
                    "bssidChangedBody",
                    "Your device switched to a different access point. " +
                        "Open Torcav to verify it's still your network.",
                ),
            )
        }

        // A swing of >50% in visible-network count is unusual at home and
        // worth a glance — a new mesh node, a neighbour's router, or a
        // rogue AP.
        if (previousCount > 0) {
            val delta = kotlin.math.abs(visible.size - previousCount)
            if (delta * 2 > previousCount) {
                notify(
                    id = 4242,
                    title = s("envChangedTitle", "Wi-Fi environment changed"),
                    body = s(
                        "envChangedBody",
                        "Nearby networks moved from {from} to {to}. Open Torcav to review.",
                    )
                        .replace("{from}", previousCount.toString())
                        .replace("{to}", visible.size.toString()),
                )
            }
        }
    }

    /**
     * Kicks a scan and waits (bounded) for SCAN_RESULTS_AVAILABLE before
     * reading, so we don't evaluate the *previous* tick's snapshot. On
     * throttled/denied scans we fall back to the cached results — stale
     * data beats no data for a drift check.
     */
    private fun freshScanResults(wifi: WifiManager): List<ScanResult> {
        val latch = CountDownLatch(1)
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                latch.countDown()
            }
        }
        ContextCompat.registerReceiver(
            applicationContext,
            receiver,
            IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION),
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
        try {
            @Suppress("DEPRECATION")
            val accepted = try {
                wifi.startScan()
            } catch (_: Exception) {
                false
            }
            if (accepted) latch.await(SCAN_AWAIT_SECONDS, TimeUnit.SECONDS)
        } catch (_: InterruptedException) {
            // Worker being stopped — return whatever the cache has.
        } finally {
            try {
                applicationContext.unregisterReceiver(receiver)
            } catch (_: Exception) {}
        }
        return try {
            wifi.scanResults ?: emptyList()
        } catch (_: SecurityException) {
            emptyList()
        }
    }

    @Suppress("DEPRECATION")
    private fun readConnectedBssid(wifi: WifiManager): String? {
        val raw = wifi.connectionInfo?.bssid
        return if (raw.isNullOrBlank() || raw == "02:00:00:00:00:00") {
            null
        } else {
            raw.uppercase()
        }
    }

    // ── Notification plumbing ───────────────────────────────────────────

    private fun s(key: String, fallback: String): String =
        applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString("$STRING_PREFIX$key", null) ?: fallback

    private fun notify(id: Int, title: String, body: String) {
        if (!NotificationManagerCompat.from(applicationContext).areNotificationsEnabled()) {
            return
        }
        ensureChannel()

        val openAppIntent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pending = PendingIntent.getActivity(
            applicationContext,
            id,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setSmallIcon(R.drawable.ic_stat_torcav)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setContentIntent(pending)
            .build()
        try {
            NotificationManagerCompat.from(applicationContext).notify(id, notification)
        } catch (e: SecurityException) {
            Log.w(TAG, "Notification blocked", e)
        }
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = applicationContext
            .getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // Recreating is idempotent and refreshes the localized name after a
        // language change.
        mgr.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                s("channelName", "Network watch alerts"),
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = s(
                    "channelDesc",
                    "Alerts from the periodic background Wi-Fi check.",
                )
            },
        )
    }
}
