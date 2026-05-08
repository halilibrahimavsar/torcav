import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register the BGAppRefreshTask identifier before plugin registration —
    // iOS requires registration during didFinishLaunching.
    MonitoringTask.register()
    GeneratedPluginRegistrant.register(with: self)

    // Wire the same MethodChannel name as the Android side so the Flutter
    // BackgroundMonitorImpl works identically on both platforms.
    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let channel = FlutterMethodChannel(
        name: "torcav/background_monitor",
        binaryMessenger: messenger
      )
      channel.setMethodCallHandler { (call, result) in
        switch call.method {
        case "start":
          MonitoringTask.schedule()
          result(true)
        case "stop":
          MonitoringTask.cancel()
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
