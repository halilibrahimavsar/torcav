package com.example.torcav.ar

import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import android.view.View
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.google.android.filament.Colors
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.Pose
import com.google.ar.core.TrackingState
import dev.romainguy.kotlin.math.Float3
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.node.SphereNode

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
    private var lastCameraPose: Pose? = null
    private val markerNodes = ArrayList<SphereNode>()

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
                    lastCameraPose = camera.pose
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

    /**
     * Drops a colored sphere at the camera's last known world position,
     * lowered ~1.1 m to sit near the floor. Returns true when a pose was
     * available and the node was scheduled for rendering.
     */
    fun placeMarkerAtCamera(colorArgb: Int, radius: Float): Boolean {
        val pose = lastCameraPose ?: return false
        return try {
            val t = pose.translation
            val material = sceneView.materialLoader.createColorInstance(
                color = argbToLinear(colorArgb),
                metallic = 0.1f,
                roughness = 0.35f,
                reflectance = 0.4f,
            )
            val sphere = SphereNode(
                engine = sceneView.engine,
                radius = radius,
                center = Float3(0f, 0f, 0f),
                materialInstance = material,
            ).apply {
                position = Float3(t[0], t[1] - DROP_BELOW_CAMERA, t[2])
            }
            sceneView.addChildNode(sphere)
            markerNodes.add(sphere)
            true
        } catch (t: Throwable) {
            Log.e(TAG, "placeMarkerAtCamera failed", t)
            false
        }
    }

    fun clearMarkers() {
        for (node in markerNodes) {
            try {
                sceneView.removeChildNode(node)
                node.destroy()
            } catch (t: Throwable) {
                Log.w(TAG, "marker destroy threw", t)
            }
        }
        markerNodes.clear()
    }

    override fun dispose() {
        try {
            clearMarkers()
            sceneView.destroy()
        } catch (t: Throwable) {
            Log.w(TAG, "sceneView.destroy() threw", t)
        }
    }

    private fun argbToLinear(argb: Int): dev.romainguy.kotlin.math.Float4 {
        val r = ((argb shr 16) and 0xFF) / 255f
        val g = ((argb shr 8) and 0xFF) / 255f
        val b = (argb and 0xFF) / 255f
        val a = ((argb shr 24) and 0xFF) / 255f
        // Filament expects linear RGB; approximate from sRGB.
        val linear = Colors.toLinear(Colors.RgbaType.SRGB, floatArrayOf(r, g, b, a))
        return dev.romainguy.kotlin.math.Float4(linear[0], linear[1], linear[2], linear[3])
    }

    companion object {
        private const val TAG = "ArScenePlatformView"
        private const val EMIT_INTERVAL_MS = 66L // ~15 Hz
        private const val DROP_BELOW_CAMERA = 1.1f // meters from eye to marker
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
