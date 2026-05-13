# Torcav app-specific ProGuard / R8 keep rules.
#
# Flutter's default rules already cover the engine; this file is for
# native interop and platform channel handlers that R8 cannot infer.

# Keep the Kotlin classes that Flutter calls via MethodChannel.
-keep class dev.halilibrahim.torcav.MainActivity { *; }
-keep class dev.halilibrahim.torcav.PingStabilizerVpnService { *; }
-keep class dev.halilibrahim.torcav.PingStabilizerChannelHandler { *; }
-keep class dev.halilibrahim.torcav.PingStabilizerStatsSink { *; }
-keep class dev.halilibrahim.torcav.MonitoringService { *; }

# Keep ARCore + Filament native bridges (sceneview wraps them).
-keep class com.google.ar.** { *; }
-keep class io.github.sceneview.** { *; }
-keep class com.google.android.filament.** { *; }

# Keep ONNX Runtime entry points.
-keep class ai.onnxruntime.** { *; }
-keep class * implements ai.onnxruntime.OnnxRuntime { *; }

# Generated Hive type adapters (none yet, future-proof).
-keep class * extends hive.TypeAdapter { *; }

# Equatable + dartz reflection (precaution; usually unaffected).
-keepclassmembers class * extends java.lang.Enum { *; }
