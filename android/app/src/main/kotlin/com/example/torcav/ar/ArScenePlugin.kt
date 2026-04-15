package com.example.torcav.ar

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Registers the `torcav/ar_scene_view` PlatformView, the broadcast
 * `torcav/ar_scene/events` EventChannel (plane polygons + camera pose),
 * and the `torcav/ar_scene/commands` MethodChannel used by Dart to drop
 * and clear 3D signal markers inside the AR scene.
 */
class ArScenePlugin {

    private var activeSink: EventChannel.EventSink? = null
    private var activeView: ArScenePlatformView? = null

    fun register(messenger: BinaryMessenger, registry: io.flutter.plugin.platform.PlatformViewRegistry) {
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    activeSink = events
                }

                override fun onCancel(arguments: Any?) {
                    activeSink = null
                }
            },
        )

        MethodChannel(messenger, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            val view = activeView
            if (view == null) {
                result.success(false)
                return@setMethodCallHandler
            }
            when (call.method) {
                "placeMarkerAtCamera" -> {
                    val rssi = (call.argument<Number>("rssi") ?: -70).toInt()
                    val color = (call.argument<Number>("color") ?: 0xFF00E676).toInt()
                    result.success(view.placeMarkerAtCamera(rssi, color))
                }
                "clearMarkers" -> {
                    view.clearMarkers()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        registry.registerViewFactory(
            VIEW_TYPE,
            object : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
                override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
                    val view = ArScenePlatformView(context) { event ->
                        activeSink?.success(event)
                    }
                    activeView = view
                    return view
                }
            },
        )
    }

    companion object {
        const val VIEW_TYPE = "torcav/ar_scene_view"
        const val EVENT_CHANNEL = "torcav/ar_scene/events"
        const val COMMAND_CHANNEL = "torcav/ar_scene/commands"
    }
}
