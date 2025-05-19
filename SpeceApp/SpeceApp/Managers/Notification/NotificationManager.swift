//
//  NotificationManager.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    private let notificationLeadTime: TimeInterval = 2 * 60

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("Authorization error: \(error.localizedDescription)")
//            } else {
//                print("Notification permission granted: \(granted)")
//            }
        }
    }

    func toggleLaunchNotification(launch: LaunchResult) {
        let notificationCenter = UNUserNotificationCenter.current()
        let identifier = "launchReminder_\(launch.id)"

        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            let alreadyScheduled = requests.contains { $0.identifier == identifier }

            guard let launchDate = launch.netDate else {
//                print("Notification can't be set: launch date is not present.")
                return
            }

            let reminderTime = launchDate.addingTimeInterval(-self.notificationLeadTime)

            guard self.canManipulateNotification(date: launchDate) else {
//                print("Notification can't be set: launch date is too soon or in the past.")
                return
            }

            if alreadyScheduled {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
//                print("Notification for launch \(launch.id) canceled.")
            } else {
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString(launch.name, comment: "")
                content.body = String(format: NSLocalizedString("notification.message", comment: ""), Int(self.notificationLeadTime / 60))
                content.sound = .default

                let timeInterval = reminderTime.timeIntervalSinceNow
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                notificationCenter.add(request) { error in
//                    if let error = error {
//                        print("Failed to schedule notification: \(error.localizedDescription)")
//                    } else {
//                        print("Notification for launch \(launch.id) scheduled.")
//                    }
                }
            }
        }
    }

    func canManipulateNotification(date: Date) -> Bool {
            return date.timeIntervalSinceNow > notificationLeadTime
        }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: .didReceiveLaunchNotification, object: nil)
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceiveLaunchNotification = Notification.Name("didReceiveLaunchNotification")
}
