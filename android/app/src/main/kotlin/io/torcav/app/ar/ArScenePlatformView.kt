package io.torcav.app.ar

import android.content.Context
import android.content.ContextWrapper
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color as AndroidColor
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.util.Log
import android.view.View
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.google.android.filament.EntityManager
import com.google.android.filament.LightManager
import com.google.android.filament.MaterialInstance
import com.google.android.filament.Texture
import com.google.ar.core.Config
import com.google.ar.core.Pose
import com.google.ar.core.TrackingState
import dev.romainguy.kotlin.math.Float3
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.math.Position
import io.github.sceneview.math.Rotation
import io.github.sceneview.node.PlaneNode
import io.github.sceneview.texture.ImageTexture
import kotlin.math.atan2
import kotlin.math.roundToInt

/**
 * PlatformView that hosts ARCore via SceneView solely for camera pose tracking
 * and signal-tag rendering. Plane detection is disabled — ARCore's only job
 * here is to provide a stable world-anchored pose so that billboarded RSSI
 * labels stay locked to real-world positions as the user walks.
 *
 * Signal samples are rendered as small billboarded text quads ("signal tags")
 * showing the RSSI value on a colored pill. Textures are cached per
 * (rssi-bucket, color) so long surveys do not allocate unbounded material
 * instances.
 */
