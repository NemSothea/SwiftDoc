//
//  NotificationManager.swift
//  SmartFarmerAssistantFinish
//
//  Calendar & Reminders Module — Local Notification Manager
//

import Foundation
import UserNotifications
import CoreData

// MARK: - Notification Name for Deep Linking
extension Notification.Name {
    /// Posted when the user taps a farm-activity notification.
    /// userInfo contains  ["activityID": UUID]
    static let didTapActivityNotification = Notification.Name("didTapActivityNotification")
}

// MARK: - NotificationManager
/// Singleton that owns all UNUserNotificationCenter interactions:
///   • Requesting permission
///   • Scheduling / cancelling per-activity reminders
///   • Handling foreground presentation and tap-to-open deep links
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }

    // MARK: - Permission

    /// Requests notification permission. Calls `completion` on the main thread.
    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            print("[NotificationManager] requestPermission granted=\(granted) error=\(String(describing: error))")
            DispatchQueue.main.async {
                self.isAuthorized = granted
                completion(granted)
            }
        }
    }

    /// Re-checks the current authorization status (e.g. on app foreground).
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("[NotificationManager] checkAuthorization status=\(Self.describe(settings.authorizationStatus)) alertSetting=\(settings.alertSetting.rawValue)")
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private static func describe(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .denied:        return "denied"
        case .authorized:    return "authorized"
        case .provisional:   return "provisional"
        case .ephemeral:     return "ephemeral"
        @unknown default:    return "unknown(\(status.rawValue))"
        }
    }

    // MARK: - Schedule / Cancel

    /// Schedules a local notification that fires at the activity's date & time.
    func scheduleNotification(for activity: FarmActivity) {
        guard let id = activity.id,
              let title = activity.title,
              let date = activity.date else {
            print("[NotificationManager] schedule SKIPPED: missing id/title/date")
            return
        }

        // Don't schedule notifications in the past
        guard date > Date() else {
            print("[NotificationManager] schedule SKIPPED: date \(date) is not in the future (now=\(Date()))")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🌾 កម្មវិធីកសិកម្ម"
        content.body = title
        if let notes = activity.notes, !notes.isEmpty {
            content.body += " — \(notes)"
        }
        content.sound = .default
        content.userInfo = ["activityID": id.uuidString]

        // Fire at the exact date + time
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger
        )

        print("[NotificationManager] scheduling id=\(id.uuidString.prefix(8)) fireAt=\(date) isAuthorized=\(isAuthorized)")

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] add() FAILED: \(error)")
            } else {
                print("[NotificationManager] add() OK")
                self.dumpPendingRequests()
            }
        }
    }

    /// Removes any pending notification for the given activity ID.
    func cancelNotification(for activityID: UUID) {
        print("[NotificationManager] cancelling id=\(activityID.uuidString.prefix(8))")
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [activityID.uuidString])
    }

    /// Prints every pending local notification — call this anywhere while debugging.
    func dumpPendingRequests() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("[NotificationManager] pending count=\(requests.count)")
            for req in requests {
                let fire = (req.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
                print("  • id=\(req.identifier.prefix(8)) title=\"\(req.content.title)\" fires=\(fire?.description ?? "nil")")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Show the notification banner even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// Handle the user tapping on a notification — post a deep-link event.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let idString = userInfo["activityID"] as? String,
           let activityID = UUID(uuidString: idString) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .didTapActivityNotification,
                    object: nil,
                    userInfo: ["activityID": activityID]
                )
            }
        }
        completionHandler()
    }
}
