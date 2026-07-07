package dev.halilibrahim.torcav

import android.content.Context
import android.util.Log
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.TimeUnit

/**
 * Periodic background download probe feeding the paying-vs-getting trend
 * ("taahhüt hızı" comparison) with measurements the user did not have to
 * remember to take.
 *
 * Guardrails, in keeping with the app's conservative posture:
 *  - UNMETERED networks only — never burns mobile data quota;
 *  - requires battery-not-low;
 *  - downloads a fixed 10 MB — enough for a stable Mbps estimate on home
 *    links, small enough to be negligible on any home plan;
 *  - no upload leg and no notification: this worker only collects evidence.
 *
 * Results are queued as JSON in SharedPreferences; the app drains the queue
 * into the encrypted history DB on next launch (the worker process has no
 * access to the SQLCipher key, and must not).
 */
class SpeedProbeWorker(
    appContext: Context,
    params: WorkerParameters,
) : Worker(appContext, params) {

    companion object {
        private const val TAG = "TorcavSpeedProbe"
        private const val UNIQUE_PERIODIC = "torcav_speed_probe_periodic"

        private const val PREFS = "torcav_speed_probe"
        private const val KEY_QUEUE = "resultQueue"

        /** Bound the queue so an unopened app doesn't grow prefs forever. */
        private const val MAX_QUEUE = 48

        private const val DOWNLOAD_BYTES = 10_000_000
        private const val DOWNLOAD_URL =
            "https://speed.cloudflare.com/__down?bytes=$DOWNLOAD_BYTES"
        private const val LATENCY_URL = "https://speed.cloudflare.com/__down?bytes=0"

        /** Twice a day is plenty for a trend; don't allow tighter loops. */
        private const val MIN_INTERVAL_MS = 6L * 60L * 60_000L

        fun schedule(context: Context, intervalMs: Long) {
            val interval = intervalMs.coerceAtLeast(MIN_INTERVAL_MS)
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.UNMETERED)
                .setRequiresBatteryNotLow(true)
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                UNIQUE_PERIODIC,
                ExistingPeriodicWorkPolicy.UPDATE,
                PeriodicWorkRequestBuilder<SpeedProbeWorker>(
                    interval,
                    TimeUnit.MILLISECONDS,
                ).setConstraints(constraints).build(),
            )
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_PERIODIC)
        }

        /** Returns the queued results as a JSON array string and clears the queue. */
        fun drain(context: Context): String {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val queued = prefs.getString(KEY_QUEUE, "[]") ?: "[]"
            prefs.edit().remove(KEY_QUEUE).apply()
            return queued
        }
    }

    override fun doWork(): Result {
        try {
            val latencyMs = measureLatency()
            val downloadMbps = measureDownload()
            if (downloadMbps > 0) enqueueResult(latencyMs, downloadMbps)
        } catch (e: Exception) {
            // Best-effort evidence gathering; the next periodic run retries.
            Log.e(TAG, "Speed probe failed", e)
        }
        return Result.success()
    }

    /** Median of three zero-byte round-trips (TTFB-style latency). */
    private fun measureLatency(): Double {
        val samples = mutableListOf<Long>()
        repeat(3) {
            val start = System.nanoTime()
            try {
                val conn = URL(LATENCY_URL).openConnection() as HttpURLConnection
                conn.connectTimeout = 5_000
                conn.readTimeout = 5_000
                conn.inputStream.use { it.readBytes() }
                conn.disconnect()
                samples.add((System.nanoTime() - start) / 1_000_000)
            } catch (_: Exception) {
                // Skip the failed sample.
            }
        }
        if (samples.isEmpty()) return 0.0
        samples.sort()
        return samples[samples.size / 2].toDouble()
    }

    private fun measureDownload(): Double {
        val conn = URL(DOWNLOAD_URL).openConnection() as HttpURLConnection
        conn.connectTimeout = 10_000
        conn.readTimeout = 60_000
        return try {
            val buffer = ByteArray(64 * 1024)
            var total = 0L
            val start = System.nanoTime()
            conn.inputStream.use { input ->
                while (true) {
                    val read = input.read(buffer)
                    if (read < 0) break
                    total += read
                }
            }
            val seconds = (System.nanoTime() - start) / 1_000_000_000.0
            if (seconds <= 0 || total <= 0) 0.0 else (total * 8) / (seconds * 1_000_000)
        } finally {
            conn.disconnect()
        }
    }

    private fun enqueueResult(latencyMs: Double, downloadMbps: Double) {
        val prefs = applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val array = JSONArray(prefs.getString(KEY_QUEUE, "[]") ?: "[]")
        array.put(
            JSONObject().apply {
                put("recordedAtMs", System.currentTimeMillis())
                put("latencyMs", latencyMs)
                put("downloadMbps", downloadMbps)
            },
        )
        val trimmed = if (array.length() > MAX_QUEUE) {
            JSONArray().also { out ->
                for (i in array.length() - MAX_QUEUE until array.length()) {
                    out.put(array.get(i))
                }
            }
        } else {
            array
        }
        prefs.edit().putString(KEY_QUEUE, trimmed.toString()).apply()
    }
}
