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
        ) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                completion(granted)
            }
        }
    }

    /// Re-checks the current authorization status (e.g. on app foreground).
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Schedule / Cancel

    /// Schedules a local notification that fires at the activity's date & time.
    func scheduleNotification(for activity: FarmActivity) {
        guard let id = activity.id,
              let title = activity.title,
              let date = activity.date else { return }

        // Don't schedule notifications in the past
        guard date > Date() else { return }

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
        UNUserNotificationCenter.current().add(request)
    }

    /// Removes any pending notification for the given activity ID.
    func cancelNotification(for activityID: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [activityID.uuidString])
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
