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

    private val sceneView: ARSceneView = ARSceneView(context).apply {
        hostLifecycle?.let { lifecycle = it }
        sessionConfiguration = { _, config ->
            config.planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
            config.depthMode = Config.DepthMode.DISABLED
            config.lightEstimationMode = Config.LightEstimationMode.DISABLED
            config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        }
        onSessionUpdated = { _, frame ->
            try {
                val updated = frame.getUpdatedTrackables(Plane::class.java)
                val payload = ArrayList<Map<String, Any>>()
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
                    payload.add(
                        mapOf(
                            "id" to System.identityHashCode(plane),
                            "type" to "vertical",
                            "extentX" to plane.extentX.toDouble(),
                            "extentZ" to plane.extentZ.toDouble(),
                            "centerX" to center[0].toDouble(),
                            "centerY" to center[1].toDouble(),
                            "centerZ" to center[2].toDouble(),
                            "points" to worldPoints,
                        ),
                    )
                }
                if (payload.isNotEmpty()) {
                    eventSink.send(mapOf("planes" to payload))
                }
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
