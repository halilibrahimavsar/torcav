package com.example.torcav.ar

import android.animation.ValueAnimator
import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.google.android.filament.EntityManager
import com.google.android.filament.LightManager
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.Pose
import com.google.ar.core.TrackingState
import dev.romainguy.kotlin.math.Float3
import dev.romainguy.kotlin.math.Float4
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.node.Node
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
    private val markerNodes = ArrayList<Node>()

    // Filament light entities added manually (since LightEstimation is disabled).
    private var lightEntity: Int = 0
    private var sceneHasLight = false

    private val sceneView: ARSceneView = ARSceneView(context).apply {
        hostLifecycle?.let { lifecycle = it }
        sessionConfiguration = { _, config ->
            config.planeFindingMode = Config.PlaneFindingMode.VERTICAL
            config.depthMode = Config.DepthMode.DISABLED
            config.lightEstimationMode = Config.LightEstimationMode.DISABLED
            config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        }

        onSessionUpdated = lambda@{ _, frame ->
            // On the very first tracked frame, inject a directional sun light
            // and a constant ambient term so PBR materials render with colour
            // even though LightEstimationMode is disabled.
            if (!sceneHasLight) {
                try {
                    lightEntity = EntityManager.get().create()
                    LightManager.Builder(LightManager.Type.DIRECTIONAL)
                        .color(1.0f, 0.98f, 0.95f)    // warm white
                        .intensity(200_000f)            // ~outdoor daylight
                        .direction(0.2f, -1f, -0.5f)   // slightly off-axis
                        .castShadows(false)
                        .build(this.engine, lightEntity)
                    this.scene.addEntity(lightEntity)
                    sceneHasLight = true
                    Log.d(TAG, "Scene lighting initialised")
                } catch (e: Throwable) {
                    Log.e(TAG, "Failed to add scene light", e)
                }
            }
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
     * Drops a colored 3D sphere ("Signal Pin") at the camera's last known world
     * position. Uses [SphereNode] with [materialLoader.createColorInstance] —
     * the native SceneView 2.x API that bypasses Sceneform-legacy rendering.
     *
     * Color encodes the RSSI tier:
     *   - Green  → strong signal
     *   - Yellow → medium signal
     *   - Red    → weak signal
     *
     * Markers are placed approx. 1.1 m below the camera (belt level) for
     * maximum visibility during the survey.
     */
    fun placeMarkerAtCamera(rssi: Int, colorArgb: Int, radius: Float): Boolean {
        val pose = lastCameraPose ?: run {
            Log.w(TAG, "placeMarkerAtCamera: no camera pose yet — skipping")
            return false
        }

        sceneView.post {
            try {
                val t = pose.translation
                Log.d(TAG, "Placing Signal Pin: world=(${t[0]}, ${t[1]}, ${t[2]}), rssi=$rssi")

                // Decompose ARGB int to normalized Filament color components.
                val r = android.graphics.Color.red(colorArgb) / 255f
                val g = android.graphics.Color.green(colorArgb) / 255f
                val b = android.graphics.Color.blue(colorArgb) / 255f

                // createColorInstance uses SceneView's built-in PBR material.
                // Low metallic + high roughness → matte solid sphere, still
                // visible without any light estimation.
                val materialInstance = sceneView.materialLoader.createColorInstance(
                    color = Float4(r, g, b, 1f),
                    metallic = 0f,
                    roughness = 0.8f,
                    reflectance = 0f,
                )

                val sphereRadius = radius.coerceIn(0.05f, 0.25f)

                val sphereNode = SphereNode(
                    engine = sceneView.engine,
                    radius = sphereRadius,
                    materialInstance = materialInstance,
                ).apply {
                    // Drop the pin ~1.1 m below the eye (around belt height).
                    position = Float3(t[0], t[1] - DROP_BELOW_CAMERA, t[2])
                }

                // Gentle pulsing scale to make the pin feel "alive".
                ValueAnimator.ofFloat(0.8f, 1.2f).apply {
                    duration = 1400
                    repeatCount = ValueAnimator.INFINITE
                    repeatMode = ValueAnimator.REVERSE
                    interpolator = AccelerateDecelerateInterpolator()
                    addUpdateListener { animator ->
                        val v = animator.animatedValue as Float
                        sphereNode.scale = Float3(v, v, v)
                    }
                    start()
                }

                sceneView.addChildNode(sphereNode)
                markerNodes.add(sphereNode)
                Log.d(TAG, "Signal Pin added. Total markers: ${markerNodes.size}")
            } catch (throwable: Throwable) {
                Log.e(TAG, "placeMarkerAtCamera failed", throwable)
            }
        }
        return true
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
            if (lightEntity != 0) {
                sceneView.scene.removeEntity(lightEntity)
                EntityManager.get().destroy(lightEntity)
                lightEntity = 0
            }
            sceneView.destroy()
        } catch (t: Throwable) {
            Log.w(TAG, "sceneView.destroy() threw", t)
        }
    }

    companion object {
        private const val TAG = "ArScenePlatformView"
        private const val EMIT_INTERVAL_MS = 66L  // ~15 Hz
        private const val DROP_BELOW_CAMERA = 1.1f // metres from eye to pin
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
