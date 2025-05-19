//
//  NotificationManager.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import Foundation
import UserNotifications

// MARK: - Notification Manager

/// Manages local notifications for upcoming launches.
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    /// Shared singleton instance.
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// How many seconds before a launch the user should be notified.
    private let notificationLeadTime: TimeInterval = 2 * 60
    
    // MARK: - Notification Permissions
    
    /// Requests notification permission from the user.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            //            if let error = error {
            //                print("Authorization error: \(error.localizedDescription)")
            //            } else {
            //                print("Notification permission granted: \(granted)")
            //            }
        }
    }
    
    // MARK: - Notification Toggling
    
    /// Schedules or cancels a local notification for the given launch.
    /// - Parameter launch: The launch for which to toggle a reminder.
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
    
    /// Checks if a notification can be scheduled (launch must be in the future by the notification time).
    func canManipulateNotification(date: Date) -> Bool {
        return date.timeIntervalSinceNow > notificationLeadTime
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: .didReceiveLaunchNotification, object: nil)
        completionHandler()
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let didReceiveLaunchNotification = Notification.Name("didReceiveLaunchNotification")
}
