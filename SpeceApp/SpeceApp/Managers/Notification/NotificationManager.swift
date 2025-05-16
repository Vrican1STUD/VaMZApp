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

    // Request notification permissions
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
// take into an account that the notification have arrive 15 minutes before launch
    func toggleLaunchNotification(launch: LaunchResult) {
        let notificationCenter = UNUserNotificationCenter.current()
        let identifier = "launchReminder_\(launch.id)"

        // Step 1: Check if the notification already exists
        notificationCenter.getPendingNotificationRequests { requests in
            let alreadyScheduled = requests.contains { $0.identifier == identifier }
            
            if let launchDate = launch.netDate {
                if self.canManipulateNotification(date: launchDate) {
                    if alreadyScheduled {
                        // Step 2a: If it exists, remove it
                        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                        print("Notification for launch \(launch.id) canceled.")
                    } else {
                        // Step 2b: If not, create and add a new one
                        let content = UNMutableNotificationContent()
                        content.title = NSLocalizedString("\(launch.name)", comment: "")
                        content.body = NSLocalizedString("15 minutes and rocket is launching, so pay attention.", comment: "")
                        content.sound = .default
                        content.userInfo = ["launchId": launch.id]
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: launchDate.timeIntervalSinceNow , repeats: false)
                        
                        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                        
                        notificationCenter.add(request) { error in
                            if let error = error {
                                print("Failed to schedule notification: \(error.localizedDescription)")
                            } else {
                                print("Notification for launch \(launch.id) scheduled.")
                            }
                        }
                    }
                } else {
                    print("Notification can't be set: launch date is in the past.")
                }
            } else {
                print("Notification can't be set: launch date is not present.")
            }
        }
    }
    
    func canManipulateNotification(date: Date) -> Bool {
        return date.timeIntervalSinceNow > 0
    }

    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        if let launchId = userInfo["launchId"] as? String {
            NotificationCenter.default.post(name: .didReceiveLaunchNotification, object: nil, userInfo: ["launchId": launchId])
        }

        completionHandler()
    }
}

import Foundation

extension Notification.Name {
    static let didReceiveLaunchNotification = Notification.Name("didReceiveLaunchNotification")
}
