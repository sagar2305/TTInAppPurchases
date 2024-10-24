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
                self?.scheduleLocalNotifications(isForRecording: false)
            }
        }
    }
    
    public func scheduleLocalNotifications(isForRecording: Bool) {
        guard Permission.notification.authorized else { return }
        
        let hasUserMadeFirstCall = UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.hasUserMadeFirstCall) ?? false
        let hasUserPlayed = UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.haveUserPlayedFirstRecordingKey) ?? false
        cancelLocalNotifications()
        
        if !hasUserMadeFirstCall || !hasUserPlayed {
            let content = createNotificationContent(callMade: hasUserMadeFirstCall)
            
            if(isForRecording){
                scheduleNotificationOneHourAfter(content: content, date: Date(), notificationIdenifier: Constants.localPushNotificationText.listenRecordingOneHourNotificationIdentifier)
                schedule24HoursNotification(content: content, notificationIdentifier: Constants.localPushNotificationText.listenRecordingRepeatingNotificationIdentifier)
                AnalyticsHelper.shared.logEvent(.listenRecordigNotificationsScheduled)
            }else{
                scheduleNotificationOneHourAfter(content: content, date: Date(), notificationIdenifier: Constants.localPushNotificationText.makeCallOneHourNotificationIdentifier)
                schedule24HoursNotification(content: content, notificationIdentifier: Constants.localPushNotificationText.makeCallRepeatingNotificationIdentifier)
                AnalyticsHelper.shared.logEvent(.makeCallNotificationsScheduled)
            }
            
            
        }
    }
    
    public func cancelLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        AnalyticsHelper.shared.logEvent(.cancelledAllSheduledNotification)
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
    
    func scheduleNotificationOneHourAfter(content: UNMutableNotificationContent, date: Date, notificationIdenifier: String) {
        
        // Set trigger for 1 hour later
        
        let triggerDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)!
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDate.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationIdenifier, content: content, trigger: trigger)
        
        // Add the notification request
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }else{
                print("Notification scheduled successfully")
                
            }
        }
    }
    
    private func schedule24HoursNotification(content: UNMutableNotificationContent, notificationIdentifier: String) {
        let triggerTime: TimeInterval = 60 * 60 * 24  // 24 hours in seconds
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: true)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
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
        var identifier = response.notification.request.identifier
        
        let hasUserMadeFirstCall = defaults.bool(forKey: Constants.CallRecorderDefaults.hasUserMadeFirstCall) ?? false
        if [Constants.localPushNotificationText.makeCallOneHourNotificationIdentifier, Constants.localPushNotificationText.makeCallRepeatingNotificationIdentifier, Constants.localPushNotificationText.listenRecordingOneHourNotificationIdentifier, Constants.localPushNotificationText.listenRecordingRepeatingNotificationIdentifier].contains(identifier) {
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
            identifier = FirestoreHelper.shared.notificationType
        }
        
        logDifferentTypeOfNotificationTapEvents(identifier: identifier)
        completionHandler()
    }
    
    private func logDifferentTypeOfNotificationTapEvents(identifier: String) {
        print(identifier)
        switch identifier {
        case Constants.localPushNotificationText.makeCallOneHourNotificationIdentifier:
            AnalyticsHelper.shared.logEvent(.makeCallNotificationScheduledForOneHourTapped)
            break;
        case Constants.localPushNotificationText.makeCallRepeatingNotificationIdentifier:
            AnalyticsHelper.shared.logEvent(.makeCallNotificationScheduledFor24HourTapped)
            break;
        case Constants.localPushNotificationText.listenRecordingOneHourNotificationIdentifier:
            AnalyticsHelper.shared.logEvent(.listenRecordigNotificationScheduledForOneHourTapped)
            break;
        case Constants.localPushNotificationText.listenRecordingRepeatingNotificationIdentifier:
            AnalyticsHelper.shared.logEvent(.listenRecordigNotificationScheduledFor24HourTapped)
            break;
        case Constants.localPushNotificationText.subscriptionCancelled:
            AnalyticsHelper.shared.logEvent(.subsciptionCancelledNotificationTapped)
            break;
        case Constants.localPushNotificationText.subscriptionExpired:
            AnalyticsHelper.shared.logEvent(.subsciptionExpiredNotificationTapped)
            break;
        case Constants.localPushNotificationText.billingIssue:
            AnalyticsHelper.shared.logEvent(.subsciptionBillingIssueNotificationTapped)
            break;
        case Constants.localPushNotificationText.subscriptionPaused:
            AnalyticsHelper.shared.logEvent(.subsciptionPausedNotificationTapped)
            break;
        default:
            break
        }
    }

}
