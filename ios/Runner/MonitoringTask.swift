import BackgroundTasks
import Flutter
import Foundation
import SystemConfiguration.CaptiveNetwork
import UserNotifications

/// iOS counterpart of Android's `MonitoringService`. Apple does not let
/// third-party apps run a true foreground service, so the best we can do
/// is schedule a `BGAppRefreshTask` and ask the system to wake us up
/// periodically. iOS decides when (and whether) to actually run it —
/// usually some hours apart, biased toward times the user normally
/// opens the app.
///
/// Scope on iOS is intentionally narrow:
///   - `NEHotspotHelper` is gated behind a special entitlement, so we
///     don't enumerate visible networks.
///   - We only check the *connected* SSID/BSSID and post a local
///     notification if it changed since the last refresh.
///
/// This is markedly less capable than the Android side, and the
/// in-app Settings copy makes that explicit.
final class MonitoringTask {

    static let identifier = "dev.halilibrahim.torcav.refresh"
    private static let lastBssidKey = "torcav.monitor.lastBssid"

    /// Register the task identifier with iOS. Must be called before
    /// `application(_:didFinishLaunchingWithOptions:)` returns.
    static func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: nil
        ) { task in
            handle(task: task as! BGAppRefreshTask)
        }
    }

    /// Schedule the next refresh ~30 minutes out. iOS will treat that as
    /// a lower bound and may run the task much later.
    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            NSLog("Torcav: failed to schedule background refresh: \(error)")
        }
    }

    /// Cancel any pending refresh.
    static func cancel() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    }

    private static func handle(task: BGAppRefreshTask) {
        // Always reschedule first so a single failure doesn't end the
        // recurrence chain.
        schedule()

        task.expirationHandler = {
            // iOS reclaims the task — surrender gracefully.
            task.setTaskCompleted(success: false)
        }

        let defaults = UserDefaults.standard
        let lastBssid = defaults.string(forKey: lastBssidKey)
        let currentBssid = readConnectedBssid()
        defaults.set(currentBssid, forKey: lastBssidKey)

        if let last = lastBssid,
           let current = currentBssid,
           last.uppercased() != current.uppercased() {
            postChangeNotification(
                title: "Connected access point changed",
                body: "Open Torcav to verify the network is still yours."
            )
        }

        task.setTaskCompleted(success: true)
    }

    /// iOS provides only the SSID/BSSID of the *currently connected*
    /// network without entitlements. We use the public CaptiveNetwork
    /// fall-back where it still works (iOS 13+ requires location auth).
    private static func readConnectedBssid() -> String? {
        // CaptiveNetwork.CNCopyCurrentNetworkInfo is deprecated but
        // still functional with location permission. Without the
        // NEHotspotHelper entitlement there is no other public path.
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else {
                continue
            }
            if let bssid = info["BSSID"] as? String, !bssid.isEmpty {
                return bssid
            }
        }
        return nil
    }

    private static func postChangeNotification(title: String, body: String) {
        // Use a UNUserNotificationCenter request without scheduling —
        // it fires immediately. We don't request authorization here
        // because the user already opted in via Settings; the Flutter
        // side requested permission alongside the toggle.
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
