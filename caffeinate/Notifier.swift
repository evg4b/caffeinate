import Foundation
import UserNotifications
import os

enum Notifier {
    enum Event {
        case started
        case stopped

        var title: String {
            switch self {
            case .started: return String(localized: "Caffeinate started")
            case .stopped: return String(localized: "Caffeinate stopped")
            }
        }

        var body: String {
            switch self {
            case .started: return String(localized: "Your Mac will stay awake.")
            case .stopped: return String(localized: "Your Mac can sleep again.")
            }
        }
    }

    static func post(_ event: Event, waitForDelivery: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = event.body

        let center = UNUserNotificationCenter.current()
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        let delivered = DispatchSemaphore(value: 0)

        center.requestAuthorization(options: [.alert]) { granted, error in
            if let error {
                Logger.app.error("Notification authorization failed: \(error.localizedDescription, privacy: .public)")
            }
            guard granted else {
                delivered.signal()
                return
            }
            center.add(request) { error in
                if let error {
                    Logger.app.error("Failed to post notification: \(error.localizedDescription, privacy: .public)")
                }
                delivered.signal()
            }
        }

        if waitForDelivery {
            _ = delivered.wait(timeout: .now() + 2)
        }
    }
}