class ArScenePlatformView(
    context: Context,
    private val eventSink: EventChannelSink,
) : PlatformView {

    private val hostLifecycle: Lifecycle? = context.findLifecycle()
    private var lastEmitMs: Long = 0L
    private var lastCameraPose: Pose? = null
    private val markerNodes = ArrayDeque<PlaneNode>()
    private val materialCache = HashMap<Long, MaterialInstance>()
    private val textureCache = HashMap<Long, Texture>()

    // Filament light entities added manually (since LightEstimation is disabled).
    private var lightEntity: Int = 0
    private var sceneHasLight = false

    private val sceneView: ARSceneView = ARSceneView(context).apply {
        hostLifecycle?.let { lifecycle = it }
        sessionConfiguration = { _, config ->
            config.planeFindingMode = Config.PlaneFindingMode.DISABLED
            config.depthMode = Config.DepthMode.DISABLED
            config.lightEstimationMode = Config.LightEstimationMode.DISABLED
            config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        }

        onSessionUpdated = lambda@{ _, frame ->
            if (!sceneHasLight) {
                try {
                    lightEntity = EntityManager.get().create()
                    LightManager.Builder(LightManager.Type.DIRECTIONAL)
                        .color(1.0f, 0.98f, 0.95f)
                        .intensity(200_000f)
                        .direction(0.2f, -1f, -0.5f)
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
                val camera = frame.camera
                if (camera.trackingState == TrackingState.TRACKING) {
                    lastCameraPose = camera.pose
                    billboardMarkers(camera.pose.translation)
                }

                if (camera.trackingState != TrackingState.TRACKING) return@lambda

                val now = System.currentTimeMillis()
                if (now - lastEmitMs < EMIT_INTERVAL_MS) return@lambda
                lastEmitMs = now

                val t = camera.pose.translation
                eventSink.send(
                    mapOf(
                        "camera" to mapOf(
                            "x" to t[0].toDouble(),
                            "y" to t[1].toDouble(),
                            "z" to t[2].toDouble(),
                        ),
                    ),
                )
            } catch (t: Throwable) {
                Log.e(TAG, "onSessionUpdated failed", t)
            }
        }
    }

    override fun getView(): View = sceneView

    /**
     * Drops a compact billboarded "signal tag" quad at the camera's last known
     * world position. The tag displays the RSSI value (e.g. `-54 dBm`) on a
     * rounded colored pill and is re-oriented each frame to face the viewer.
     *
     * Material instances are cached by (RSSI bucket, color) so repeated samples
     * with similar signal reuse the same GPU texture.
     */
    fun placeMarkerAtCamera(rssi: Int, colorArgb: Int): Boolean {
        val pose = lastCameraPose ?: run {
            Log.w(TAG, "placeMarkerAtCamera: no camera pose yet — skipping")
            return false
        }

        sceneView.post {
            try {
                val t = pose.translation
                val material = getOrCreateMaterial(rssi, colorArgb)

                val planeNode = PlaneNode(
                    engine = sceneView.engine,
                    size = Float3(LABEL_WIDTH, LABEL_HEIGHT, 0f),
                    normal = Float3(0f, 0f, 1f),
                    materialInstance = material,
                ).apply {
                    position = Position(t[0], t[1] - DROP_BELOW_CAMERA, t[2])
                }

                sceneView.addChildNode(planeNode)
                markerNodes.addLast(planeNode)

                while (markerNodes.size > MAX_MARKERS) {
                    val old = markerNodes.removeFirst()
                    try {
                        sceneView.removeChildNode(old)
                        old.destroy()
                    } catch (_: Throwable) {
                        // already torn down — ignore
                    }
                }

                Log.d(TAG, "Signal tag added. count=${markerNodes.size}")
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
            for ((_, mat) in materialCache) {
                try {
                    sceneView.engine.destroyMaterialInstance(mat)
                } catch (_: Throwable) {
                    // engine may already be torn down — ignore
                }
            }
            materialCache.clear()
            for ((_, tex) in textureCache) {
                try {
                    sceneView.engine.destroyTexture(tex)
                } catch (_: Throwable) {
                    // engine may already be torn down — ignore
                }
            }
            textureCache.clear()
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

    // Yaws each marker around its Y axis so its front face looks at the camera.
    // Only yaw — pitch/roll stay zero so text remains horizontally upright.
    private fun billboardMarkers(cameraT: FloatArray) {
        if (markerNodes.isEmpty()) return
        val cx = cameraT[0]
        val cz = cameraT[2]
        for (node in markerNodes) {
            val p = node.position
            val dx = cx - p.x
            val dz = cz - p.z
            if (dx * dx + dz * dz < 1e-6f) continue
            val yawRad = atan2(dx, dz).toDouble()
            val yawDeg = Math.toDegrees(yawRad).toFloat()
            node.rotation = Rotation(x = 0f, y = yawDeg, z = 0f)
        }
    }

    private fun getOrCreateMaterial(rssi: Int, colorArgb: Int): MaterialInstance {
        val bucket = (rssi / 5.0).roundToInt() * 5
        val key = ((bucket.toLong() and 0xFFFF) shl 32) or
            (colorArgb.toLong() and 0xFFFFFFFF)
        materialCache[key]?.let { return it }
        val bitmap = renderLabelBitmap(bucket, colorArgb)
        val texture = ImageTexture.Builder()
            .bitmap(bitmap)
            .build(sceneView.engine)
        textureCache[key] = texture
        val instance = sceneView.materialLoader.createImageInstance(texture)
        materialCache[key] = instance
        return instance
    }

    private fun renderLabelBitmap(rssi: Int, colorArgb: Int): Bitmap {
        val w = BITMAP_W
        val h = BITMAP_H
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)

        val shadowRect = RectF(14f, 20f, w - 6f, h - 6f)
        val shadow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = 0x66000000.toInt()
            style = Paint.Style.FILL
        }
        canvas.drawRoundRect(shadowRect, 48f, 48f, shadow)

        val pillRect = RectF(6f, 6f, w - 14f, h - 20f)
        val bg = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = colorArgb
            style = Paint.Style.FILL
        }
        canvas.drawRoundRect(pillRect, 48f, 48f, bg)

        val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = AndroidColor.WHITE
            style = Paint.Style.STROKE
            strokeWidth = 6f
        }
        canvas.drawRoundRect(pillRect, 48f, 48f, stroke)

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = AndroidColor.WHITE
            textSize = 120f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            setShadowLayer(8f, 0f, 3f, 0xAA000000.toInt())
        }
        val text = "$rssi dBm"
        val cxText = pillRect.centerX()
        val cyText = pillRect.centerY() -
            (textPaint.descent() + textPaint.ascent()) / 2f
        canvas.drawText(text, cxText, cyText, textPaint)

        return bmp
    }

    companion object {
        private const val TAG = "ArScenePlatformView"
        private const val EMIT_INTERVAL_MS = 66L  // ~15 Hz
        private const val DROP_BELOW_CAMERA = 0.8f // metres from eye to label
        private const val LABEL_WIDTH = 0.22f      // metres
        private const val LABEL_HEIGHT = 0.11f     // metres (2:1 aspect)
        private const val BITMAP_W = 512
        private const val BITMAP_H = 256
        private const val MAX_MARKERS = 200
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
 * callback.
 */
fun interface EventChannelSink {
    fun send(event: Any)
}
