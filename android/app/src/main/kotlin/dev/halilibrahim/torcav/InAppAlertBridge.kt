package dev.halilibrahim.torcav

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Routes native alerts (MonitoringWorker, StabilizerAlertEngine) to the
 * Flutter UI as in-app snackbar events while the app is in the foreground,
 * so the user isn't hit with a system notification for a screen they are
 * already looking at.
 *
 * Delivery contract: [deliver] hands the payload to the Dart event sink only
 * when BOTH the activity is resumed and Flutter is listening; in every other
 * case (backgrounded, engine detached, sink error, race during pause) the
 * caller-supplied fallback posts the regular system notification. The
 * fallback therefore must stay side-effect-safe to run on any thread —
 * alerts originate from worker/bench threads, while sink calls are hopped
 * to the main looper as the platform channel requires.
 */
object InAppAlertBridge : EventChannel.StreamHandler {

    const val EVENT_CHANNEL = "torcav/in_app_alerts"

    @Volatile private var sink: EventChannel.EventSink? = null
    @Volatile var isForeground: Boolean = false

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun deliver(payload: Map<String, Any?>, fallback: () -> Unit) {
        if (!isForeground || sink == null) {
            fallback()
            return
        }
        mainHandler.post {
            // Re-check on the main thread: the activity may have paused (or
            // the engine detached) between the alert firing and this hop.
            val s = sink
            if (!isForeground || s == null) {
                fallback()
                return@post
            }
            try {
                s.success(payload)
            } catch (_: Exception) {
                fallback()
            }
        }
    }
}
