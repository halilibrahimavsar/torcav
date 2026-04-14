package com.example.torcav.ar

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import android.view.View
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.TrackingState
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView

/**
 * PlatformView that hosts ARCore via SceneView and streams vertical-plane
 * polygons to Dart over [eventSink].
 *
 * Polygon math: ARCore `Plane.polygon` is a FloatBuffer of 2D vertices in the
 * plane's local X/Z frame. We transform each vertex by `plane.centerPose` to
 * obtain world-space (x, y, z) points and forward the list to Dart, which
 * projects them onto the floor plane to build WallSegment pairs.
 */
class ArScenePlatformView(
    context: Context,
    private val eventSink: EventChannelSink,
) : PlatformView {

    private val hostLifecycle: Lifecycle? = context.findLifecycle()
    private var lastEmitMs: Long = 0L

    private val sceneView: ARSceneView = ARSceneView(context).apply {
        hostLifecycle?.let { lifecycle = it }
        sessionConfiguration = { _, config ->
            config.planeFindingMode = Config.PlaneFindingMode.VERTICAL
            config.depthMode = Config.DepthMode.DISABLED
            config.lightEstimationMode = Config.LightEstimationMode.DISABLED
            config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        }
        onSessionUpdated = lambda@{ _, frame ->
            try {
                val now = System.currentTimeMillis()
                if (now - lastEmitMs < EMIT_INTERVAL_MS) return@lambda
                lastEmitMs = now

                val planes = ArrayList<Map<String, Any>>()
                val updated = frame.getUpdatedTrackables(Plane::class.java)
                for (plane in updated) {
                    if (plane.trackingState != TrackingState.TRACKING) continue
                    if (plane.type != Plane.Type.VERTICAL) continue

                    val poly = plane.polygon.asReadOnlyBuffer()
                    poly.rewind()
                    val vertexCount = poly.remaining() / 2
                    if (vertexCount < 2) continue

                    val worldPoints = ArrayList<Double>(vertexCount * 3)
                    val local = FloatArray(3)
                    val world = FloatArray(3)
                    while (poly.remaining() >= 2) {
                        local[0] = poly.get()
                        local[1] = 0f
                        local[2] = poly.get()
                        plane.centerPose.transformPoint(local, 0, world, 0)
                        worldPoints.add(world[0].toDouble())
                        worldPoints.add(world[1].toDouble())
                        worldPoints.add(world[2].toDouble())
                    }

                    val center = plane.centerPose.translation
                    planes.add(
                        mapOf(
                            "id" to System.identityHashCode(plane),
                            "extentX" to plane.extentX.toDouble(),
                            "extentZ" to plane.extentZ.toDouble(),
                            "centerX" to center[0].toDouble(),
                            "centerY" to center[1].toDouble(),
                            "centerZ" to center[2].toDouble(),
                            "points" to worldPoints,
                        ),
                    )
                }

                val camera = frame.camera
                val payload = HashMap<String, Any>()
                payload["planes"] = planes
                if (camera.trackingState == TrackingState.TRACKING) {
                    val t = camera.pose.translation
                    payload["camera"] = mapOf(
                        "x" to t[0].toDouble(),
                        "y" to t[1].toDouble(),
                        "z" to t[2].toDouble(),
                    )
                }
                eventSink.send(payload)
            } catch (t: Throwable) {
                Log.e(TAG, "onSessionUpdated failed", t)
            }
        }
    }

    override fun getView(): View = sceneView

    override fun dispose() {
        try {
            sceneView.destroy()
        } catch (t: Throwable) {
            Log.w(TAG, "sceneView.destroy() threw", t)
        }
    }

    companion object {
        private const val TAG = "ArScenePlatformView"
        private const val EMIT_INTERVAL_MS = 66L // ~15 Hz
    }
}

private fun Context.findLifecycle(): Lifecycle? {
    var ctx: Context? = this
    while (ctx is ContextWrapper) {
        if (ctx is LifecycleOwner) return ctx.lifecycle
        ctx = ctx.baseContext
    }
    return null
}


/**
 * Simple wrapper so the platform view does not depend on the MainThread check
 * that `EventChannel.EventSink` enforces when called from ARCore's render
 * callback (which already runs on the UI thread, but we want to be defensive).
 */
fun interface EventChannelSink {
    fun send(event: Any)
}
