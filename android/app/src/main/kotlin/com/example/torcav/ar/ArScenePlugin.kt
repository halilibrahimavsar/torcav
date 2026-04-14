package com.example.torcav.ar

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Registers the `torcav/ar_scene_view` PlatformView and a broadcast
 * `torcav/ar_scene/events` EventChannel that streams detected vertical
 * planes to the Dart wall datasource.
 */
class ArScenePlugin {

    private var activeSink: EventChannel.EventSink? = null

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

        registry.registerViewFactory(
            VIEW_TYPE,
            object : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
                override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
                    return ArScenePlatformView(context) { event ->
                        activeSink?.success(event)
                    }
                }
            },
        )
    }

    companion object {
        const val VIEW_TYPE = "torcav/ar_scene_view"
        const val EVENT_CHANNEL = "torcav/ar_scene/events"
    }
}
