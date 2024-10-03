//
//  NotificationManager.swift
//
//
//  Created by Ashok on 26/09/24.
//

import Foundation
import PermissionsKit
import NotificationPermission
import UIKit
import UserNotifications // Make sure to import UserNotifications
import FirebaseMessaging
import FirebaseCore

public class NotificationManager : NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    public static let shared = NotificationManager()
    
    // This will ask for notification permission
    public func askNotificationPermission() {
        Permission.notification.request { [weak self] in
            guard Permission.notification.authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                self?.scheduleLocalNotifications()
            }
        }
    }
    
    public func scheduleLocalNotifications() {
        guard Permission.notification.authorized else { return }
        
        let hasUserMadeFirstCall = UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.hasUserMadeFirstCall) ?? false
        let hasUserPlayed = UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.haveUserPlayedFirstRecordingKey) ?? false
        cancelLocalNotifications()
        
        if !hasUserMadeFirstCall || !hasUserPlayed {
            let content = createNotificationContent(callMade: hasUserMadeFirstCall)
            
            scheduleNotificationOneHourAfter(content: content, date: Date())
            schedule24HoursNotification(content: content)
            
        }
    }
    
    public func cancelLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    private func createNotificationContent(callMade : Bool) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        
        if callMade {
            content.title = Constants.localPushNotificationText.titleForPlayRecording
            content.body = Constants.localPushNotificationText.subtitleForPlayRecording
        } else {
            content.title = Constants.localPushNotificationText.titleForCall
            if ConfigurationHelper.shared.isAutoCallEnabled {
                content.body = Constants.localPushNotificationText.subtitleForAutoCall
            } else {
                content.body = Constants.localPushNotificationText.subtitleForRegularCall
            }
        }
        
        content.sound = UNNotificationSound.default
        return content
    }
    
    func scheduleNotificationOneHourAfter(content: UNMutableNotificationContent, date: Date) {
        
        // Set trigger for 1 hour later
        
        let triggerDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)!
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDate.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: Constants.localPushNotificationText.oneHourNotificationIdentifier, content: content, trigger: trigger)
        
        // Add the notification request
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }else{
                print("Notification scheduled successfully")
                
            }
        }
    }
    
    private func schedule24HoursNotification(content: UNMutableNotificationContent) {
        let triggerTime: TimeInterval = 60 * 60 * 24  // 24 hours in seconds
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: true)
        
        let request = UNNotificationRequest(identifier: Constants.localPushNotificationText.repeatingNotification24HoursIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to configure Firebase and request notification permission
    public func configureNotifications() {
        
        // Set FCM delegate
        Messaging.messaging().delegate = self
        
        // Configure UserNotifications
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
    }
    
    // Handle receiving a new FCM token
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Save token or send it to your backend
        FirestoreHelper.shared.notificationToken = fcmToken ?? ""
        FirestoreHelper.shared.savePhoneNumberAndNotificationToken()
    }
    
    // UNUserNotificationCenterDelegate method to detect if app was opened via a notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        let identifier = response.notification.request.identifier
        
        let hasUserMadeFirstCall = defaults.bool(forKey: Constants.CallRecorderDefaults.hasUserMadeFirstCall) ?? false
        if identifier == Constants.localPushNotificationText.oneHourNotificationIdentifier || identifier == Constants.localPushNotificationText.repeatingNotification24HoursIdentifier {
            if hasUserMadeFirstCall {
                if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                   let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 1 // Assuming the recordings tab is at index 1
                }
            }
        } else {
            let userInfo = response.notification.request.content.userInfo
            FirestoreHelper.shared.isAppOpenedFromNotification = true
            FirestoreHelper.shared.notificationType = userInfo["type"]! as! String
        }
        
        completionHandler()
    }

}
