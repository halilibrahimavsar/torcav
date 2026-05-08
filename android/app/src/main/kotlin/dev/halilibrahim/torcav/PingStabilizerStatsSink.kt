package dev.halilibrahim.torcav

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Bridge between [PingStabilizerVpnService] (background thread) and the
 * Flutter main isolate. Holds the active [EventChannel.EventSink] and
 * marshals emissions onto the main looper.
 *
 * Singleton because both sides need to access the same sink without
 * threading through the service binder.
 */
object PingStabilizerStatsSink : EventChannel.StreamHandler {

    @Volatile private var sink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(payload: Map<String, Any?>) {
        mainHandler.post {
            try {
                sink?.success(payload)
            } catch (_: Exception) {
                // EventSink can throw if the listener has gone away mid-emit.
            }
        }
    }
}
