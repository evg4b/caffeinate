import AppKit
import UserNotifications
import os

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum StatusIcon {
        static let name = "CoffeeBeanIcon"
        static let size = NSSize(width: 18, height: 18)
    }

    private static let notificationResponseGrace: TimeInterval = 1

    private let controller = CaffeinateController()
    private var statusItem: NSStatusItem?
    private let launchedAt = Date()
    private var launchedFromNotification = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().delegate = self

        if notification.userInfo?[NSApplication.launchUserNotificationUserInfoKey] != nil {
            quitAfterNotificationClick()
            return
        }

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        installStatusItem()

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.notificationResponseGrace) { [weak self] in
            guard let self else { return }
            if launchedFromNotification {
                quitAfterNotificationClick()
            } else {
                controller.start()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller.stop()
    }

    private func installStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.image = Self.statusIcon()
            button.toolTip = String(
                localized: "Keeping the Mac awake — click to quit, right click for options"
            )
        }
        self.statusItem = statusItem
    }

    private func quitAfterNotificationClick() {
        Logger.app.info("Launched by a notification click; quitting without starting caffeinate")
        NSApp.terminate(nil)
    }

    private static func statusIcon() -> NSImage? {
        guard let image = NSImage(named: StatusIcon.name) else {
            Logger.app.error("Status bar icon \(StatusIcon.name, privacy: .public) is missing")
            return nil
        }
        image.isTemplate = true
        image.size = StatusIcon.size
        image.accessibilityDescription = String(localized: "Awake")
        return image
    }

    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        let opensMenu = event?.type == .rightMouseUp
            || event?.modifierFlags.contains(.control) == true

        if opensMenu {
            popUpOptionsMenu()
        } else {
            NSApp.terminate(nil)
        }
    }

    private func popUpOptionsMenu() {
        let menu = NSMenu()
        for option in CaffeinateOption.allCases {
            let item = NSMenuItem(
                title: option.title,
                action: #selector(toggleOption(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = option
            item.state = controller.isEnabled(option) ? .on : .off
            menu.addItem(item)
        }

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func toggleOption(_ sender: NSMenuItem) {
        guard let option = sender.representedObject as? CaffeinateOption else { return }
        controller.toggle(option)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if Date().timeIntervalSince(launchedAt) < Self.notificationResponseGrace {
            launchedFromNotification = true
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list])
    }
}
